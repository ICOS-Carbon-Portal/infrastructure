# icos.rdf_common

Template-only "role": it has no tasks and is never applied to a host. It holds the
configuration templates that are shared between `icos.cpmeta` (the `meta` service) and
`icos.cpmeta_rdfstore` (the `rdfStore` service), and is named after the `rdfCommon` build
module that owns the same configuration in the meta repository.

`meta` and `rdfStore` are two independently deployed applications that read parts of the same
`cpmeta.*` configuration contract - the RDF log database, the DataCite credentials, the ENVRI
hosts and the instance-server/graph layout. See `docs/rdf-store-split.md` in the meta
repository, section "Configuration", for which paths are shared and why.

Neither service may include the other's templates. `application_shared.conf` is the one
template both include in their generated `application.conf`, so their views of the shared
configuration cannot drift. Deployment-specific configuration remains in the owning service's
own template.

`application_metacore.conf` is the one topic kept in its own file: `icos.cpdata` needs the
ENVRI hosts without the rest of the shared configuration, so it includes that file directly
and `application_shared.conf` pulls it in for meta and rdfStore.
