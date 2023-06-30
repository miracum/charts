# fhir-gateway

[FHIR Gateway](https://github.com/miracum/fhir-gateway) - Helm chart for deploying the MIRACUM FHIR Gateway on Kubernetes.

## TL;DR;

```console
$ helm repo add miracum https://miracum.github.io/charts
$ helm repo update
$ helm install fhir-gateway miracum/fhir-gateway -n fhir-gateway
```

## Breaking changes

### v2 to v3

Version 3 of the chart upgrades the fhir-pseudonymizer component to v2. It's breaking changes require version 1.10 of gPAS, in particular it depends
on the new gPAS TTP FHIR GW interface. The value `gpas.wsdlUrl` has been renamed to `gpas.fhirUrl` to reflect this change.

## Introduction

This chart deploys the MIRACUM FHIR Gateway on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes v1.16+
- Helm v3

## Installing the Chart

To install the chart with the release name `fhir-gateway`:

```console
$ helm install fhir-gateway miracum/fhir-gateway -n fhir-gateway
```

The command deploys the MIRACUM FHIR Gateway on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `fhir-gateway`:

```console
$ helm delete fhir-gateway -n fhir-gateway
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the `fhir-gateway` chart and their default values.

| Parameter                                              | Description                                                                                                                                                                                                                                       | Default                                                          |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| common.deploymentAnnotations                           | metadata.annotations to apply to all deployments                                                                                                                                                                                                  | <code>{}</code>                                                  |
| tracing.enabled                                        | enables tracing for all supported components by default, the components export traces in Jaeger format to `localhost:16686`                                                                                                                       | <code>false</code>                                               |
| replicaCount                                           | number of replicas. The application is well-suited to scale horizontally if required.                                                                                                                                                             | <code>1</code>                                                   |
| imagePullSecrets                                       | image pull secrets for the pod                                                                                                                                                                                                                    | <code>[]</code>                                                  |
| nameOverride                                           | String to partially override fullname template (will maintain the release name)                                                                                                                                                                   | <code>""</code>                                                  |
| fullnameOverride                                       | String to fully override fullname template                                                                                                                                                                                                        | <code>""</code>                                                  |
| podAnnotations                                         | annotations to apply to the pod                                                                                                                                                                                                                   | <code>{}</code>                                                  |
| podSecurityContext                                     | pod security context                                                                                                                                                                                                                              | <code>{}</code>                                                  |
| service                                                | the service used to expose the FHIR GW REST endpoint                                                                                                                                                                                              | <code>{"metricsPort":8081,"port":8080,"type":"ClusterIP"}</code> |
| ingress.enabled                                        | if enabled, create an Ingress to expose the FHIR Gateway outside the cluster                                                                                                                                                                      | <code>false</code>                                               |
| ingress.annotations                                    | ingress annotations                                                                                                                                                                                                                               | <code>{}</code>                                                  |
| ingress.ingressClassName                               | kubernetes.io/ingress.class: nginx kubernetes.io/tls-acme: "true" ingressClassName field                                                                                                                                                          | <code>""</code>                                                  |
| ingress.tls                                            | TLS config                                                                                                                                                                                                                                        | <code>[]</code>                                                  |
| resources                                              |                                                                                                                                                                                                                                                   | <code>{}</code>                                                  |
| nodeSelector                                           | node labels for pods assignment see: <<https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/>>                                                                                                                                 | <code>{}</code>                                                  |
| tolerations                                            | tolerations for pods assignment see: <https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/>                                                                                                                                    | <code>[]</code>                                                  |
| affinity                                               | affinity for pods assignment see: <https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity>                                                                                                                 | <code>{}</code>                                                  |
| extraEnv                                               | extra environment vars to set on the FHIR gateway container                                                                                                                                                                                       | <code>[]</code>                                                  |
| metrics.serviceMonitor.enabled                         | if enabled, creates a ServiceMonitor instance for Prometheus Operator-based monitoring                                                                                                                                                            | <code>false</code>                                               |
| metrics.serviceMonitor.additionalLabels                | additional labels for the ServiceMonitor resource, e.g. `release: prometheus`                                                                                                                                                                     | <code>{}</code>                                                  |
| sinks.postgres.enabled                                 | if enabled, writes all received FHIR resources to a Postgres DB if `postgresql.enabled=true`, then a Postgres DB is started as part of this installation. If `postgresql.enabled=false`, then `sinks.postgres.external.*` is used.                | <code>true</code>                                                |
| sinks.postgres.external.host                           | host or server name                                                                                                                                                                                                                               | <code>""</code>                                                  |
| sinks.postgres.external.port                           | port                                                                                                                                                                                                                                              | <code>"5432"</code>                                              |
| sinks.postgres.external.database                       | name of the database to connect to                                                                                                                                                                                                                | <code>""</code>                                                  |
| sinks.postgres.external.username                       | username to authenticate as                                                                                                                                                                                                                       | <code>""</code>                                                  |
| sinks.postgres.external.password                       | password for the user                                                                                                                                                                                                                             | <code>""</code>                                                  |
| sinks.postgres.external.existingSecret                 | can be used to specify the name of an existing secret containing the PostgreSQL password. An alternative to setting the password above.                                                                                                           | <code>""</code>                                                  |
| sinks.postgres.external.existingSecretKey              | the key inside the `existingSecret` containing the password.                                                                                                                                                                                      | <code>"postgresql-password"</code>                               |
| sinks.fhirServer.enabled                               | if enabled, sends all received resources to the specified FHIR server                                                                                                                                                                             | <code>false</code>                                               |
| sinks.fhirServer.url                                   | URL of the FHIR server. Support for authentication is not implemented.                                                                                                                                                                            | <code>""</code>                                                  |
| kafka.enabled                                          | if enabled, the FHIR Gateway will read resources from the specified Kafka topic `inputTopic` and write them to `outputTopic`. Requires the Kafka cluster to be configured using <https://strimzi.io/>.                                            | <code>false</code>                                               |
| kafka.groupId                                          | the Kafka consumer group id. Evaluated as a template.                                                                                                                                                                                             | <code>'{{ include "fhir-gateway.fullname" . }}-gateway'</code>   |
| kafka.inputTopic                                       | name of the Kafka topic to read resources from DEPRECATED: use `kafka.inputTopics` (note the s) instead.                                                                                                                                          | <code>fhir-raw</code>                                            |
| kafka.outputTopic                                      | name of the topic to write processed resources to                                                                                                                                                                                                 | <code>fhir.post-gatway</code>                                    |
| kafka.securityProtocol                                 | either PLAINTEXT or SSL                                                                                                                                                                                                                           | <code>PLAINTEXT</code>                                           |
| kafka.strimziClusterName                               | name of the Strimzi Kafka CRD this gateway should connect to. This is used to resolve the Kafka bootstrap service.                                                                                                                                | <code>"my-cluster"</code>                                        |
| postgresql.enabled                                     | enabled the included Postgres DB see <https://github.com/bitnami/charts/tree/master/bitnami/postgresql> for configuration options                                                                                                                 | <code>true</code>                                                |
| postgresql.auth.database                               | name of the database to create see: <https://github.com/bitnami/containers/tree/main/bitnami/postgresql#creating-a-database-on-first-run>                                                                                                         | <code>"fhir_gateway"</code>                                      |
| postgresql.auth.enablePostgresUser                     | Assign a password to the "postgres" admin user. Otherwise, remote access will be blocked for this user                                                                                                                                            | <code>true</code>                                                |
| loincConverter.enabled                                 | whether to enable the LOINC conversion and harmonization service                                                                                                                                                                                  | <code>true</code>                                                |
| loincConverter.metrics.serviceMonitor.enabled          | if enabled, creates a ServiceMonitor instance for Prometheus Operator-based monitoring                                                                                                                                                            | <code>false</code>                                               |
| loincConverter.metrics.serviceMonitor.additionalLabels | additional labels for the ServiceMonitor resource, e.g. `release: prometheus`                                                                                                                                                                     | <code>{}</code>                                                  |
| loincConverter.replicaCount                            | if necessary, the service can easily scale horizontally                                                                                                                                                                                           | <code>1</code>                                                   |
| loincConverter.imagePullSecrets                        | credentials to use when pulling the image                                                                                                                                                                                                         | <code>[]</code>                                                  |
| loincConverter.podAnnotations                          | annotations for the pod                                                                                                                                                                                                                           | <code>{}</code>                                                  |
| loincConverter.podSecurityContext                      | the pod security context                                                                                                                                                                                                                          | <code>{}</code>                                                  |
| loincConverter.service                                 | service to expose the application                                                                                                                                                                                                                 | <code>{"port":8080,"type":"ClusterIP"}</code>                    |
| loincConverter.resources                               | resource limits and requests                                                                                                                                                                                                                      | <code>{}</code>                                                  |
| loincConverter.nodeSelector                            | node labels for pods assignment see: <<https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/>>                                                                                                                                 | <code>{}</code>                                                  |
| loincConverter.tolerations                             | tolerations for pods assignment see: <https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/>                                                                                                                                    | <code>[]</code>                                                  |
| loincConverter.affinity                                | affinity for pods assignment see: <https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity>                                                                                                                 | <code>{}</code>                                                  |
| loincConverter.extraEnv                                | extra environment variables to set on the                                                                                                                                                                                                         | <code>[]</code>                                                  |
| fhir-pseudonymizer.enabled                             | whether to enable the FHIR Pseudonymizer - a thin, FHIR-native wrapper on top of gPAS an Vfps with additional options for anonymization. if this is set to false, then the FHIR gateway will not attempt to pseudonymize/anonymize the resources. | <code>true</code>                                                |
| fhir-pseudonymizer.vfps.nameOverride                   |                                                                                                                                                                                                                                                   | <code>gateway-vfps</code>                                        |
| fhir-pseudonymizer.vfps.postgresql.nameOverride        | overrides the chart's postgres server name to avoid conflicts with the fhir-gateway's postgresql                                                                                                                                                  | <code>"vfps-postgres"</code>                                     |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```console
$ helm install fhir-gateway miracum/fhir-gateway -n fhir-gateway --set replicaCount=1
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while
installing the chart. For example:

```console
$ helm install fhir-gateway miracum/fhir-gateway -n fhir-gateway --values values.yaml
```
