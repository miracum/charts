# s3manager

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A Helm chart for deploying S3 Manager, a web GUI to manage S3 buckets from any provider.

**Homepage:** <https://github.com/cloudlena/s3manager>

## Installation

```sh
helm install s3manager oci://ghcr.io/miracum/charts/s3manager -n s3manager --create-namespace -f values.yaml
```

At least one S3 instance has to be configured, e.g. a MinIO instance using credentials from an existing secret:

```yaml
instances:
  - name: minio
    endpoint: minio.minio.svc:9000
    useSSL: false
    existingSecret:
      name: minio-s3manager-credentials
      accessKeyIdKey: ACCESS_KEY_ID
      secretAccessKeyKey: SECRET_ACCESS_KEY
```

### Buckets created via an ObjectBucketClaim (Rook Ceph)

Buckets provisioned via an [ObjectBucketClaim](https://rook.io/docs/rook/latest/Storage-Configuration/Object-Storage-RGW/ceph-object-bucket-claim/)
come with a ConfigMap (`BUCKET_HOST`, `BUCKET_PORT`, `BUCKET_NAME`, `BUCKET_REGION`) and a Secret (`AWS_ACCESS_KEY_ID`,
`AWS_SECRET_ACCESS_KEY`) named after the claim. Reference the claim and the chart reads the endpoint, bucket, region and
credentials from them:

```yaml
instances:
  - objectBucketClaim:
      name: my-bucket
  - name: other-bucket # defaults to the claim's name
    objectBucketClaim:
      name: other-bucket-claim
```

The claims have to be in the release namespace. The endpoint is assumed to serve plain HTTP, as the in-cluster Rook
RGW service does. Set `useSSL: true` on the instance otherwise.

If the NetworkPolicy is enabled, allow egress to the RGW pods. Note that NetworkPolicies match the pod's port, not the
Service's (Rook's default RGW pod port is `8080`):

```yaml
networkPolicy:
  enabled: true
  extraEgress:
    - ports:
        - port: 8080
      to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: rook-ceph
          podSelector:
            matchLabels:
              app: rook-ceph-rgw
```

> [!WARNING]
> S3 Manager has no built-in authentication: everyone who can reach it can use all configured S3 instances.
> Restrict access, e.g. by putting an authenticating reverse proxy (OAuth2 Proxy, basic auth, ...) in front of the Ingress,
> or by enabling the NetworkPolicy (`networkPolicy.enabled=true`, `networkPolicy.allowExternal=false`).
> To give different teams access to different S3 accounts, install one release per team.

