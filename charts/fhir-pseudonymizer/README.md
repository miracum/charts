# fhir-pseudonymizer

[FHIR Pseudonymizer](https://gitlab.miracum.org/miracum/etl/fhir-pseudonymizer) - Helm chart for deploying the MIRACUM FHIR Pseudonymizer on Kubernetes.

## TL;DR;

```console
$ helm repo add miracum https://miracum.github.io/charts
$ helm repo update
$ helm install fhir-pseudonymizer miracum/fhir-pseudonymizer -n fhir-pseudonymizer
```

<!---
## Breaking changes

### v2 to v3

Version 3 of the chart upgrades the fhir-pseudonymizer component to v2. It's breaking changes require version 1.10 of gPAS, in particular it depends
on the new gPAS TTP FHIR GW interface. The value `gpas.wsdlUrl` has been renamed to `gpas.fhirUrl` to reflect this change.
--->

## Introduction

This chart deploys the MIRACUM FHIR Pseudonymizer on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes v1.16+
- Helm v3

## Installing the Chart

To install the chart with the release name `fhir-pseudonymizer`:

```console
$ helm install fhir-pseudonymizer miracum/fhir-pseudonymizer -n fhir-pseudonymizer
```

The command deploys the MIRACUM FHIR Pseudonymizer on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `fhir-pseudonymizer`:

```console
$ helm delete fhir-pseudonymizer -n fhir-pseudonymizer
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the `fhir-pseudonymizer` chart and their default values.

| Parameter                               | Description                                                                                                                                                                                                                                                                      | Default                            |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| global.deploymentAnnotations            | metadata.annotations to apply to all deployments                                                                                                                                                                                                                                 | `{}`                               |
| global.tracing.enabled                  | enables tracing by default, traces are exported in Jaeger format to `localhost:16686`                                                                                                                                                                                            | `false`                            |
| nameOverride                            | String to partially override fullname template (will maintain the release name)                                                                                                                                                                                                  | `""`                               |
| fullnameOverride                        | String to fully override fullname template                                                                                                                                                                                                                                       | `""`                               |
| gpas.fhirUrl                            | the gPAS TTP FHIR Pseudonymizer base URL used to be used by the pseudonymization service. it should look similar to this: `http://gpas:8080/ttp-fhir/fhir/`                                                                                                                      | `""`                               |
| gpas.version                            | Version of gPAS used. There were breaking changes to the FHIR API starting in 1.10.2, so explicitely set this value to 1.10.2 if `gpas.fhirUrl` points to gPAS 1.10.2.                                                                                                           | `"1.10.1"`                         |
| gpas.auth.basic.enabled                 | whether the fhir-pseudonymizer needs to provide basic auth credentials to access the gPAS FHIR API                                                                                                                                                                               | `false`                            |
| gpas.auth.basic.username                | HTTP basic auth username                                                                                                                                                                                                                                                         | `""`                               |
| gpas.auth.basic.password                | HTTP basic auth password                                                                                                                                                                                                                                                         | `""`                               |
| gpas.auth.basic.existingSecret          | read the password from an existing secret from the `GPAS__AUTH__BASIC__PASSWORD` key                                                                                                                                                                                             | `""`                               |
| metrics.serviceMonitor.enabled          | if enabled, creates a ServiceMonitor instance for Prometheus Operator-based monitoring                                                                                                                                                                                           | `false`                            |
| metrics.serviceMonitor.additionalLabels | additional labels for the ServiceMonitor resource, e.g. `release: prometheus`                                                                                                                                                                                                    | `{}`                               |
| auth.apiKey.enabled                     | enable requiring an API key placed in the `x-api-key` header to authenticate against the fhir-pseudonymizer's `/fhir/$de-pseudonymize` endpoint.                                                                                                                                 | `false`                            |
| auth.apiKey.key                         | expected value for the key, aka "password"                                                                                                                                                                                                                                       | `""`                               |
| auth.apiKey.existingSecret              | name of an existing secret with an `APIKEY` key containing the expected password                                                                                                                                                                                                 | `""`                               |
| replicaCount                            | number of replicas. This components can also be easily scaled horizontally if necessary.                                                                                                                                                                                         | `1`                                |
| imagePullSecrets                        | image pull secrets                                                                                                                                                                                                                                                               | `[]`                               |
| podAnnotations                          | pod annotations                                                                                                                                                                                                                                                                  | `{}`                               |
| podSecurityContext                      | the pod security context                                                                                                                                                                                                                                                         | `{}`                               |
| service                                 | service to expose the fhir-pseudonymizer                                                                                                                                                                                                                                         | `{"port":8080,"type":"ClusterIP"}` |
| anonymizationConfig                     | configure the anonymization rules, see <https://gitlab.miracum.org/miracum/etl/deployment/-/blob/master/fhir-gw/anonymization.yaml> for an example. this is evaluated as a template. Also see [README.md](README.md#pseudonymization) for configuring it within this values.yaml | `{}`                               |
| resources                               | resource requests and limits                                                                                                                                                                                                                                                     | `{}`                               |
| nodeSelector                            | node labels for pods assignment see: <https://kubernetes.io/docs/user-guide/node-selection/>                                                                                                                                                                                     | `{}`                               |
| tolerations                             | tolerations for pods assignment see: <https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/>                                                                                                                                                                   | `[]`                               |
| affinity                                | affinity for pods assignment see: <https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity>                                                                                                                                                | `{}`                               |
| extraEnv                                | extra environment variables to apply to the container                                                                                                                                                                                                                            | `[]`                               |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```console
$ helm install fhir-pseudonymizer miracum/fhir-pseudonymizer -n fhir-pseudonymizer --set gpas.version="1.10.1"
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while
installing the chart. For example:

```console
$ helm install fhir-pseudonymizer miracum/fhir-pseudonymizer -n fhir-pseudonymizer --values values.yaml
```

## Pseudonymization

You can configure custom anonymization rules directly in the `values.yaml`. For example, the following configuraiton is used by the fhir-pseudonymizer by default.
It simply encrypts the medical record and visit numbers:

```yaml
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
