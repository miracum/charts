# fhir-gateway

[FHIR Gateway](https://gitlab.miracum.org/miracum/etl/fhir-gateway) - Helm chart for deploying the MIRACUM FHIR Gateway on Kubernetes.

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

| Parameter                                                    | Description                                                                                                                                                                                                                               | Default                            |
| ------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| tracing.enabled                                              | enables tracing for all supported components by default, the components export traces in Jaeger format to `localhost:16686`                                                                                                               | `false`                            |
| replicaCount                                                 | number of replicas. The application is well-suited to scale horizontally if required.                                                                                                                                                     | `1`                                |
| nameOverride                                                 | String to partially override fullname template (will maintain the release name)                                                                                                                                                           | `""`                               |
| fullnameOverride                                             | String to fully override fullname template                                                                                                                                                                                                | `""`                               |
| service                                                      | the service used to expose the FHIR GW REST endpoint                                                                                                                                                                                      | `{"port":8080,"type":"ClusterIP"}` |
| ingress.enabled                                              | if enabled, create an Ingress to expose the FHIR Gateway outside the cluster                                                                                                                                                              | `false`                            |
| metrics.serviceMonitor.enabled                               | if enabled, creates a ServiceMonitor instance for Prometheus Operator-based monitoring                                                                                                                                                    | `false`                            |
| sinks.postgres.enabled                                       | if enabled, writes all received FHIR resources to a Postgres DB if `postgresql.enabled=true`, then a Postgres DB is started as part of this installation. If `postgresql.enabled=false`, then `sinks.postgres.external.*` is used.        | `true`                             |
| sinks.postgres.external.host                                 | host or server name                                                                                                                                                                                                                       | `""`                               |
| sinks.postgres.external.port                                 | port                                                                                                                                                                                                                                      | `"5432"`                           |
| sinks.postgres.external.database                             | name of the database to connect to                                                                                                                                                                                                        | `""`                               |
| sinks.postgres.external.username                             | username to authenticate as                                                                                                                                                                                                               | `""`                               |
| sinks.postgres.external.password                             | password for the user                                                                                                                                                                                                                     | `""`                               |
| sinks.postgres.external.existingSecret                       | can be used to specify the name of an existing secret with a `postgresql-password` key containing the password. An alternative to setting the password above.                                                                             | `""`                               |
| sinks.fhirServer.enabled                                     | if enabled, sends all received resources to the specified FHIR server                                                                                                                                                                     | `false`                            |
| sinks.fhirServer.url                                         | URL of the FHIR server. Support for authentication is not implemented.                                                                                                                                                                    | `""`                               |
| kafka.enabled                                                | if enabled, the FHIR Gateway will read resources from the specified Kafka topic `inputTopic` and write them to `outputTopic`. Requires the Kafka cluster to be configured using <https://strimzi.io/>.                                    | `false`                            |
| kafka.inputTopic                                             | name of the Kafka topic to read resources from                                                                                                                                                                                            | `fhir-raw`                         |
| kafka.outputTopic                                            | name of the topic to write processed resources to                                                                                                                                                                                         | `fhir.post-gatway`                 |
| kafka.securityProtocol                                       | either PLAINTEXT or SSL                                                                                                                                                                                                                   | `PLAINTEXT`                        |
| kafka.strimziClusterName                                     | name of the Strimzi Kafka CRD this gateway should connect to. This is used to resolve the Kafka bootstrap service.                                                                                                                        | `"my-cluster"`                     |
| postgresql.enabled                                           | enabled the included Postgres DB see <https://github.com/bitnami/charts/tree/master/bitnami/postgresql> for configuration options                                                                                                         | `true`                             |
| postgresql.postgresqlDatabase                                | name of the database used by the FHIR gateway to store the resources                                                                                                                                                                      | `"fhir_gateway"`                   |
| postgresql.replication.enabled                               | enable replication for data resilience                                                                                                                                                                                                    | `true`                             |
| postgresql.replication.readReplicas                          | number of read (slave) replicas                                                                                                                                                                                                           | `2`                                |
| postgresql.replication.synchronousCommit                     | enable synchronous commit - this may degrade performance in favor of resiliency                                                                                                                                                           | `"on"`                             |
| postgresql.replication.numSynchronousReplicas                | from the number of `readReplicas` defined above, set the number of those that will have synchronous replication NOTE: It cannot be > readReplicas                                                                                         | `1`                                |
| postgresql.image.tag                                         | use a more recent Postgres version than the default                                                                                                                                                                                       | `13.1.0`                           |
| postgresql.image.pullPolicy                                  |                                                                                                                                                                                                                                           | `IfNotPresent`                     |
| postgresql.containerSecurityContext.allowPrivilegeEscalation |                                                                                                                                                                                                                                           | `false`                            |
| gpas.fhirUrl                                                 | the gPAS TTP FHIR Gateway base URL used to be used by the pseudonymization service. it should look similar to this: `http://gpas:8080/ttp-fhir/fhir/`                                                                                     | `""`                               |
| gpas.version                                                 | Version of gPAS used. There were breaking changes to the FHIR API starting in 1.10.2, so explicitely set this value to 1.10.2 if `gpas.fhirUrl` points to gPAS 1.10.2.                                                                    | `"1.10.1"`                         |
| gpas.auth.basic.enabled                                      | whether the fhir-pseudonymizer needs to provide basic auth credentials to access the gPAS FHIR API                                                                                                                                        | `false`                            |
| gpas.auth.basic.username                                     | HTTP basic auth username                                                                                                                                                                                                                  | `""`                               |
| gpas.auth.basic.password                                     | HTTP basic auth password                                                                                                                                                                                                                  | `""`                               |
| gpas.auth.basic.existingSecret                               | read the password from an existing secret from the `GPAS__AUTH__BASIC__PASSWORD` key                                                                                                                                                      | `""`                               |
| loincConverter.enabled                                       | whether to enable the LOINC conversion and harmonization service                                                                                                                                                                          | `true`                             |
| loincConverter.metrics.serviceMonitor.enabled                | if enabled, creates a ServiceMonitor instance for Prometheus Operator-based monitoring                                                                                                                                                    | `false`                            |
| loincConverter.replicaCount                                  | if necessary, the service can easily scale horizontally                                                                                                                                                                                   | `1`                                |
| loincConverter.service                                       | service to expose the application                                                                                                                                                                                                         | `{"port":8080,"type":"ClusterIP"}` |
| fhirPseudonymizer.enabled                                    | whether to enable the FHIR Pseudonymizer - a thin, FHIR-native wrapper on top of gPAS with additional options for anonymization. if this is set to false, then the FHIR gateway will not attempt to pseudonymize/anonymize the resources. | `true`                             |
| fhirPseudonymizer.metrics.serviceMonitor.enabled             | if enabled, creates a ServiceMonitor instance for Prometheus Operator-based monitoring                                                                                                                                                    | `false`                            |
| fhirPseudonymizer.auth.apiKey.enabled                        | enable requiring an API key placed in the `x-api-key` header to authenticate against the fhir-pseudonymizer's `/fhir/$de-pseudonymize` endpoint.                                                                                          | `false`                            |
| fhirPseudonymizer.auth.apiKey.key                            | expected value for the key, aka "password"                                                                                                                                                                                                | `""`                               |
| fhirPseudonymizer.auth.apiKey.existingSecret                 | name of an existing secret with an `APIKEY` key containing the expected password                                                                                                                                                          | `""`                               |
| fhirPseudonymizer.replicaCount                               | number of replicas. This components can also be easily scaled horizontally if necessary.                                                                                                                                                  | `1`                                |
| fhirPseudonymizer.service                                    | service to expose the fhir-pseudonymizer                                                                                                                                                                                                  | `{"port":8080,"type":"ClusterIP"}` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```console
$ helm install fhir-gateway miracum/fhir-gateway -n fhir-gateway --set replicaCount=1
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while
installing the chart. For example:

```console
$ helm install fhir-gateway miracum/fhir-gateway -n fhir-gateway --values values.yaml
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
