package se.lu.nateko.cp.sbtcodegen
import scala.meta._
import java.io.Writer
import scala.collection.mutable
import scala.meta.dialects.Scala3

class NaiveTransformer(writer: Writer, codeGen: CodeGenerator) {

	import NaiveTransformer._

	val init = writer.append(codeGen.initStatements)

	def declareMappings(customTypeMappings: Iterable[(String, String)]): Unit = {
		for((from, to) <- customTypeMappings){
			writer.append(codeGen.getTypeAlias(from, to))
		}
		writer.append("\n")
	}

	def fromSource(srcTxt: String): Unit = {
		val src = srcTxt.parse[Source].get
		val enumsInfo = collectEnumMembers(src)

		val sealedTraitBuffer = new mutable.ArrayBuffer[String]()

		enumsInfo.foreach{
			case (tname, membs) =>
				writer.append(codeGen.getEnum(tname, membs))
		}

		src.traverse{
			case Defn.Class(mods, Type.Name(name), _, Ctor.Primary(_, _, params :: Nil), _) if hasCase(mods) =>
				fromCaseClass(name, params, enumsInfo)

			case Defn.Trait(mods, Type.Name(name), _, _, _) if hasSealed(mods)=>
				fromSealedTrait(name, src, sealedTraitBuffer)

			case Defn.Object(mods, Term.Name(name), Template(_, inits, _, _)) if hasCase(mods) && !inits.isEmpty =>
				writer.append(codeGen.getUnitTypeVariable(name))
		}

		sealedTraitBuffer.foreach(writer.append)
	}

	private def fromSealedTrait(name: String, src: Source, sealedTraitBuffer: mutable.ArrayBuffer[String]): Unit = {
		sealedTraitBuffer.append(codeGen.getStartOfTypeDef(name))

		def extendsTrait(inits: List[Init]): Boolean = inits.collectFirst{
			case Init(Type.Name(`name`), _, _) => true
		}.isDefined

		val typeUnionMembers = src.collect{
			case Defn.Class(mods, Type.Name(name), _, _, Template(_, inits, _, _)) if hasCase(mods) && extendsTrait(inits) =>
				name
			case Defn.Object(mods, Term.Name(name), Template(_, inits, _, _)) if hasCase(mods) && extendsTrait(inits) =>
				name
			case Defn.Trait(mods, Type.Name(name), _, _, Template(_, inits, _, _)) if extendsTrait(inits) =>
				name
		}
		val typeUnion = if(typeUnionMembers.isEmpty) codeGen.unitType else typeUnionMembers.mkString(" | ")
		sealedTraitBuffer.append(codeGen.getEndOfTypeDef(typeUnion))
	}

	private def fromCaseClass(name: String, members: List[Term.Param], enumsInfo: EnumsInfo): Unit = {
		writer.append(codeGen.getStartOfClassDef(name))
		members.foreach{memb =>
			memb.decltpe.foreach{tpe =>
				writer.append('\t')
				fromCaseClassMember(memb.name.value, tpe, enumsInfo, isOptional = false)
				writer.append('\n')
			}
		}
		writer.append(codeGen.endOfClassDef)
	}

	private def fromCaseClassMember(name: String, declType: Type, enumsInfo: EnumsInfo, isOptional: Boolean): Unit = {
		def appendFor(tname: String, forType: Type, isOptionalOneOrSeq: Boolean): Unit = {
			val typeRepr = typeRepresentation(forType, enumsInfo)

			if (isOptional || isOptionalOneOrSeq) writer.append(codeGen.getOptionalTypeRepr(tname, typeRepr))
			else writer.append(s"$tname: $typeRepr")
		}

		declType match{
			case Type.Apply(Type.Name("Option"), typeArg :: Nil) =>
				fromCaseClassMember(name, typeArg, enumsInfo, isOptional = true)

			case Type.Apply(Type.Name("OptionalOneOrSeq"), typeArg) =>
				appendFor(codeGen.getOptionalName(name), declType, isOptionalOneOrSeq = true)

			case _ =>
				appendFor(name, declType, false)
		}
	}

	def typeNameConversion(scala: String): String = codeGen.getTypeNameConversion(scala)

	def typeRepresentation(t: Type, enumsInfo: EnumsInfo): String = t match{
		case Type.Name(name) =>
			typeNameConversion(name)

		case Type.Tuple(ttypes) =>
			codeGen.getTuple(ttypes.map(typeRepresentation(_, enumsInfo)))

		case Type.Apply(Type.Name(collName), typeArg :: Nil) if collsToArray.contains(collName) =>
			val inner = typeRepresentation(typeArg, enumsInfo)
			codeGen.getArray(inner)

		case Type.Apply(Type.Name(tname), typeArg :: Nil) if collsToOneOrSeq.contains(tname) =>
			val inner = typeRepresentation(typeArg, enumsInfo)
			codeGen.getOneOrSeq(inner)

		case Type.Apply(Type.Name("Either"), List(type1, type2)) =>
			val t1 = typeRepresentation(type1, enumsInfo)
			val t2 = typeRepresentation(type2, enumsInfo)
			s"$t1 | $t2"

		case Type.Select(Term.Name(termName), Type.Name(typeName)) if typeName == "Value" || typeName == termName && enumsInfo.contains(termName) =>
			termName
		case other =>
			"unknown"
	}
}

object NaiveTransformer {
	type EnumsInfo = Map[String, List[String]]

	private val collsToArray = Set("Seq", "Array", "IndexedSeq", "Vector")
	private val collsToOneOrSeq = Set("OptionalOneOrSeq", "OneOrSeq")

	def hasCase(mods: List[Mod]): Boolean = mods.collectFirst{
		case m @ Mod.Case() => m
	}.isDefined

	def hasSealed(mods: List[Mod]): Boolean = mods.collectFirst{
		case m @ Mod.Sealed() => m
	}.isDefined

	def collectEnumMembers(src: Source): EnumsInfo = {

		def collectValues(s: Stat): List[String] = s match{
			case Defn.Val(_, pats, _, Term.Name("Value")) => pats.collect{
				case Pat.Var(Term.Name(name)) => name
			}
			case Defn.Val(
				_, _, _,
				Term.Apply(Term.Name("Value"), List(Lit.String(name)))
			) => List(name)
			case _ => Nil
		}

		src.collect{
			case Defn.Object(
					_,
					Term.Name(enumName),
					Template(
						_,
						List(Init(Type.Name("Enumeration"), _, _)),
						_,
						stats
					)
				) => enumName -> stats.flatMap(collectValues)
			case e : Defn.Enum =>
				val name = e.name.value
				val cases = e.collect{
					case ec: Defn.EnumCase => List(ec.name.value)
					case rec: Defn.RepeatedEnumCase =>
						rec.cases.map(_.value)
				}.flatten
				name -> cases

		}.filterNot(_._2.isEmpty).toMap
	}
}
