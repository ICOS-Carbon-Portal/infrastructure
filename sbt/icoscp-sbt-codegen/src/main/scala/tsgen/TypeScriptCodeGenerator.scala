package se.lu.nateko.cp.sbtcodegen

class TypeScriptCodeGenerator extends CodeGenerator{

	val unitType = "void"
	val initStatements = ""

	def getTypeAlias(from: String, to: String): String = s"type $from = $to\n"

	def getTypeNameConversion(scala: String): String = scala match{
		case "Int" | "Float" | "Double" | "Long" | "Byte" => "number"
		case "String" => "string"
		case _ => scala
	}

	def getArray(inner: String): String = s"Array<$inner>"	
	def getOneOrSeq(inner: String): String = s"$inner | Array<$inner>"

	def getUnitTypeVariable(name: String) = s"export type $name = void\n\n"

	def getStartOfTypeDef(name: String) = s"export type $name = "
	def getEndOfTypeDef(typeUnion: String) = s"$typeUnion\n\n"

	def getStartOfClassDef(name: String) = s"export interface $name{\n"
	val endOfClassDef = "}\n\n"

	def getEnum(tname: String, membs: List[String]): String =
		s"export type $tname = " +
		membs.mkString("\"", "\" | \"", "\"") +
		"\n\n"
	
	def getOptionalTypeRepr(tname: String, typeRepr: String) = {
		val name = tname.stripSuffix("?") + "?"
		s"$name: $typeRepr"
	}

	def getOptionalName(name: String): String = name.stripSuffix("?") + "?"

	def getTuple(types: List[String]): String = types.mkString("[", ", ", "]")
}
