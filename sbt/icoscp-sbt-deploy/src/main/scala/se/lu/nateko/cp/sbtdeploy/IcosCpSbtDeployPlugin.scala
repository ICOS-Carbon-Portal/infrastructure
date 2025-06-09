package se.lu.nateko.cp.sbtdeploy

import sbt._
import sbt.Keys._
import sbt.plugins.JvmPlugin
import sbtassembly.AssemblyPlugin
import sbtbuildinfo.BuildInfoPlugin

import scala.sys.process.Process


object IcosCpSbtDeployPlugin extends AutoPlugin {

	override def trigger = noTrigger
	override def requires = AssemblyPlugin && BuildInfoPlugin

	override lazy val buildSettings = Seq()

	override lazy val globalSettings = Seq()

	object autoImport {
		val cpDeploy = inputKey[Int]("Deploys to production using Ansible (depends on 'infrastructure' project)")
		val cpDeployPreAssembly = taskKey[Unit]("Task for operations to be performed before packaging of the fat JAR")
		val cpDeployTarget = settingKey[String]("Ansible target role for cpDeploy")
		val cpDeployBuildInfoPackage = settingKey[String]("Java/Scala package to put BuildInfo object into")
		val cpDeployPlaybook = settingKey[String]("The ansible playbook")
		val cpDeployPermittedInventories = settingKey[Option[Seq[String]]](
			"Inventories that are permitted to be used with the chosen playbook. If None, all inventories are permitted."
		)
		val cpDeployInfraBranch = settingKey[String]("The branch of 'infrastructure' repository to execute Ansible against")
	}

	import autoImport._
	import AssemblyPlugin.autoImport.assembly
	import BuildInfoPlugin.autoImport._

	lazy val gitChecksTask = Def.task {
		val log = streams.value.log

		log.info("Check git status")
		val gitStatus = Process("git status -s").lineStream.mkString("").trim
		if(!gitStatus.isEmpty) sys.error("Please clean your 'git status -s' before deploying!")

		log.info("Check infrastructure version")
		val infrastructureDir = new java.io.File("../infrastructure/").getCanonicalFile
		val branch = cpDeployInfraBranch.value
		Process("git -C " + infrastructureDir + " fetch")
		if (Process("git -C " + infrastructureDir + s" rev-list HEAD...origin/$branch --count").!!.trim.toInt > 0) {
			sys.error(s"Your infrastructure repo is not in sync with origin/$branch.")
		}
	}

	lazy val cpAnsible = Def.inputTask {
		val log = streams.value.log
		val args: Seq[String] = sbt.Def.spaceDelimited().parsed

		val inventories = cpDeployPermittedInventories.value

		val (check, inventory) = args.toList match{
			case "to" :: inventory :: Nil =>
				if(inventories.fold(true)(_.contains(inventory))) {
					log.info(s"Performing a REAL deployment with $inventory inventory")
					(false, inventory)
				} else
					sys.error(s"Inventory '$inventory' is not enabled for this playbook. " +
						s"Permitted inventories are: ${inventories.toSeq.flatten.mkString(", ")}")
			case _ =>
				log.warn("Performing a CHECK deployment with 'production' inventory. Use " +
					"'cpDeploy to <inventory_name>' for a real deployment with <inventory_name> inventory")
				(true, "production")
		}

		// The full path of the "fat" jarfile. The jarfile contains the
		// entire application and this is the file we will deploy.
		val jarPath = assembly.value.getAbsolutePath

		// The name used by Ansible to identify this core service, e.g. 'cpdata', 'cpmeta', 'cpauth'
		val target = cpDeployTarget.value
		val playbook = cpDeployPlaybook.value

		val ansibleCmd = Seq(
			"ansible-playbook",
			// "--check" will make ansible simulate all its actions. It's
			// only useful when running against the production inventory.
			if (check) "--check" else "",

			// Add an ansible tag, e.g '-t cpdata_deploy'. Each ansible role that we use
			// is required to have a 'project_deploy' tag that will only to
			// (re)deployment of the jarfile, i.e it'll skip its dependencies (linux,
			// nginx, docker etc)
			"-t",  target + "_deploy",

			// Add an extra ansible variable specifying which jarfile to deploy.
			"-e", s"""${target}_jar_file="$jarPath"""",

			// Specify which inventory to use
			"-i", s"${inventory}.inventory",

			playbook

		).filterNot(_.isEmpty)

		val ansibleDir = new java.io.File("../infrastructure/devops/").getCanonicalFile
		val ansiblePath = ansibleDir.getAbsolutePath
		if(!ansibleDir.exists || !ansibleDir.isDirectory) sys.error("Folder not found: " + ansiblePath)

		log.info(ansibleCmd.mkString("RUNNING:\n", " ", "\nIN DIRECTORY " + ansiblePath))

		Process(ansibleCmd, ansibleDir).run(log, false).exitValue()
	}

	override lazy val projectSettings = Seq(
		cpDeployPlaybook := "core.yml",
		cpDeployPermittedInventories := None,
		cpDeploy := cpAnsible.dependsOn(gitChecksTask).evaluated,
		cpDeployPreAssembly := {},
		cpDeployInfraBranch := "master",
		assembly := assembly.dependsOn(cpDeployPreAssembly).value,
		buildInfoKeys := Seq[BuildInfoKey](name, version),
		buildInfoPackage := cpDeployBuildInfoPackage.value,
		buildInfoKeys ++= Seq(
			BuildInfoKey.action("buildTime") {java.time.Instant.now().toString()},
			BuildInfoKey.action("gitHash") {
				Process("git rev-parse HEAD").lineStream.mkString("")
			},
			BuildInfoKey.action("gitBranch") {
				Process("git branch --show-current").lineStream.mkString("")
			}
		)
	)
}
