# {{ .Project.ShortName }}

[{{ .Project.Name }}]({{ .Project.URL }}) - {{ .Project.Description }}

## TL;DR;

```console
$ helm install {{ .Release.Name }} {{ .Repository.Name }}/{{ .Chart.Name }} --create-namespace -n {{ .Release.Namespace }}
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
