# fhir-pseudonymizer

[FHIR Pseudonymizer](https://github.com/miracum/fhir-pseudonymizer) - Helm chart for deploying the MIRACUM FHIR Pseudonymizer on Kubernetes.

## TL;DR;

```console
$ helm install fhir-pseudonymizer oci://ghcr.io/miracum/charts/fhir-pseudonymizer --create-namespace -n fhir-pseudonymizer
```

## Introduction

This chart deploys the MIRACUM FHIR Pseudonymizer on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes v1.16+
- Helm v3

## Installing the Chart

To install the chart with the release name `fhir-pseudonymizer`:

```console
$ helm install fhir-pseudonymizer oci://ghcr.io/miracum/charts/fhir-pseudonymizer --create-namespace -n fhir-pseudonymizer
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

| Parameter                                   | Description                                                                                                                                                                                                                                                                                                                               | Default                                                          |
| ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| deploymentAnnotations                       | metadata.annotations to apply to the deployment                                                                                                                                                                                                                                                                                           | <code>{}</code>                                                  |
| nameOverride                                | String to partially override fullname template (will maintain the release name)                                                                                                                                                                                                                                                           | <code>""</code>                                                  |
| fullnameOverride                            | String to fully override fullname template                                                                                                                                                                                                                                                                                                | <code>""</code>                                                  |
| pseudonymizationService                     | the type of pseudonymization service to use. One of gPAS, Vfps, None                                                                                                                                                                                                                                                                      | <code>gPAS</code>                                                |
| gpas.fhirUrl                                | the gPAS TTP FHIR Pseudonymizer base URL used to be used by the pseudonymization service. it should look similar to this: `http://gpas:8080/ttp-fhir/fhir/`                                                                                                                                                                               | <code>""</code>                                                  |
| gpas.version                                | Version of gPAS used. There were breaking changes to the FHIR API starting in 1.10.2, so explicitly set this value to 1.10.2 if `gpas.fhirUrl` points to gPAS 1.10.2.                                                                                                                                                                     | <code>"1.10.1"</code>                                            |
| gpas.auth.basic.enabled                     | whether the fhir-pseudonymizer needs to provide basic auth credentials to access the gPAS FHIR API                                                                                                                                                                                                                                        | <code>false</code>                                               |
| gpas.auth.basic.username                    | HTTP basic auth username                                                                                                                                                                                                                                                                                                                  | <code>""</code>                                                  |
| gpas.auth.basic.password                    | HTTP basic auth password                                                                                                                                                                                                                                                                                                                  | <code>""</code>                                                  |
| gpas.auth.basic.existingSecret              | read the password from an existing secret from the `GPAS__AUTH__BASIC__PASSWORD` key                                                                                                                                                                                                                                                      | <code>""</code>                                                  |
| metrics.serviceMonitor.enabled              | if enabled, creates a ServiceMonitor instance for Prometheus Operator-based monitoring                                                                                                                                                                                                                                                    | <code>false</code>                                               |
| metrics.serviceMonitor.additionalLabels     | additional labels for the ServiceMonitor resource, e.g. `release: prometheus`                                                                                                                                                                                                                                                             | <code>{}</code>                                                  |
| auth.apiKey.enabled                         | enable requiring an API key placed in the `x-api-key` header to authenticate against the fhir-pseudonymizer's `/fhir/$de-pseudonymize` endpoint.                                                                                                                                                                                          | <code>false</code>                                               |
| auth.apiKey.key                             | expected value for the key, aka "password"                                                                                                                                                                                                                                                                                                | <code>""</code>                                                  |
| auth.apiKey.existingSecret                  | name of an existing secret with an `APIKEY` key containing the expected password                                                                                                                                                                                                                                                          | <code>""</code>                                                  |
| replicaCount                                | number of replicas. This components can also be easily scaled horizontally if necessary.                                                                                                                                                                                                                                                  | <code>1</code>                                                   |
| imagePullSecrets                            | image pull secrets                                                                                                                                                                                                                                                                                                                        | <code>[]</code>                                                  |
| podAnnotations                              | pod annotations                                                                                                                                                                                                                                                                                                                           | <code>{}</code>                                                  |
| podSecurityContext                          | the pod security context                                                                                                                                                                                                                                                                                                                  | <code>{}</code>                                                  |
| service                                     | service to expose the fhir-pseudonymizer at                                                                                                                                                                                                                                                                                               | <code>{"metricsPort":8081,"port":8080,"type":"ClusterIP"}</code> |
| anonymizationConfig                         | configure the anonymization rules, see <https://github.com/miracum/fhir-pseudonymizer/blob/HEAD/src/FhirPseudonymizer/anonymization.yaml> for an example. this is evaluated as a template. Also see [README.md](README.md#pseudonymization) for configuring it within this values.yaml                                                    | <code>""</code>                                                  |
| resources                                   | resource requests and limits                                                                                                                                                                                                                                                                                                              | <code>{}</code>                                                  |
| nodeSelector                                | node labels for pods assignment see: <<https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/>>                                                                                                                                                                                                                         | <code>{}</code>                                                  |
| tolerations                                 | tolerations for pods assignment see: <https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/>                                                                                                                                                                                                                            | <code>[]</code>                                                  |
| affinity                                    | affinity for pods assignment see: <https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity>                                                                                                                                                                                                         | <code>{}</code>                                                  |
| extraEnv                                    | extra environment variables to apply to the container                                                                                                                                                                                                                                                                                     | <code>[]</code>                                                  |
| extraVolumeMounts                           | extra volumeMounts for the main fhir-pseudonymizer container                                                                                                                                                                                                                                                                              | <code>[]</code>                                                  |
| extraVolumes                                | extra volumes                                                                                                                                                                                                                                                                                                                             | <code>[]</code>                                                  |
| topologySpreadConstraints                   | pod topology spread configuration see: <https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#api>                                                                                                                                                                                                          | <code>[]</code>                                                  |
| podDisruptionBudget.enabled                 | create a PodDisruptionBudget resource                                                                                                                                                                                                                                                                                                     | <code>false</code>                                               |
| podDisruptionBudget.minAvailable            | Minimum available instances; ignored if there is no PodDisruptionBudget                                                                                                                                                                                                                                                                   | <code>1</code>                                                   |
| podDisruptionBudget.maxUnavailable          | Maximum unavailable instances; ignored if there is no PodDisruptionBudget                                                                                                                                                                                                                                                                 | <code>""</code>                                                  |
| autoscaling.enabled                         | enable horizontal pod autoscaling                                                                                                                                                                                                                                                                                                         | <code>false</code>                                               |
| autoscaling.minReplicas                     | minReplicas is the lower limit for the number of replicas to which the autoscaler can scale down. It defaults to 1 pod. minReplicas is allowed to be 0 if the alpha feature gate HPAScaleToZero is enabled and at least one Object or External metric is configured. Scaling is active as long as at least one metric value is available. | <code>1</code>                                                   |
| autoscaling.maxReplicas                     | upper limit for the number of pods that can be set by the autoscaler; cannot be smaller than `minReplicas`.                                                                                                                                                                                                                               | <code>5</code>                                                   |
| autoscaling.targetCPUUtilizationPercentage  | target average CPU utilization (represented as a percentage of requested CPU) over all the pods; if not specified the default autoscaling policy will be used.                                                                                                                                                                            | <code>80</code>                                                  |
| serviceAccount.create                       | Specifies whether a service account should be created                                                                                                                                                                                                                                                                                     | <code>false</code>                                               |
| serviceAccount.annotations                  | Annotations to add to the service account                                                                                                                                                                                                                                                                                                 | <code>{}</code>                                                  |
| serviceAccount.name                         | The name of the service account to use. If not set and create is true, a name is generated using the fullname template                                                                                                                                                                                                                    | <code>""</code>                                                  |
| serviceAccount.automountServiceAccountToken | whether to automount the SA token                                                                                                                                                                                                                                                                                                         | <code>false</code>                                               |
| vfps.enabled                                | set to `true` to enable the included vfps sub-chart and auto-configure the FHIR Pseudonymizer to use it as the pseudonymization backend                                                                                                                                                                                                   | <code>false</code>                                               |
| externalVfps.address                        | the address of an external vfps service to use. Use `dns:///example:8081` to enable dns-based round-robin client-side load-balancing.                                                                                                                                                                                                     | <code>""</code>                                                  |
| tests.resources                             | configure the test pods resource requests and limits                                                                                                                                                                                                                                                                                      | <code>{}</code>                                                  |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```console
$ helm install fhir-pseudonymizer oci://ghcr.io/miracum/charts/fhir-pseudonymizer -n fhir-pseudonymizer --set pseudonymizationService=gPAS
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while
installing the chart. For example:

```console
$ helm install fhir-pseudonymizer oci://ghcr.io/miracum/charts/fhir-pseudonymizer -n fhir-pseudonymizer --values values.yaml
```

## Pseudonymization

You can configure custom anonymization rules directly in the `values.yaml`. For example, the following configuration is used by the fhir-pseudonymizer by default.
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

### Vfps

The FHIR Pseudonymizer supports both gPAS and Vfps as a pseudonymization backend service. gPAS is set as the default.
To switch to Vfps, set `pseudonymizationService=Vfps` and optionally set `vfps.enabled=true` to start an included version of the Vfps chart.
