package se.lu.nateko.cp.sbttsgen
import scala.meta._
import java.io.Writer
import scala.collection.mutable

class NaiveTransformer(writer: Writer){

	import NaiveTransformer._

	def declareMappings(customTypeMappings: Iterable[(String, String)]): Unit = {
		for((from, to) <- customTypeMappings){
			writer.append(s"type $from = $to\n")
		}
		writer.append("\n")
	}

	def fromSource(srcTxt: String): Unit = {
		val src = srcTxt.parse[Source].get

		val enumsInfo = collectEnumMembers(src)

		enumsInfo.foreach{
			case (tname, membs) =>
				writer.append(s"export type $tname = ")
				writer.append(membs.mkString("\"", "\" | \"", "\""))
				writer.append("\n\n")
		}

		src.traverse{
			case Defn.Class(mods, Type.Name(name), _, Ctor.Primary(_, _, params :: Nil), _) if hasCase(mods) =>
				fromCaseClass(name, params, enumsInfo)

			case Defn.Trait(mods, Type.Name(name), _, _, _) if hasSealed(mods)=>
				fromSealedTrait(name, src)

			case Defn.Object(mods, Term.Name(name), Template(_, inits, _, _)) if hasCase(mods) && !inits.isEmpty =>
				writer.append(s"export type $name = void\n\n")
		}

	}

	private def fromSealedTrait(name: String, src: Source): Unit = {
		writer.append(s"export type $name = ")

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
		val typeUnion = if(typeUnionMembers.isEmpty) "void" else typeUnionMembers.mkString(" | ")
		writer.append(s"$typeUnion\n\n")
	}

	private def fromCaseClass(name: String, members: List[Term.Param], enumsInfo: EnumsInfo): Unit = {
		writer.append(s"export interface $name{\n")
		members.foreach{memb =>
			memb.decltpe.foreach{tpe =>
				writer.append('\t')
				fromCaseClassMember(memb.name.value, tpe, enumsInfo)
				writer.append('\n')
			}
		}
		writer.append("}\n\n")
	}

	private def fromCaseClassMember(name: String, declType: Type, enumsInfo: EnumsInfo): Unit = {
		def appendFor(tname: String, forType: Type): Unit = {
			val typeRepr = typeRepresentation(forType, enumsInfo)
			writer.append(s"$tname: $typeRepr")
		}

		declType match{
			case Type.Apply(Type.Name("Option"), typeArg :: Nil) =>
				fromCaseClassMember(name.stripSuffix("?") + "?", typeArg, enumsInfo)

			case Type.Apply(Type.Name("OptionalOneOrSeq"), _) =>
				appendFor(name.stripSuffix("?") + "?", declType)

			case _ =>
				appendFor(name, declType)
		}
	}
}


object NaiveTransformer{
	type EnumsInfo = Map[String, List[String]]

	def typeNameConversion(scala: String): String = scala match{
		case "Int" | "Float" | "Double" | "Long" | "Byte" => "number"
		case "String" => "string"
		case _ => scala
	}

	def typeRepresentation(t: Type, enumsInfo: EnumsInfo): String = t match{
		case Type.Name(name) =>
			typeNameConversion(name)

		case Type.Tuple(ttypes) =>
			ttypes.map(typeRepresentation(_, enumsInfo)).mkString("[", ", ", "]")

		case Type.Apply(Type.Name(collName), typeArg :: Nil) if collsToArray.contains(collName) =>
			val inner = typeRepresentation(typeArg, enumsInfo)
			s"Array<$inner>"

		case Type.Apply(Type.Name("OptionalOneOrSeq"), typeArg :: Nil) =>
			val inner = typeRepresentation(typeArg, enumsInfo)
			s"$inner | Array<$inner>"

		case Type.Apply(Type.Name("Either"), List(type1, type2)) =>
			val t1 = typeRepresentation(type1, enumsInfo)
			val t2 = typeRepresentation(type2, enumsInfo)
			s"$t1 | $t2"

		case Type.Select(Term.Name(termName), Type.Name(typeName)) if typeName == "Value" || typeName == termName && enumsInfo.contains(termName) =>
			termName
		case other =>
			"unknown"
	}

	private val collsToArray = Set("Seq", "Array", "IndexedSeq", "Vector")

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
		}.filterNot(_._2.isEmpty).toMap
	}
}
