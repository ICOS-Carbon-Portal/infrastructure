# ERDDAP recovery test — 2026-10-02

A fresh isolated Ubuntu 24.04 container rebuilt active data using the pinned
runtime/ingestion code and only the ICOS authentication file:
`/home/ubuntu/.icoscp/cpauthToken_auth_conf.json`.
No database, CSVs, `datasets.xml`, caches or shared data mount were restored.
Without the authentication file, downloads failed.

The authenticated ingestion run took 4 minutes 25 seconds, excluding provisioning
and cache loading. All 391 CSV checksums and 783 catalog IDs matched; sample
queries and SQLite integrity checks passed. The 13 deleted historical database
records were not recreated.

This demonstrates recovery of the active data available at that time, not a
guarantee against upstream data removal or service outages. Preserve credentials,
custom assets, subscriptions and SQLite history in [backups](backup.md).

The temporary container was removed. Its test playbook/inventory are not
maintained here; this is a test record, not a runnable recovery procedure.
See [current operations](README.md) for rebuild precautions.
