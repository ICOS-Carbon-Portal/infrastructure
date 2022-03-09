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

		src.traverse{
			case Defn.Class(mods, Type.Name(name), _, Ctor.Primary(_, _, params :: Nil), _) if hasCase(mods) =>
				fromCaseClass(name, params)
		}

		src.traverse{
			case Defn.Trait(mods, Type.Name(name), _, _, _) if hasSealed(mods)=>
				fromSealedTrait(name, src)
		}

	}

	private def fromSealedTrait(name: String, src: Source): Unit = {
		writer.append(s"export type $name = ")

		def extendsTrait(inits: List[Init]): Boolean = inits.collectFirst{
			case Init(Type.Name(`name`), _, _) => true
		}.isDefined

		val typeUnionMembers = mutable.Buffer.empty[String]

		src.traverse{
			case Defn.Class(mods, Type.Name(name), _, _, Template(_, inits, _, _)) if hasCase(mods) && extendsTrait(inits) =>
				typeUnionMembers += name
		}
		val typeUnion = if(typeUnionMembers.isEmpty) "void" else typeUnionMembers.mkString(" | ")
		writer.append(s"$typeUnion\n\n")
	}

	private def fromCaseClass(name: String, members: List[Term.Param]): Unit = {
		writer.append(s"export interface $name{\n")
		members.foreach{memb =>
			memb.decltpe.foreach{tpe =>
				writer.append('\t')
				fromCaseClassMember(memb.name.value, tpe)
				writer.append('\n')
			}
		}
		writer.append("}\n\n")
	}

	private def fromCaseClassMember(name: String, declType: Type): Unit = {
		def appendFor(tname: String, forType: Type): Unit = {
			val typeRepr = typeRepresentation(forType)
			writer.append(s"$tname: $typeRepr")
		}

		declType match{
			case Type.Apply(Type.Name("Option"), typeArg :: Nil) =>
				fromCaseClassMember(name.stripSuffix("?") + "?", typeArg)

			case Type.Apply(Type.Name("OptionalOneOrSeq"), _) =>
				appendFor(name.stripSuffix("?") + "?", declType)

			case _ =>
				appendFor(name, declType)
		}
	}
}


object NaiveTransformer{

	def typeNameConversion(scala: String): String = scala match{
		case "Int" | "Float" | "Double" | "Long" | "Byte" => "number"
		case "String" => "string"
		case _ => scala
	}

	def typeRepresentation(t: Type): String = t match{
		case Type.Name(name) =>
			typeNameConversion(name)

		case Type.Tuple(ttypes) =>
			ttypes.map(typeRepresentation).mkString("[", ", ", "]")

		case Type.Apply(Type.Name(collName), typeArg :: Nil) if collsToArray.contains(collName) =>
			val inner = typeRepresentation(typeArg)
			s"Array<$inner>"

		case Type.Apply(Type.Name("OptionalOneOrSeq"), typeArg :: Nil) =>
			val inner = typeRepresentation(typeArg)
			s"$inner | Array<$inner>"

		case Type.Apply(Type.Name("Either"), List(type1, type2)) =>
			val t1 = typeRepresentation(type1)
			val t2 = typeRepresentation(type2)
			s"$t1 | $t2"

		case _ => "unknown"
	}

	private val collsToArray = Set("Seq", "Array", "IndexedSeq", "Vector")

	def hasCase(mods: List[Mod]): Boolean = mods.collectFirst{
		case m @ Mod.Case() => m
	}.isDefined

	def hasSealed(mods: List[Mod]): Boolean = mods.collectFirst{
		case m @ Mod.Sealed() => m
	}.isDefined

}
