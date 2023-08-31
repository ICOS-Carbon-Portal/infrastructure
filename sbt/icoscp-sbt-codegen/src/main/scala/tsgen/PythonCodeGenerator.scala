package se.lu.nateko.cp.sbtcodegen

class PythonCodeGenerator extends CodeGenerator{

  val unitType = "None"
  val initStatements: String = 
    "from __future__ import annotations\n" + 
    "from dataclasses import dataclass\n" + 
    "from typing import Optional\n" + 
    "from typing import TypeAlias\n" +
    "from typing import Literal\n" + "\n"

  def getTypeAlias(from: String, to: String): String = s"$from: TypeAlias = $to\n"

  def getTypeNameConversion(scala: String): String = scala match{
		case "Int" | "Long" => "int"
		case "Float" | "Double" => "float"
		case "String" => "str"
		case "Boolean" => "bool"
		case _ => scala
	}

	def getArray(inner: String): String = s"list[$inner]"
	def getOneOrSeq(inner: String): String = s"$inner | list[$inner]"

  def getUnitTypeVariable(name: String) = getTypeAlias(name, "None\n")

  def getStartOfTypeDef(name: String) = s"$name: TypeAlias = "
	def getEndOfTypeDef(typeUnion: String) = s"$typeUnion\n\n"

  def getStartOfClassDef(name: String): String = s"@dataclass\n" + s"class $name:\n"
	val endOfClassDef: String = "\n\n"

  def getEnum(tname: String, membs: List[String]): String = 
    s"$tname: TypeAlias = Literal[" + membs.mkString("\"", "\" , \"", "\"") + "]\n\n"

  def getOptionalTypeRepr(tname: String, typeRepr: String) = s"$tname: Optional[$typeRepr]"

	def getOptionalName(name: String): String = name // no change in python

	def getTuple(types: List[String]): String = types.mkString("tuple[", ", ", "]")
}
