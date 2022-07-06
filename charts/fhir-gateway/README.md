# fhir-gateway

[FHIR Gateway](https://gitlab.miracum.org/miracum/etl/fhir-gateway) - Helm chart for deploying the MIRACUM FHIR Gateway on Kubernetes.

## TL;DR;

```console
$ helm repo add miracum https://miracum.github.io/charts
$ helm repo update
$ helm install fhir-gateway miracum/fhir-gateway -n fhir-gateway --version=3.5.9
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
$ helm install fhir-gateway miracum/fhir-gateway -n fhir-gateway --version=3.5.9
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

| Parameter                                                    | Description                                                                                                                                                                                                                                                                      | Default                                       |
| ------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| common.deploymentAnnotations                                 | metadata.annotations to apply to all deployments                                                                                                                                                                                                                                 | <code>{}</code>                               |
| tracing.enabled                                              | enables tracing for all supported components by default, the components export traces in Jaeger format to `localhost:16686`                                                                                                                                                      | <code>false</code>                            |
| replicaCount                                                 | number of replicas. The application is well-suited to scale horizontally if required.                                                                                                                                                                                            | <code>1</code>                                |
| imagePullSecrets                                             | image pull secrets for the pod                                                                                                                                                                                                                                                   | <code>[]</code>                               |
| nameOverride                                                 | String to partially override fullname template (will maintain the release name)                                                                                                                                                                                                  | <code>""</code>                               |
| fullnameOverride                                             | String to fully override fullname template                                                                                                                                                                                                                                       | <code>""</code>                               |
| podAnnotations                                               | annotations to apply to the pod                                                                                                                                                                                                                                                  | <code>{}</code>                               |
| podSecurityContext                                           | pod security context                                                                                                                                                                                                                                                             | <code>{}</code>                               |
| service                                                      | the service used to expose the FHIR GW REST endpoint                                                                                                                                                                                                                             | <code>{"port":8080,"type":"ClusterIP"}</code> |
| ingress.enabled                                              | if enabled, create an Ingress to expose the FHIR Gateway outside the cluster                                                                                                                                                                                                     | <code>false</code>                            |
| ingress.annotations                                          | ingress annotations                                                                                                                                                                                                                                                              | <code>{}</code>                               |
| ingress.tls                                                  | TLS config                                                                                                                                                                                                                                                                       | <code>[]</code>                               |
| resources                                                    |                                                                                                                                                                                                                                                                                  | <code>{}</code>                               |
| nodeSelector                                                 | node labels for pods assignment see: <https://kubernetes.io/docs/user-guide/node-selection/>                                                                                                                                                                                     | <code>{}</code>                               |
| tolerations                                                  | tolerations for pods assignment see: <https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/>                                                                                                                                                                   | <code>[]</code>                               |
| affinity                                                     | affinity for pods assignment see: <https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity>                                                                                                                                                | <code>{}</code>                               |
| extraEnv                                                     | extra environment vars to set on the FHIR gateway container                                                                                                                                                                                                                      | <code>[]</code>                               |
| metrics.serviceMonitor.enabled                               | if enabled, creates a ServiceMonitor instance for Prometheus Operator-based monitoring                                                                                                                                                                                           | <code>false</code>                            |
| metrics.serviceMonitor.additionalLabels                      | additional labels for the ServiceMonitor resource, e.g. `release: prometheus`                                                                                                                                                                                                    | <code>{}</code>                               |
| sinks.postgres.enabled                                       | if enabled, writes all received FHIR resources to a Postgres DB if `postgresql.enabled=true`, then a Postgres DB is started as part of this installation. If `postgresql.enabled=false`, then `sinks.postgres.external.*` is used.                                               | <code>true</code>                             |
| sinks.postgres.external.host                                 | host or server name                                                                                                                                                                                                                                                              | <code>""</code>                               |
| sinks.postgres.external.port                                 | port                                                                                                                                                                                                                                                                             | <code>"5432"</code>                           |
| sinks.postgres.external.database                             | name of the database to connect to                                                                                                                                                                                                                                               | <code>""</code>                               |
| sinks.postgres.external.username                             | username to authenticate as                                                                                                                                                                                                                                                      | <code>""</code>                               |
| sinks.postgres.external.password                             | password for the user                                                                                                                                                                                                                                                            | <code>""</code>                               |
| sinks.postgres.external.existingSecret                       | can be used to specify the name of an existing secret with a `postgresql-password` key containing the password. An alternative to setting the password above.                                                                                                                    | <code>""</code>                               |
| sinks.fhirServer.enabled                                     | if enabled, sends all received resources to the specified FHIR server                                                                                                                                                                                                            | <code>false</code>                            |
| sinks.fhirServer.url                                         | URL of the FHIR server. Support for authentication is not implemented.                                                                                                                                                                                                           | <code>""</code>                               |
| kafka.enabled                                                | if enabled, the FHIR Gateway will read resources from the specified Kafka topic `inputTopic` and write them to `outputTopic`. Requires the Kafka cluster to be configured using <https://strimzi.io/>.                                                                           | <code>false</code>                            |
| kafka.inputTopic                                             | name of the Kafka topic to read resources from DEPRECATED: use `kafka.inputTopics` (note the s) instead.                                                                                                                                                                         | <code>fhir-raw</code>                         |
| kafka.outputTopic                                            | name of the topic to write processed resources to                                                                                                                                                                                                                                | <code>fhir.post-gatway</code>                 |
| kafka.securityProtocol                                       | either PLAINTEXT or SSL                                                                                                                                                                                                                                                          | <code>PLAINTEXT</code>                        |
| kafka.strimziClusterName                                     | name of the Strimzi Kafka CRD this gateway should connect to. This is used to resolve the Kafka bootstrap service.                                                                                                                                                               | <code>"my-cluster"</code>                     |
| postgresql.enabled                                           | enabled the included Postgres DB see <https://github.com/bitnami/charts/tree/master/bitnami/postgresql> for configuration options                                                                                                                                                | <code>true</code>                             |
| postgresql.postgresqlDatabase                                | name of the database used by the FHIR gateway to store the resources                                                                                                                                                                                                             | <code>"fhir_gateway"</code>                   |
| postgresql.replication.enabled                               | enable replication for data resilience                                                                                                                                                                                                                                           | <code>true</code>                             |
| postgresql.replication.readReplicas                          | number of read (slave) replicas                                                                                                                                                                                                                                                  | <code>2</code>                                |
| postgresql.replication.synchronousCommit                     | enable synchronous commit - this may degrade performance in favor of resiliency                                                                                                                                                                                                  | <code>"on"</code>                             |
| postgresql.replication.numSynchronousReplicas                | from the number of `readReplicas` defined above, set the number of those that will have synchronous replication NOTE: It cannot be > readReplicas                                                                                                                                | <code>1</code>                                |
| postgresql.image.tag                                         | use a more recent Postgres version than the default                                                                                                                                                                                                                              | <code>13.1.0</code>                           |
| postgresql.image.pullPolicy                                  |                                                                                                                                                                                                                                                                                  | <code>IfNotPresent</code>                     |
| postgresql.containerSecurityContext.allowPrivilegeEscalation |                                                                                                                                                                                                                                                                                  | <code>false</code>                            |
| gpas.fhirUrl                                                 | the gPAS TTP FHIR Gateway base URL used to be used by the pseudonymization service. it should look similar to this: `http://gpas:8080/ttp-fhir/fhir/`                                                                                                                            | <code>""</code>                               |
| gpas.version                                                 | Version of gPAS used. There were breaking changes to the FHIR API starting in 1.10.2, so explicitely set this value to 1.10.2 if `gpas.fhirUrl` points to gPAS 1.10.2.                                                                                                           | <code>"1.10.1"</code>                         |
| gpas.auth.basic.enabled                                      | whether the fhir-pseudonymizer needs to provide basic auth credentials to access the gPAS FHIR API                                                                                                                                                                               | <code>false</code>                            |
| gpas.auth.basic.username                                     | HTTP basic auth username                                                                                                                                                                                                                                                         | <code>""</code>                               |
| gpas.auth.basic.password                                     | HTTP basic auth password                                                                                                                                                                                                                                                         | <code>""</code>                               |
| gpas.auth.basic.existingSecret                               | read the password from an existing secret from the `GPAS__AUTH__BASIC__PASSWORD` key                                                                                                                                                                                             | <code>""</code>                               |
| loincConverter.enabled                                       | whether to enable the LOINC conversion and harmonization service                                                                                                                                                                                                                 | <code>true</code>                             |
| loincConverter.metrics.serviceMonitor.enabled                | if enabled, creates a ServiceMonitor instance for Prometheus Operator-based monitoring                                                                                                                                                                                           | <code>false</code>                            |
| loincConverter.metrics.serviceMonitor.additionalLabels       | additional labels for the ServiceMonitor resource, e.g. `release: prometheus`                                                                                                                                                                                                    | <code>{}</code>                               |
| loincConverter.replicaCount                                  | if necessary, the service can easily scale horizontally                                                                                                                                                                                                                          | <code>1</code>                                |
| loincConverter.imagePullSecrets                              | credentials to use when pulling the image                                                                                                                                                                                                                                        | <code>[]</code>                               |
| loincConverter.podAnnotations                                | annotations for the pod                                                                                                                                                                                                                                                          | <code>{}</code>                               |
| loincConverter.podSecurityContext                            | the pod security context                                                                                                                                                                                                                                                         | <code>{}</code>                               |
| loincConverter.service                                       | service to expose the application                                                                                                                                                                                                                                                | <code>{"port":8080,"type":"ClusterIP"}</code> |
| loincConverter.resources                                     | resource limits and requests                                                                                                                                                                                                                                                     | <code>{}</code>                               |
| loincConverter.nodeSelector                                  | node labels for pods assignment see: <https://kubernetes.io/docs/user-guide/node-selection/>                                                                                                                                                                                     | <code>{}</code>                               |
| loincConverter.tolerations                                   | tolerations for pods assignment see: <https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/>                                                                                                                                                                   | <code>[]</code>                               |
| loincConverter.affinity                                      | affinity for pods assignment see: <https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity>                                                                                                                                                | <code>{}</code>                               |
| loincConverter.extraEnv                                      | extra environment variables to set on the                                                                                                                                                                                                                                        | <code>[]</code>                               |
| fhirPseudonymizer.enabled                                    | whether to enable the FHIR Pseudonymizer - a thin, FHIR-native wrapper on top of gPAS with additional options for anonymization. if this is set to false, then the FHIR gateway will not attempt to pseudonymize/anonymize the resources.                                        | <code>true</code>                             |
| fhirPseudonymizer.metrics.serviceMonitor.enabled             | if enabled, creates a ServiceMonitor instance for Prometheus Operator-based monitoring                                                                                                                                                                                           | <code>false</code>                            |
| fhirPseudonymizer.metrics.serviceMonitor.additionalLabels    | additional labels for the ServiceMonitor resource, e.g. `release: prometheus`                                                                                                                                                                                                    | <code>{}</code>                               |
| fhirPseudonymizer.auth.apiKey.enabled                        | enable requiring an API key placed in the `x-api-key` header to authenticate against the fhir-pseudonymizer's `/fhir/$de-pseudonymize` endpoint.                                                                                                                                 | <code>false</code>                            |
| fhirPseudonymizer.auth.apiKey.key                            | expected value for the key, aka "password"                                                                                                                                                                                                                                       | <code>""</code>                               |
| fhirPseudonymizer.auth.apiKey.existingSecret                 | name of an existing secret with an `APIKEY` key containing the expected password                                                                                                                                                                                                 | <code>""</code>                               |
| fhirPseudonymizer.replicaCount                               | number of replicas. This components can also be easily scaled horizontally if necessary.                                                                                                                                                                                         | <code>1</code>                                |
| fhirPseudonymizer.imagePullSecrets                           | image pull secrets                                                                                                                                                                                                                                                               | <code>[]</code>                               |
| fhirPseudonymizer.podAnnotations                             | pod annotations                                                                                                                                                                                                                                                                  | <code>{}</code>                               |
| fhirPseudonymizer.podSecurityContext                         | the pod security context                                                                                                                                                                                                                                                         | <code>{}</code>                               |
| fhirPseudonymizer.service                                    | service to expose the fhir-pseudonymizer                                                                                                                                                                                                                                         | <code>{"port":8080,"type":"ClusterIP"}</code> |
| fhirPseudonymizer.anonymizationConfig                        | configure the anonymization rules, see <https://gitlab.miracum.org/miracum/etl/deployment/-/blob/master/fhir-gw/anonymization.yaml> for an example. this is evaluated as a template. Also see [README.md](README.md#pseudonymization) for configuring it within this values.yaml | <code>{}</code>                               |
| fhirPseudonymizer.resources                                  | resource requests and limits                                                                                                                                                                                                                                                     | <code>{}</code>                               |
| fhirPseudonymizer.nodeSelector                               | node labels for pods assignment see: <https://kubernetes.io/docs/user-guide/node-selection/>                                                                                                                                                                                     | <code>{}</code>                               |
| fhirPseudonymizer.tolerations                                | tolerations for pods assignment see: <https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/>                                                                                                                                                                   | <code>[]</code>                               |
| fhirPseudonymizer.affinity                                   | affinity for pods assignment see: <https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity>                                                                                                                                                | <code>{}</code>                               |
| fhirPseudonymizer.extraEnv                                   | extra environment variables to apply to the container                                                                                                                                                                                                                            | <code>[]</code>                               |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```console
$ helm install fhir-gateway miracum/fhir-gateway -n fhir-gateway --version=3.5.9 --set replicaCount=1
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while
installing the chart. For example:

```console
$ helm install fhir-gateway miracum/fhir-gateway -n fhir-gateway --version=3.5.9 --values values.yaml
```

## Pseudonymization

You can configure custom anonymization rules directly in the `values.yaml`. For example, the following configuraiton is used by the fhir-pseudonymizer by default.
It simply encrypts the medical record and visit numbers:

```yaml
fhirPseudonymizer:
  enabled: true
  anonymizationConfig: |
    ---
    fhirVersion: R4
    fhirPathRules:
    - path: nodesByType('HumanName')
        method: redact
    - path: nodesByType('Identifier').where(type.coding.system='http://terminology.hl7.org/CodeSystem/v2-0203' and type.coding.code='VN').value
        method: encrypt
    - path: nodesByType('Identifier').where(type.coding.system='http://terminology.hl7.org/CodeSystem/v2-0203' and type.coding.code='MR').value
        method: encrypt
    parameters:
    dateShiftKey: ""
    dateShiftScope: resource
    cryptoHashKey: fhir-pseudonymizer
    # must be of a valid AES key length; here the key is padded to 192 bits
    encryptKey: fhir-pseudonymizer000000
    enablePartialAgesForRedact: true
    enablePartialDatesForRedact: true
    enablePartialZipCodesForRedact: true
    restrictedZipCodeTabulationAreas: []
```

An example which leverages pseudonymization:

```yaml
fhirPseudonymizer:
  enabled: true
  anonymizationConfig: |
    fhirVersion: R4
    fhirPathRules:
    - path: nodesByType('HumanName')
        method: redact
    - path: nodesByType('Identifier').where(type.coding.system='http://terminology.hl7.org/CodeSystem/v2-0203' and type.coding.code='VN').value
        method: pseudonymize
        domain: ENCOUNTER-IDS
    - path: nodesByType('Identifier').where(type.coding.system='http://terminology.hl7.org/CodeSystem/v2-0203' and type.coding.code='MR').value
        method: pseudonymize
        domain: PATIENT-IDS
    - path: nodesByType('Identifier').where(type.coding.system='http://fhir.de/CodeSystem/identifier-type-de-basis' and type.coding.code='GKV' or type.coding.code='PKV')
        method: redact
    parameters:
    dateShiftKey: ""
    dateShiftScope: resource
    cryptoHashKey: "secret"
    encryptKey: ""
    enablePartialAgesForRedact: true
    enablePartialDatesForRedact: true
    enablePartialZipCodesForRedact: true
    restrictedZipCodeTabulationAreas: []
```
