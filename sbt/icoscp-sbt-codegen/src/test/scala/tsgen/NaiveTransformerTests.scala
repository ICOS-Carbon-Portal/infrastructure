package se.lu.nateko.cp.sbtcodegen
import org.scalatest.FunSuite
import java.io.StringWriter
import java.io.FileWriter

class TsTransformerTests extends FunSuite{

	private val example = """|
	|	case class UriResource(uri: URI, label: Option[String])

	|	sealed trait Agent{
	|		val self: UriResource
	|	}
	|	case class Organization(self: UriResource, name: String) extends Agent
	|	case class Person(self: UriResource, firstName: String, lastName: String) extends Agent

	|	case class Station(
	|		org: Organization,
	|		id: String,
	|		name: String,
	|		coverage: Option[GeoFeature],
	|		funding: Option[Seq[Funding]]
	|	)
	|	case class Funding(
	|		self: UriResource,
	|		funder: Funder,
	|		awardTitle: Option[String],
	|		awardNumber: Option[String],
	|		awardUrl: Option[URI],
	|		start: Option[LocalDate],
	|		stop: Option[LocalDate],
	|	)
	|	type LatLon = (Double, Double)

	|	object FunderIdType extends Enumeration{
	|		val Crossref = Value("Crossref Funder ID")
	|		val GRID, ISNI, ROR, Other = Value
	|	}
	|
	|	case class Funder(org: Organization, id: Option[(String,FunderIdType.Value)])

	|	case class DataTheme(self: UriResource, icon: URI, markerIcon: Option[URI])

	|	case class DataObjectSpec(
	|		self: UriResource,
	|		project: UriResource,
	|		theme: DataTheme,
	|		format: UriResource,
	|		encoding: UriResource,
	|		dataLevel: Int,
	|		datasetSpec: Option[JsValue]
	|	)

	|	case class DataAcquisition(
	|		station: Station,
	|		interval: Option[TimeInterval],
	|		instrument: OptionalOneOrSeq[URI],
	|		samplingHeight: Option[Float]
	|	){
	|		def instruments: Seq[URI] = instrument.fold(Seq.empty[URI])(_.fold(Seq(_), identity))
	|	}

	|	case class DataProduction(
	|		creator: Agent,
	|		contributors: Seq[Agent],
	|		host: Option[Organization],
	|		comment: Option[String],
	|		sources: Seq[UriResource],
	|		dateTime: Instant
	|	)
	|
	|case class DataObject(
	|	hash: Sha256Sum,
	|	accessUrl: Option[URI],
	|	pid: Option[String],
	|	doi: Option[String],
	|	fileName: String,
	|	size: Option[Long],
	|	submission: DataSubmission,
	|	specification: DataObjectSpec,
	|	specificInfo: Either[L3SpecificMeta, L2OrLessSpecificMeta],
	|	previousVersion: OptionalOneOrSeq[URI],
	|	nextVersion: Option[URI],
	|	parentCollections: Seq[UriResource],
	|	citationString: Option[String]
	|)""".stripMargin

	ignore("workbench for manual testing"){
		val writer = new FileWriter("/home/klara/tstest.ts")
		// val writer = new FileWriter("/home/klara/pytest.py")
		val codeGen = new TypeScriptCodeGenerator
		// val codeGen = new PythonCodeGenerator

		val transf = new NaiveTransformer(writer, codeGen)
		try{
			transf.fromSource(example)
		}
		finally{
			writer.close()
		}
	}
}