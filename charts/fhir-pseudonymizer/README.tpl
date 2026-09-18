# {{ .Project.ShortName }}

[{{ .Project.Name }}]({{ .Project.URL }}) - {{ .Project.Description }}

## TL;DR;

```console
$ helm install {{ .Release.Name }} {{ .Repository.Name }}/{{ .Chart.Name }} --create-namespace -n {{ .Release.Namespace }}
```

## Introduction

This chart deploys {{ .Project.App }} on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites
{{ range .Prerequisites }}
- {{ . }}
{{- end }}

## Installing the Chart

To install the chart with the release name `{{ .Release.Name }}`:

```console
$ helm install {{ .Release.Name }} {{ .Repository.Name }}/{{ .Chart.Name }} --create-namespace -n {{ .Release.Namespace }}
```

The command deploys {{ .Project.App }} on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `{{ .Release.Name }}`:

```console
$ helm delete {{ .Release.Name }} -n {{ .Release.Namespace }}
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the `{{ .Chart.Name }}` chart and their default values.

{{ .Chart.Values }}

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```console
$ helm install {{ .Release.Name }} {{ .Repository.Name }}/{{ .Chart.Name }} -n {{ .Release.Namespace }} --set {{ .Chart.ValuesExample }}
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while
installing the chart. For example:

```console
$ helm install {{ .Release.Name }} {{ .Repository.Name }}/{{ .Chart.Name }} -n {{ .Release.Namespace }} --values values.yaml
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

## Reading from Kafka

In addition to the HTTP API, the FHIR Pseudonymizer can consume FHIR resources/bundles directly from one or more Kafka topics,
pseudonymize them, and produce the result to a per-topic output topic. Set `kafka.enabled=true`, point `kafka.bootstrapServers`
at your brokers, and list the input topics as an array:

```yaml
kafka:
  enabled: true
  bootstrapServers: "kafka:9092"
  topics:
    - fhir.patient
    - fhir.observation
```

The output topic is derived from the input topic by a regular expression match-and-replace. The default prepends
`pseudonymized.` to every input topic, so `fhir.patient` becomes `pseudonymized.fhir.patient`. To instead insert it after a
common prefix, turning `fhir.patient` into `fhir.pseudonymized.patient`:

```yaml
kafka:
  outputTopicPattern: '^fhir\.'
  outputTopicReplacement: "fhir.pseudonymized."
```

Every entry of `kafka.topics`, as well as `kafka.provenanceTopic` and `kafka.consumer.groupId`, is evaluated as a template.
The consumer group id defaults to the release's fullname; note that it is also part of the name of the dead letter topic that
messages which could not be pseudonymized are sent to: `error.<input-topic>.<group-id>`.

Settings not exposed as a dedicated value can be set through the `kafka.client`, `kafka.consumer.config`, and
`kafka.producer.config` maps. Their keys are the property names of `Confluent.Kafka.ClientConfig`, `ConsumerConfig`, and
`ProducerConfig` respectively, and they are passed to the container as `Kafka__Client__<key>`, `Kafka__Consumer__<key>`, and
`Kafka__Producer__<key>` environment variables:

```yaml
kafka:
  client:
    securityProtocol: SaslSsl
    saslMechanism: ScramSha512
    saslUsername: fhir-pseudonymizer
  consumer:
    config:
      sessionTimeoutMs: "45000"
```

Since these end up in the pod spec in plaintext, set credentials via `extraEnv` with a `secretKeyRef` instead:

```yaml
extraEnv:
  - name: Kafka__Client__SaslPassword
    valueFrom:
      secretKeyRef:
        name: fhir-pseudonymizer-kafka-user
        key: password
```

If the brokers use TLS with a private CA, mount the CA certificate using `extraVolumes`/`extraVolumeMounts` and point
`kafka.client.sslCaLocation` at it.

Note that the application exposes no Kafka health check: a pod that cannot reach its brokers still reports itself as ready,
and only logs connection errors. Use the `fhirpseudonymizer_kafka_messages_total` metric and the consumer group's lag to
monitor whether messages are actually being processed.
