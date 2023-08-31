package se.lu.nateko.cp.sbtcodegen

trait CodeGenerator {
	val unitType: String
	val initStatements: String
	def getTypeAlias(from: String, to: String): String
	def getTypeNameConversion(scala: String): String
	def getArray(inner: String): String
	def getOneOrSeq(inner: String): String
	def getUnitTypeVariable(name: String): String
	def getEnum(tname: String, membs: List[String]): String
	def getStartOfTypeDef(name: String): String
	def getEndOfTypeDef(typeUnion: String): String
	def getStartOfClassDef(name: String): String
	val endOfClassDef: String
	def getOptionalTypeRepr(tname: String, typeRepr: String): String
	def getOptionalName(name: String): String
	def getTuple(types: List[String]): String
}
