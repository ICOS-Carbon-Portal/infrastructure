package se.lu.nateko.cp.sbtfrontend

import sbt.internal.util.ExitHook
import scala.sys.process.Process
import java.lang.{Process => JProcess, ProcessBuilder, ProcessHandle}

class KillUnixProcWithChildren(val hdl: ProcessHandle) extends ExitHook{
	def runBeforeExiting(): Unit = UnixProcessWithChildren.terminate(hdl)

	override def equals(x: Any): Boolean = x match{
		case other: KillUnixProcWithChildren => other.hdl.pid() == hdl.pid()
		case _ => false
	}

	override def hashCode(): Int = hdl.pid().toInt
}

class UnixProcessWithChildren(val proc: JProcess){

	val exitHook = new KillUnixProcWithChildren(proc.toHandle)

	def killAndWaitFor(): Int = {
		if(proc.isAlive()) UnixProcessWithChildren.terminate(proc.toHandle)
		proc.waitFor()
	}
}

object UnixProcessWithChildren{

	def terminate(hdl: ProcessHandle): Unit = {
		hdl.children().forEach(terminate)
		hdl.destroy()
	}

	def run(dir: java.io.File, command: String*): UnixProcessWithChildren = {
		val pb = new ProcessBuilder(command: _*)
		pb.directory(dir)
		pb.redirectOutput(ProcessBuilder.Redirect.INHERIT)
		val proc = pb.start()
		new UnixProcessWithChildren(proc)
	}

	implicit class ExitHooksProcReplacementOpt(val set: Set[ExitHook]) extends AnyVal{

		def replaceProcToKill(kill: KillUnixProcWithChildren): Set[ExitHook] = dropProcessKilling + kill

		def dropProcessKilling: Set[ExitHook] = set.filter{
			case _: KillUnixProcWithChildren => false
			case _ => true
		}
	}
}
