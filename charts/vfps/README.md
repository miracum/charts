# vfps

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A Helm chart for deploying VFPS, a very fast and resource-efficient pseudonym service.

**Homepage:** <https://github.com/miracum/vfps>

## Installation

```sh
helm repo add miracum https://miracum.github.io/charts
helm repo update
helm install --create-namespace vfps miracum/vfps -n vfps
```

> **Warning**
> By default, the included [PostgreSQL Helm chart](https://github.com/bitnami/charts/tree/master/bitnami/postgresql#upgrading)
> auto-generates a random password for the database which may cause problems when upgrading the chart (see [here for details](https://github.com/bitnami/charts/tree/master/bitnami/postgresql#upgrading)).

## Usage

```sh
kubectl run --namespace=vfps -i --tty --rm --image=ghcr.io/miracum/vfps-grpc-utils:latest --restart=Never vfps-tester -- bash

nobody@debug:/$ grpcurl \
  -plaintext \
  -import-path=/tmp/protos/ \
  -proto=Protos/vfps/api/v1/namespaces.proto \
  -d '{"name": "test", "pseudonymGenerationMethod": "PSEUDONYM_GENERATION_METHOD_SECURE_RANDOM_BASE64URL_ENCODED", "pseudonymLength": 32}' \
  vfps-headless:8081 \
  vfps.api.v1.NamespaceService/Create

nobody@debug:/$ ghz --duration=1m \
  --connections=3 \
  --lb-strategy=round_robin \
  --cpus=3 \
  --insecure \
  --enable-compression \
  --import-paths=/tmp/protos/ \
  --proto=Protos/vfps/api/v1/pseudonyms.proto \
  --call=vfps.api.v1.PseudonymService/Create \
  -d '{"originalValue": "{{ randomString 32 }}", "namespace": "test"}' \
  dns:///vfps-headless:8081
```

## CSV pseudonymization jobs

Off by default. Enabling them needs object storage for the input/output files, and a database
(Hangfire reuses the same one for its job storage):

```yaml
s3:
  enabled: true
  serviceUrl: https://minio.example.org
  bucket: vfps-csv-jobs
  existingSecret: vfps-s3
  # the admin UI uploads straight to the bucket from the browser, so its own origin has to be
  # allowed or the browser blocks the upload with a CORS error
  allowedOrigins:
    - https://vfps.example.org
```

Use a bucket dedicated to vfps: on startup the application replaces that bucket's entire lifecycle
and CORS configuration. `s3.objectRetentionDays` (30 by default) is what eventually deletes the
uploaded files - job records are kept, so without it the original, unpseudonymized input would stay
in the bucket indefinitely.

Credentials can also be given inline as `s3.accessKey`/`s3.secretKey`, which the chart puts into a
Secret rather than the pod spec - but they still pass through the Helm release, so
`s3.existingSecret` is the better choice in production.

## High availability

vfps keeps no durable state of its own outside PostgreSQL, so replicas are interchangeable. A
production deployment wants at least:

```yaml
replicaCount: 3

podDisruptionBudget:
  enabled: true

topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: ScheduleAnyway
    labelSelector:
      matchLabels:
        app.kubernetes.io/instance: vfps
        app.kubernetes.io/component: api

# the admin UI is Blazor Server and needs affinity - prefer cookie affinity on your ingress
service:
  sessionAffinity: ClientIP

# the bundled PostgreSQL is a single instance; point at an HA database instead
postgres:
  enabled: false
database:
  host: my-ha-postgres.example.com
  existingSecret: vfps-db
```

A few things are worth knowing beyond turning those on:

- **The admin UI needs session affinity; the APIs don't.** Each browser session is a Blazor Server
  circuit held in one replica's memory and can't be resumed on another. Cookie-based affinity at
  the ingress is better than `service.sessionAffinity=ClientIP`, which is coarse when clients share
  a NAT. Auth cookies and antiforgery tokens *are* portable across replicas, since vfps persists
  the ASP.NET Data Protection key ring to PostgreSQL.
- **gRPC clients pin to one replica.** A gRPC client opens a single long-lived HTTP/2 connection and
  a ClusterIP Service balances connections, not requests. Point clients at the headless Service with
  client-side load balancing - `dns:///vfps-headless:8081` plus a `round_robin` policy, as in the
  Usage example above - or terminate gRPC at a proxy that balances per request.
- **Size the connection pool for the replica count.** `Maximum Pool Size` in
  `database.additionalConnectionStringParameters` is per replica, so budget roughly
  `replicaCount x Maximum Pool Size` (plus CSV job workers) against your PostgreSQL's
  `max_connections`, and add PgBouncer if that doesn't fit.
- **Draining needs Kubernetes 1.30+.** `gracefulShutdown.preStopSleepSeconds` uses the native
  `sleep` preStop handler so that Service endpoint removal wins its race against shutdown. The vfps
  image is chiseled and has no shell, so there's no `exec` fallback - on older clusters the hook is
  skipped and the install notes say so. Keep the ordering
  `terminationGracePeriodSeconds` > `preStopSleepSeconds` + `shutdownTimeout`.
- **Migrations run while the previous version is still serving.** The migrations Job is applied
  alongside the Deployment update rather than as a pre-upgrade hook, which is what makes an upgrade
  non-disruptive - but it only works if each migration is backwards-compatible with the running
  version. Note also that a `CREATE INDEX CONCURRENTLY` which fails leaves an `INVALID` index that
  must be dropped by hand before the migration can be retried.
- **CSV jobs can be moved out of the API pods.** By default every replica processes jobs. Setting
  `worker.enabled: true` runs them in a separate Deployment instead and switches the API pods to
  accept-only (`CsvProcessing__ProcessJobs=false`) - enqueueing and the Hangfire dashboard keep
  working there, since neither needs a local job server. Worth doing once job load competes with
  API latency, or when you want jobs to drain slowly on shutdown while API pods roll quickly: a
  single Deployment can only have one `terminationGracePeriodSeconds` and one resource budget,
  which is why `worker.terminationGracePeriodSeconds` defaults to 600 against the API pods' 60.
  The workers need the same S3 and database configuration, so put anything shared in the top-level
  `extraEnv`/`extraEnvDict`/`extraEnvFrom` rather than under `worker.extraEnv`.
- **The bundled PostgreSQL is a single instance** with modest resource limits, intended for getting
  started. Any restart of it is a full outage, softened only by the application's connection retry
  budget. For real availability use an external HA PostgreSQL or an operator such as CloudNativePG.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | pod affinity |
| appsettings | string | `""` | a JSON configuration object which is mounted as `appsettings.Production.json` inside the container. useful to define namespaces to create as part of the application startup. |
| autoscaling.behavior | object | `{}` | scaling behavior, e.g. to stabilize scale-down and stop replica counts flapping. See <https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#configurable-scaling-behavior> |
| autoscaling.enabled | bool | `false` | enable horizontal pod autoscaling |
| autoscaling.maxReplicas | int | `5` | upper limit for the number of pods that can be set by the autoscaler; cannot be smaller than `minReplicas`. |
| autoscaling.minReplicas | int | `1` | minReplicas is the lower limit for the number of replicas to which the autoscaler can scale down. It defaults to 1 pod. minReplicas is allowed to be 0 if the alpha feature gate HPAScaleToZero is enabled and at least one Object or External metric is configured. Scaling is active as long as at least one metric value is available. |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | target average CPU utilization (represented as a percentage of requested CPU) over all the pods; if not specified the default autoscaling policy will be used. |
| database.additionalConnectionStringParameters | string | `"Timeout=60;Max Auto Prepare=5;Maximum Pool Size=50;"` | additional parameters appended to the connection string. `Maximum Pool Size` is set explicitly because Npgsql's own default (100) is **per replica**: scaling to 5 replicas would allow 500 connections against a PostgreSQL whose own `max_connections` commonly defaults to 100, and connection exhaustion looks like a total outage. Budget roughly `replicaCount * (Maximum Pool Size)` plus the CSV job workers, and raise both this and the server's `max_connections` together (or put PgBouncer in front). |
| database.database | string | `"vfps"` | name of the database inside. If postgres.enabled=true, then postgres.auth.database is used |
| database.existingSecret | string | `""` | name of an existing secret containing the password to the DB. |
| database.existingSecretKey | string | `"postgresql-postgres-password"` | name of the key in `database.existingSecret` to use as the password to the DB. |
| database.host | string | `"host.example.com"` | database hostname of an external database. Only used if `postgres.enabled` is set to `false`. |
| database.password | string | `"postgres"` | the database password. Only used if postgres.enabled=false, otherwise the secret created by the postgresql chart is used |
| database.port | int | `5432` | port used to connect to the postgres DB |
| database.schema | string | `""` | schema used for the tables. If empty, no `Search Path` is added to the connection string. |
| database.username | string | `"postgres"` | username used to connect to the DB. Note that this name is currently used even if postgres.enabled=true |
| deploymentAnnotations | object | `{}` | annotations to set on the main deployment itself |
| extraEnv | list | `[]` | extra environment variables to set on the vfps container |
| extraEnvDict | object | `{}` | extra environment variables as a `key:value` dictionary to set on the vfps container |
| extraEnvFrom | list | `[]` | extra `envFrom` sources for the vfps container, e.g. a Secret holding `Authorization__ClientSecret` or `S3__SecretKey`. Preferred over putting those in `extraEnv`, which stores them as plaintext in the Helm release. |
| extraVolumeMounts | list | `[]` | extra volumeMounts for the main container |
| extraVolumes | list | `[]` | extra volumes |
| fullnameOverride | string | `""` | override the full release name |
| gracefulShutdown.preStopSleepSeconds | int | `5` | seconds the pod keeps serving after `SIGTERM` before the application starts draining, so that Service endpoint removal wins its race against the shutdown. Set to `0` to disable the hook. **Requires Kubernetes 1.30+** - it uses the native `sleep` preStop handler, since the vfps runtime image is chiseled and has no shell for an `exec` handler. Silently skipped on older clusters (see the install notes). |
| gracefulShutdown.shutdownTimeout | string | `"0.00:00:25"` | value for the application's own `ShutdownTimeout` setting: how long it waits for in-flight requests, Blazor circuits and background work to finish before tearing down. Keep it below `terminationGracePeriodSeconds` minus `preStopSleepSeconds`. Set to `""` to leave the application default (25s) alone. |
| gracefulShutdown.terminationGracePeriodSeconds | int | `60` | how long Kubernetes waits after `SIGTERM` before `SIGKILL`. Must exceed `preStopSleepSeconds` plus `shutdownTimeout`, or the pod is killed mid-drain. |
| imagePullSecrets | list | `[]` | image pull secrets used by the main deployment container |
| ingress.annotations | object | `{}` | extra annotations to apply to the Ingress resource |
| ingress.className | string | `""` | ingressClassName to use |
| ingress.enabled | bool | `false` | create an Ingress for the application |
| ingress.hosts | list | `[{"host":"vfps.127.0.0.1.nip.io"}]` | list of ingress hosts. `paths` and its fields (`path`, `pathType`, `portName`) are optional per host and default to `path: /`, `pathType: ImplementationSpecific`, `portName: http` if unset. |
| ingress.tls | list | `[]` | TLS configuration |
| initContainers.resources | object | `{}` |  |
| initContainers.resourcesPreset | string | `"nano"` |  |
| migrationsJob.activeDeadlineSeconds | int | `0` | seconds before the migration job is force-terminated, so a migration blocked on a lock fails loudly instead of hanging an upgrade indefinitely. `0` (the default) means no limit, because a legitimate migration can run for a long time - a `CREATE INDEX CONCURRENTLY` over hundreds of millions of rows can outlast any deadline you'd want to set for the blocked-on-a-lock case. |
| migrationsJob.backoffLimit | int | `3` | how many times the migration job is retried before it's considered failed. More than one attempt matters because a transient failure (a database failover mid-migration) would otherwise fail the job permanently, and the main deployment's init container waits for that job forever. |
| migrationsJob.enabled | bool | `true` | whether to enable the database migration job. If enabled, a `ServiceAccount`, `Role`, and `RoleBinding` resources are created which are used by an init container of the main application to wait for the migrations to complete. |
| migrationsJob.extraEnv | list | `[]` | extra environment variables to set on the migrations job container |
| migrationsJob.resources | object | `{}` | configure the init containers pods resource requests and limits |
| migrationsJob.resourcesPreset | string | `"small"` | set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if primary.resources is set (primary.resources is recommended for production). More information: <https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15> |
| migrationsJob.restartPolicy | string | `"Never"` | restart policy for the migration job |
| migrationsJob.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| migrationsJob.serviceAccount.automountServiceAccountToken | bool | `false` | whether to automount the SA token |
| migrationsJob.serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| migrationsJob.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| migrationsJob.ttlSecondsAfterFinished | int | `-1` | seconds a finished migration job is kept before Kubernetes cleans it up. `-1` (the default) keeps it forever. **Setting a TTL is usually wrong here**: the main deployment's `wait-for-migrations-job` init container waits for this exact job by name, so once it has been cleaned up, any later pod restart or rescheduling on the same chart version blocks in init waiting for a job that no longer exists. |
| minReadySeconds | int | `10` | how long a new pod must stay ready before the rollout treats it as available and moves on. Guards against a pod that passes its readiness probe and then immediately falls over taking the rollout with it. |
| nameOverride | string | `""` | override the release name |
| nodeSelector | object | `{}` | pod node selector |
| podAnnotations | object | `{}` | annotations to set on the main deployment's pod |
| podDisruptionBudget.enabled | bool | `false` | create a PodDisruptionBudget resource. Only meaningful with `replicaCount` >= 2 - see `maxUnavailable` below. |
| podDisruptionBudget.maxUnavailable | int | `1` | Maximum unavailable instances; ignored if there is no PodDisruptionBudget, or if `minAvailable` is set. `1` keeps a drain possible at any replica count while still preventing all replicas going down at once. |
| podDisruptionBudget.minAvailable | string | `""` | Minimum available instances; ignored if there is no PodDisruptionBudget. Left empty by default in favour of `maxUnavailable`: the previous default of `minAvailable: 1` combined with a single replica is unsatisfiable, so no voluntary eviction could ever succeed and a node drain would hang forever. **Takes precedence over `maxUnavailable` when both are set**, since Kubernetes permits only one. |
| podSecurityContext | object | `{}` | the pod security context |
| postgres.auth.database | string | `"vfps"` | name of the database to create |
| postgres.auth.enablePostgresUser | bool | `false` | disable the default postgres user |
| postgres.auth.username | string | `"vfps_admin"` | username for the database user |
| postgres.enabled | bool | `true` | enabled the included Postgres DB see <https://github.com/CloudPirates-io/helm-charts/tree/main/charts/postgres> for configuration options |
| priorityClassName | string | `""` | priorityClassName for the pods. Worth setting for a service other workloads call synchronously, so it isn't the first thing evicted under node pressure. |
| replicaCount | int | `1` | number of replicas. Two or more (together with `podDisruptionBudget.enabled`, and ideally `topologySpreadConstraints`) is what makes a rolling upgrade or a node drain non-disruptive - a single replica means every restart is a gap in service. |
| resources | object | `{}` | configure the resources used by the log collector sidecar container used to tail the filesystem-stored log files |
| resourcesPreset | string | `"medium"` |  |
| s3.accessKey | string | `""` | access key for the bucket. Ignored when `existingSecret` is set. Stored in a chart-created Secret rather than inline in the pod spec, but still passes through the Helm release - prefer `existingSecret` in production. |
| s3.allowedOrigins | list | `[]` | origins allowed to PUT/GET objects directly against the bucket via presigned URLs, applied as a bucket CORS rule on startup. The browser talks to the bucket on a different origin than vfps itself, so without the admin UI's own origin here (e.g. `https://vfps.example.org`, the host from `ingress.hosts`) the browser blocks uploads with a CORS error. |
| s3.bucket | string | `""` | bucket CSV job input/output files are stored in. Use a bucket dedicated to vfps: the application replaces the bucket's entire lifecycle and CORS configuration on startup. |
| s3.enabled | bool | `false` | enable CSV pseudonymization jobs, which store their input and output files in S3-compatible object storage. Also requires a database (Hangfire reuses the same one for its job storage). When this is off, the CSV jobs feature is disabled entirely and the admin UI hides it. |
| s3.existingSecret | string | `""` | name of an existing secret holding the S3 credentials. Takes precedence over `accessKey` and `secretKey`. |
| s3.existingSecretAccessKeyKey | string | `"accessKey"` | key in `existingSecret` holding the access key |
| s3.existingSecretSecretKeyKey | string | `"secretKey"` | key in `existingSecret` holding the secret key |
| s3.forcePathStyle | bool | `true` | path-style addressing (`https://host/bucket/key`) rather than virtual-hosted-style. Required for MinIO and most non-AWS S3-compatible stores. |
| s3.objectRetentionDays | int | `30` | days before a lifecycle rule expires a job's input/output objects. Job records themselves are never deleted, so without this the original, unpseudonymized input would live in the bucket forever. Set to `0` to leave the bucket's lifecycle configuration untouched. |
| s3.presignedUrlExpiry | string | `"0.00:15:00"` | how long presigned upload/download URLs remain valid |
| s3.region | string | `"eu-central-1"` | region passed to the S3 client. Not cosmetic even against a non-AWS endpoint - it forms part of the SigV4 credential scope embedded in every signed request and presigned URL. |
| s3.secretKey | string | `""` | secret key for the bucket. Ignored when `existingSecret` is set. |
| s3.serviceUrl | string | `""` | S3-compatible endpoint URL, e.g. a MinIO instance or a real AWS/S3-compatible endpoint |
| service.grpcPort | int | `8081` | the port which supports HTTP2 only, to accept plaintext gRPC calls |
| service.metricsPort | int | `8082` | the port exposed on the service to access metrics on `/metrics` |
| service.port | int | `8080` | the port for the main endpoint which supports HTTP1, HTTP2, and HTTP3 |
| service.sessionAffinity | string | `"None"` | session affinity for the Service. The admin UI is Blazor Server: each browser session is a SignalR circuit living in one replica's memory and cannot be resumed on another, so with more than one replica the UI needs affinity. Prefer cookie-based affinity at the ingress where the controller supports it (see `ingress.annotations`) - `ClientIP` here is the fallback, and is coarse when clients arrive behind a shared NAT. The gRPC and REST APIs are stateless and need none of this. |
| service.sessionAffinityConfig | object | `{}` | configuration for `service.sessionAffinity`, e.g. `clientIP.timeoutSeconds` |
| service.type | string | `"ClusterIP"` | the type of service |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automountServiceAccountToken | bool | `true` | whether to automount the SA token. required if migrations are enabled. |
| serviceAccount.create | bool | `false` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| serviceMonitor.additionalLabels | object | `{}` | additional labels to apply to the ServiceMonitor object, e.g. `release: prometheus` |
| serviceMonitor.enabled | bool | `false` | if enabled, creates a ServiceMonitor instance for Prometheus Operator-based monitoring |
| tests.automountServiceAccountToken | bool | `false` |  |
| tests.resources | object | `{}` |  |
| tests.resourcesPreset | string | `"nano"` |  |
| tolerations | list | `[]` | pod tolerations |
| topologySpreadConstraints | list | `[]` | pod topology spread configuration see: <https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#api> |
| updateStrategy | object | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` | deployment update strategy. The default surges a new pod before removing an old one (`maxUnavailable: 0`), so capacity never dips below `replicaCount` during an upgrade. |
| worker.affinity | object | `{}` | worker affinity |
| worker.enabled | bool | `false` | run CSV pseudonymization jobs in a dedicated Deployment instead of in the API pods. Only meaningful when CSV jobs are enabled at all (`S3__IsEnabled=true`, set via `extraEnv`), which this chart cannot verify for you.  Worth turning on once job load starts competing with API latency, or when you want jobs to drain slowly on shutdown while API pods roll quickly - a single Deployment can only have one shutdown window and one resource budget. When enabled, the API pods are automatically switched to accept-only (`CsvProcessing__ProcessJobs=false`); enqueueing and the Hangfire dashboard keep working there, since neither needs a local job server. |
| worker.extraEnv | list | `[]` | extra environment variables for the worker container, appended after the shared `extraEnv`. The workers need the same S3 and database configuration as the API pods, so put anything shared in the top-level `extraEnv`/`extraEnvDict`/`extraEnvFrom` rather than here. |
| worker.nodeSelector | object | `{}` | worker node selector |
| worker.podAnnotations | object | `{}` | annotations to set on the worker pods |
| worker.podDisruptionBudget.enabled | bool | `false` | create a PodDisruptionBudget for the workers |
| worker.podDisruptionBudget.maxUnavailable | int | `1` | Maximum unavailable worker instances |
| worker.podDisruptionBudget.minAvailable | string | `""` | Minimum available worker instances; takes precedence over `maxUnavailable` when set |
| worker.priorityClassName | string | `""` | priorityClassName for the worker pods |
| worker.replicaCount | int | `1` | number of worker replicas. Hangfire coordinates through the database, so replicas pick up jobs independently with no further configuration. |
| worker.resources | object | `{}` | configure the worker container's resource requests and limits |
| worker.resourcesPreset | string | `"medium"` |  |
| worker.terminationGracePeriodSeconds | int | `600` | how long Kubernetes waits after `SIGTERM` before `SIGKILL`. Deliberately much longer than the API pods': a CSV job that is cut short has to be re-dispatched and reprocessed, so it is worth waiting for one to finish. Keep it above `CsvProcessing__JobServerShutdownTimeout`. |
| worker.tolerations | list | `[]` | worker tolerations |
| worker.topologySpreadConstraints | list | `[]` | worker pod topology spread configuration |
| worker.updateStrategy | object | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` | update strategy for the worker Deployment. `maxUnavailable: 0` avoids taking job capacity down to nothing mid-rollout. |
