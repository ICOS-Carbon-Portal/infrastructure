package eu.icoscp.sbtcodegen

import sbt._
import sbt.io.IO
import sbt.Keys._
import java.io.File
import java.io.FileWriter

object IcosCpSbtCodeGenPlugin extends AutoPlugin{

	private val OutFileName = "metacore.d."

	object autoImport{
		val cpCodeGenSources = settingKey[Seq[File]]("List of files with Scala sources to produce Typescript and Python declarations for")
		val cpTsGenTypeMap = settingKey[Map[String, String]]("A set of custom Scala-Typescript type name mappings")
		val cpPyGenTypeMap = settingKey[Map[String, String]]("A set of custom Scala-Python type name mappings")
		val cpCodeGenRun = taskKey[Seq[File]]("(Over)write the Typescript and Python output files")
	}

	import autoImport._

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

			val exts = Seq("ts", "py")
			var outFiles = Seq[File]()

			for (ext <- exts) {
				val outFile = outDir / OutFileName + ext
				val writer = new FileWriter(outFile)
	
				try{
					val transf = ext match {
						case "ts" =>
							val tsTransf = new NaiveTransformer(writer, TypeScriptCodeGenerator)
							tsTransf.declareMappings(cpTsGenTypeMap.value)
							tsTransf
						case "py" =>
							val pyTransf = new NaiveTransformer(writer, PythonCodeGenerator)
							pyTransf.declareMappings(cpPyGenTypeMap.value)
							pyTransf
					}
	
					cpCodeGenSources.value.foreach{srcFile =>
						val src = IO.read(srcFile)
						transf.fromSource(src)
					}

					if (ext == "py") writer.append(PythonCodeGenerator.parser)

					outFiles :+ outFile
				}
				finally{
					writer.close()
				}
			}
			outFiles
		},
		Compile / resourceGenerators += cpCodeGenRun
	)
}
