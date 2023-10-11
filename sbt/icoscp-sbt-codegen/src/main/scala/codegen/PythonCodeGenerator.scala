package eu.icoscp.sbtcodegen

object PythonCodeGenerator extends CodeGenerator{

	val unitType = "None"
	val prologue: String =
		"from __future__ import annotations\n" +
		"from dataclasses import dataclass\n" +
		"from typing import Optional, Literal, Type, TypeAlias, TypeVar, Any\n" +
		"from dacite import Config, from_dict\n" +
		"import json\n" + "\n"

	val epilogue: String = """
CPJson = TypeVar('CPJson')

def parse_cp_json(input_text: str, data_class: Type[CPJson]) -> CPJson:
	def tuple_hook(d: dict[str, Any]) -> Any:
		for k in d.keys():
			if isinstance(d[k], list):
					d[k] = tuple(d[k])

		return d

	input_dict=json.JSONDecoder(object_hook=tuple_hook).decode(input_text)

	return from_dict(data_class=data_class, data=input_dict, config=Config(cast=[list]))
"""

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

	def getStartOfClassDef(name: String): String = s"@dataclass(frozen=True)\n" + s"class $name:\n"
	val endOfClassDef: String = "\n\n"

	def getEnum(tname: String, membs: List[String]): String =
		s"$tname: TypeAlias = Literal[" + membs.mkString("\"", "\" , \"", "\"") + "]\n\n"

	def getOptionalTypeRepr(tname: String, typeRepr: String) = s"$tname: Optional[$typeRepr]"

	def getOptionalName(name: String): String = name // no change in python

	def getTuple(types: List[String]): String = types.mkString("tuple[", ", ", "]")

}
