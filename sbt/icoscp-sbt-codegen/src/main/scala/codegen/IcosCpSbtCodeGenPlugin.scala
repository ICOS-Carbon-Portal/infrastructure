package eu.icoscp.sbtcodegen

import sbt._
import sbt.io.IO
import sbt.Keys._
import java.io.File
import java.io.FileWriter

trait CodeGenProfile{
	def outFileName: String
	def codeGenerator: CodeGenerator
}


object IcosCpSbtCodeGenPlugin extends AutoPlugin{

	object autoImport{
		val cpCodeGenSources = settingKey[Seq[File]]("List of files with Scala sources to produce Typescript and Python declarations for")
		val cpTsGenTypeMap = settingKey[Map[String, String]]("A set of custom Scala-Typescript type name mappings")
		val cpPyGenTypeMap = settingKey[Map[String, String]]("A set of custom Scala-Python type name mappings")
		val cpCodeGenRun = taskKey[Seq[File]]("(Over)write the Typescript and Python output files")
	}

	import autoImport._

	private object TsCodeGenProfile extends CodeGenProfile{
		val outFileName = "metacore.d.ts"
		val codeGenerator = TypeScriptCodeGenerator
	}
	private object PythonCodeGenProfile extends CodeGenProfile{
		val outFileName = "metacore.py"
		val codeGenerator = PythonCodeGenerator
	}

	override lazy val projectSettings = Seq(
		cpCodeGenSources := Nil,
		cpTsGenTypeMap := Map.empty,
		cpPyGenTypeMap := Map.empty,
		cpCodeGenRun := {
			val log = streams.value.log
			val sources = cpCodeGenSources.value

			log.info("Generating Typescript and Python code to be packaged in Scala library jar")
			if(sources.isEmpty) log.warn(
				"List of Scala sources for Typescript and Python generation was empty. Set cpCodeGenSources setting."
			)

			val outDir = resourceManaged.value
			IO.createDirectory(outDir)

			Seq(TsCodeGenProfile, PythonCodeGenProfile).map{profile =>
				val outFile = outDir / profile.outFileName
				val writer = new FileWriter(outFile)
	
				try{
					val transf = new NaiveTransformer(writer, profile.codeGenerator)

					profile match {
						case TsCodeGenProfile =>
							transf.declareMappings(cpTsGenTypeMap.value)
						case PythonCodeGenProfile =>
							transf.declareMappings(cpPyGenTypeMap.value)
					}

					cpCodeGenSources.value.foreach{srcFile =>
						val src = IO.read(srcFile)
						transf.fromSource(src)
					}

					writer.append(profile.codeGenerator.epilogue)

					outFile
				}
				finally{
					writer.close()
				}
			}
		},
		Compile / resourceGenerators += cpCodeGenRun
	)
}
