# {{ .Project.ShortName }}

[{{ .Project.Name }}]({{ .Project.URL }}) - {{ .Project.Description }}

## TL;DR;

```console
$ helm repo add {{ .Repository.Name }} {{ .Repository.URL }}
$ helm repo update
$ helm install {{ .Release.Name }} {{ .Repository.Name }}/{{ .Chart.Name }} -n {{ .Release.Namespace }}
```

## Breaking changes

### v2 to v3

Version 3 of the chart upgrades the fhir-pseudonymizer component to v2. It's breaking changes require version 1.10 of gPAS, in particular it depends
on the new gPAS TTP FHIR GW interface. The value `gpas.wsdlUrl` has been renamed to `gpas.fhirUrl` to reflect this change.

## Introduction

This chart deploys {{ .Project.App }} on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites
{{ range .Prerequisites }}
- {{ . }}
{{- end }}

## Installing the Chart

To install the chart with the release name `{{ .Release.Name }}`:

```console
$ helm install {{ .Release.Name }} {{ .Repository.Name }}/{{ .Chart.Name }} -n {{ .Release.Namespace }}
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
