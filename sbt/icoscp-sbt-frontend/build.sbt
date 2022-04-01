
scalaVersion in ThisBuild := "2.12.15"
name := "icoscp-sbt-frontend"
organization := "se.lu.nateko.cp"
version := "0.1.1"

sbtPlugin := true

publishTo := {
	val nexus = "https://repo.icos-cp.eu/content/repositories/"
	if (isSnapshot.value)
		Some("snapshots" at nexus + "snapshots")
	else
		Some("releases"  at nexus + "releases")
}

credentials += Credentials(Path.userHome / ".ivy2" / ".credentials")

libraryDependencies ++= Seq(
)