When `networkPolicy.enabled=true`, egress is limited to DNS by default. Allow access to the S3 endpoints via
`networkPolicy.extraEgress` or set `networkPolicy.allowExternalEgress=true`.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | pod affinity |
| allowDelete | bool | `true` | enable deleting objects, folders and empty buckets. Sets the `ALLOW_DELETE` environment variable. |
| bucketNames | list | `[]` | only show these buckets in the bucket list of every instance. This only filters the list and is not an access restriction. Sets the `BUCKET_NAME` environment variable. |
| commonAnnotations | object | `{}` | annotations to apply to all created resources. Evaluated as a template. |
| envDict | object | `{}` | extra environment variables to set on the container in dictionary form |
| extraEnv | list | `[]` | extra environment variables to set on the container. Evaluated as a template. |
| extraEnvFrom | list | `[]` | extra sources of environment variables, e.g. a secret containing additional `S3_<n>_*` settings. |
| extraVolumeMounts | list | `[]` | extra volume mounts to add to the container |
| extraVolumes | list | `[]` | extra volumes to add to the pod |
| fullnameOverride | string | `""` | override the full release name |
| imagePullSecrets | list | `[]` | image pull secrets used by the pod |
| ingress.annotations | object | `{}` | extra annotations to apply to the Ingress resource |
| ingress.className | string | `""` | ingressClassName to use |
| ingress.enabled | bool | `false` | create an Ingress for the web UI. ⚠️ S3 Manager has no authentication: everyone who can reach it can use all configured S3 instances. Protect it at the ingress controller, e.g. via an OAuth2 proxy or basic auth. |
| ingress.hosts | list | `[{"host":"s3manager.127.0.0.1.nip.io","paths":[{"path":"/","pathType":"Prefix","portName":"http"}]}]` | list of ingress hosts |
| ingress.tls | list | `[]` | TLS configuration |
| instances | list | `[]` | the S3 instances (accounts) to manage. At least one is required. Each is shown under its `name` and reachable under `/<name>/buckets`, so pick names that work in a URL. Rendered as the numbered `S3_<n>_*` environment variables. See <https://github.com/cloudlena/s3manager#s3-instances> for details on each setting. |
| listRecursive | bool | `false` | list all objects in buckets recursively. Sets the `LIST_RECURSIVE` environment variable. |
| nameOverride | string | `""` | override the chart name |
| networkPolicy.allowExternal | bool | `true` | When set to false, only pods with the `<fullname>-client: "true"` label will have network access to the web UI port. When true, the web UI will accept connections from any source (with the correct destination port). |
| networkPolicy.allowExternalEgress | bool | `false` | Allow the pod to access any range of port and all destinations. If false, add rules allowing access to the configured S3 endpoints via `networkPolicy.extraEgress`. |
| networkPolicy.enabled | bool | `false` | Enable creation of NetworkPolicy resources |
| networkPolicy.extraEgress | list | `[]` | Add extra egress rules to the NetworkPolicy. Evaluated as a template. |
| networkPolicy.extraIngress | list | `[]` | Add extra ingress rules to the NetworkPolicy. Evaluated as a template. |
| networkPolicy.ingressNSMatchLabels | object | `{}` | Labels to match to allow traffic from other namespaces |
| networkPolicy.ingressNSPodMatchLabels | object | `{}` | Pod labels to match to allow traffic from other namespaces |
| nodeSelector | object | `{}` | pod node selector |
| podAnnotations | object | `{}` | annotations to set on the pod |
| podDisruptionBudget.enabled | bool | `false` | create a PodDisruptionBudget. Only useful when running more than one replica. |
| podDisruptionBudget.maxUnavailable | int | `1` | maximum number of pods that can be unavailable |
| podDisruptionBudget.minAvailable | string | `""` | minimum number of pods that must remain available. Takes precedence over `maxUnavailable` if set. |
| podLabels | object | `{}` | extra labels to set on the pod |
| podSecurityContext | object | `{"fsGroup":65532,"fsGroupChangePolicy":"OnRootMismatch","runAsGroup":65532,"runAsNonRoot":true,"runAsUser":65532,"seccompProfile":{"type":"RuntimeDefault"}}` | the pod security context. The image's own `s3manager` user doesn't have a fixed UID, so the chart runs it as an arbitrary unprivileged user instead. |
| replicaCount | int | `1` | number of replicas. S3 Manager is stateless, so it can run with multiple replicas. |
| resources | object | `{}` | configure the resource requests and limits |
| resourcesPreset | string | `"small"` | set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if `resources` is set (`resources` is recommended for production). More information: <https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15> |
| rootUrl | string | `""` | a root URL path prefix when served behind a reverse proxy under a sub-path that strips the prefix, e.g. `teamx`. Sets the `ROOT_URL` environment variable. |
| serverSideEncryption.existingSecret.key | string | `"SSE_KEY"` | key inside the secret containing the encryption key |
| serverSideEncryption.existingSecret.name | string | `""` | name of an existing secret containing the key for `KMS` (a key ID) or `SSE-C` (exactly 32 bytes). Sets the `SSE_KEY` environment variable. |
| serverSideEncryption.type | string | `""` | the server side encryption applied to uploaded objects: `SSE`, `KMS`, or `SSE-C`. Sets the `SSE_TYPE` environment variable. Disabled if empty. |
| service.port | int | `8080` | the port for the main HTTP endpoint |
| service.type | string | `"ClusterIP"` | the type of service |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account, e.g. to use IAM roles for service accounts (IRSA) together with `instances[].useIam`. |
| serviceAccount.automountServiceAccountToken | bool | `false` | whether to automount the SA token. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| showMetadata | bool | `true` | show the object metadata action. Sets the `SHOW_METADATA` environment variable. |
| showVersions | bool | `false` | show all object versions in the bucket view (the bucket must have versioning enabled). Sets the `SHOW_VERSIONS` environment variable. |
| tests.automountServiceAccountToken | bool | `false` | whether to automount the SA token in the test pods |
| tests.resources | object | `{}` | configure the test pods resource requests and limits |
| tests.resourcesPreset | string | `"nano"` | set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if `tests.resources` is set. More information: <https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15> |
| timeout | int | `600` | the read and write timeout in seconds. Sets the `TIMEOUT` environment variable. |
| timezone | string | `""` | IANA timezone used to display the object Last Modified times, e.g. `Europe/Berlin`. Sets the `TZ` environment variable. Defaults to UTC. |
| tmpVolumeSizeLimit | string | `""` | the size limit of the `/tmp` volume. Large uploads are buffered there before being sent to S3. |
| tolerations | list | `[]` | pod tolerations |
| topologySpreadConstraints | list | `[]` | pod topology spread configuration see: <https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#api> |
