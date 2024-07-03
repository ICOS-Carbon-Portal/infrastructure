
ThisBuild / scalaVersion := "2.12.19"
name := "icoscp-sbt-deploy"
organization := "se.lu.nateko.cp"
version := "0.4.0"

sbtPlugin := true

publishTo := {
	val nexus = "https://repo.icos-cp.eu/content/repositories/"
	if (isSnapshot.value)
		Some("snapshots" at nexus + "snapshots")
	else
		Some("releases"  at nexus + "releases")
}

credentials += Credentials(Path.userHome / ".ivy2" / ".credentials")

libraryDependencies ++= {

	def pluginDependency(pluginModule: ModuleID): ModuleID =
		Defaults.sbtPluginExtra(pluginModule, sbtBinaryVersion.value, scalaBinaryVersion.value)

	Seq(
		pluginDependency("com.eed3si9n" % "sbt-assembly" % "2.2.0"),
		pluginDependency("com.eed3si9n" % "sbt-buildinfo" % "0.12.0")
	)
}
