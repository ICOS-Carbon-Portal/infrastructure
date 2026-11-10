# fsicos2 cpmeta stall — 2026-10-14

Status: service recovered; root cause unconfirmed. All times below are UTC.
Diagnostics described in the role runbook are proposed remediation, not evidence
that they were active during this incident.

## Evidence

- cpmeta PID 516947, started October 6, remained running after the incident.
- 03:54–03:55: several long-running SPARQL queries terminated.
- Around 03:55–03:59: metadata requests stalled; normal latency returned by 04:00.
- 03:57:18: `DE-HoH_EC_202610140330_L99_F01.zip` failed connecting to
  `127.0.0.1:9094` after ten seconds. Other stations were affected too.
- Nginx logged upstream response-header timeouts against that same endpoint.
- Object observation logs showed p95 latency around 0.1 seconds before/after,
  with requests taking 60–92 seconds during the incident. Hundreds of requests
  per minute received 429s, alongside client disconnects (499) and 504s.
- No obvious request-volume spike immediately preceded the stall. Traffic
  included crawler user agents and Google-proxied requests; this alone does not
  establish a cause or verify every client's identity.
- 03:59:17–38: RDF4J connection-cleanup errors, detached response streams and
  multiple object/SPARQL request timeouts. These may be secondary failures.
- Some application timestamps preceded journal receipt by tens of seconds.
- Sysstat's 03:50–04:00 interval: 77% CPU idle, about 127 GiB available memory,
  negligible swap-in, 0.43% I/O wait, modest disk utilization. Ten-minute averages
  cannot exclude short spikes or individual-thread saturation.
- JVM uses G1 with approximately 30 GiB maximum heap. GC/safepoint logging was
  not enabled, so historical pauses cannot be established from those logs.
- Later direct HTTP check and socket inspection showed a responsive service and
  empty accept queue. A probe with the proper Host header returned HTTP 200.

Sources: staging ETC upload error log, cpmeta journal, `/var/log/nginx/error.log`,
`cpmeta.access.log`, `cpmeta-objects-observe.log`, `/var/log/sysstat/sa14`, and
read-only JVM logging/flag inspection. Kuma also showed a corresponding slowdown.

## Later stalls (not investigated)

Nginx upstream timeouts against `127.0.0.1:9094` in `/var/log/nginx/error.log*`,
which went back to October 27 when checked on November 10:

| Window (UTC)            | Timeouts |
|-------------------------|---------:|
| Nov 3, 07:32            |       40 |
| Nov 3, 08:33–08:35      |       83 |
| Nov 4, 06:07–06:24      |      710 |
| Nov 9, 11:11–11:13      |       30 |

On November 4, a 6.4 GB crash report for the cpmeta JVM was written to
`/var/crash` at 06:23, the last minute of the longest stall. These counts only
show that the stalls recur; they were not investigated like the October 14 one.

## Assessment and follow-up

Confirmed shared backend stall, not evidence of invalid DE-HoH input. Sustained
host-wide resource exhaustion is not supported by the available samples.
Dispatcher starvation, lock contention and GC pauses remain hypotheses. Neither
SPARQL traffic nor the later RDF4J exceptions prove the initiating cause.

Add rotating GC/safepoint logs, failure-triggered thread dumps, and one-minute
sysstat samples. Correlate future captures with existing Kuma/OpenSearch data.
See [deployment and rollback runbook](../../roles/icos.cpmeta/README.md).
