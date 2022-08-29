# {{ .Project.ShortName }}

[{{ .Project.Name }}]({{ .Project.URL }}) - {{ .Project.Description }}

## TL;DR;

```console
$ helm repo add {{ .Repository.Name }} {{ .Repository.URL }}
$ helm repo update
$ helm install {{ .Release.Name }} {{ .Repository.Name }}/{{ .Chart.Name }} -n {{ .Release.Namespace }}
```

You can find more exhaustive documentation at the {{ .Project.Name }} documentation site: <https://miracum.github.io/recruit/deployment/kubernetes>.

## Introduction

This chart deploys {{ .Project.App }} on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites
{{ range .Prerequisites }}
- {{ . }}
{{- end }}

## Upgrades & Breaking Changes

See [UPGRADING.md](./docs/UPGRADING.md) for information on breaking changes introduced by major version bumps and instructions on how to update.

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

## Configure Notifcation Rules

The notification rules can be directly configured inside your values.yaml. For example:

```yaml
notify:
  enabled: true
  rules:
    # create custom notification schedules using https://www.cronmaker.com
    # these are later referenced used when configuring the notification frequency per user.
    # Note that the user will only receive an email notification if the scheduled time has been
    # reached _and_ there has been a _new_ patient recommendation since the last one.An identical
    # email won't be relentlessly sent everyMorning/Monday/Hour etc...
    schedules:
      everyMorning: "0 0 8 1/1 * ? *"
      everyMonday: "0 0 8 ? * MON *"
      everyHour: "0 0 0/1 1/1 * ? *"
      everyFiveMinutes: "0 0/5 * 1/1 * ? *"

    # trials are identified by their acronym which corresponds to the cohort's title in Atlas or the "[acronym=XYZ]" tag
    trials:
      # a value of '*' matches every trial, so 'everything@example.com' will receive an email whenever any screeninglist
      # gets updated.
      - acronym: "*"
        subscriptions:
          - email: "everything@example.com"

      - acronym: "SAMPLE"
        # the new "accessibleBy" key allows specifying users either by username or email address that
        # are allowed to access the screening list
        accessibleBy:
          users:
            - "user1"
            - "user.two@example.com"
        subscriptions:
          - email: "everyMorning@example.com"
            # each 'notify'-value corresponds to one schedule
            notify: "everyMorning"
            # a lack of a 'notify'-key with an associated schedule means that the user will be notified immediately.
          - email: "immediately-sample@example.com"
            # For example, the following entry means that if the 'SAMPLE' trial received new screening recommendations,
            # an email is sent to 'everyMonday@example.com' on the next monday. This is useful for aggregating notifications
            # about screening recommendations.
          - email: "everyMonday@example.com"
            notify: "everyMonday"

      - acronym: "AMICA"
        subscriptions:
          - email: "immediately-amica@example.com"
          - email: "everyHour1@example.com"
            notify: "everyHour"
          - email: "everyHour2@example.com"
            notify: "everyHour"
          - email: "everyFiveMinutes@example.com"
            notify: "everyFiveMinutes"
```

## Distributed Tracing

First install the Jaeger operator to prepare your cluster for tracing.

```sh
# required by the Jaeger Operator
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.yaml
kubectl create namespace observability
kubectl create -f https://github.com/jaegertracing/jaeger-operator/releases/download/v1.37.0/jaeger-operator.yaml -n observability

cat <<EOF | kubectl apply -n observability -f -
# simple, all-in-one Jaeger installation. Not suitable for production use.
apiVersion: jaegertracing.io/v1
kind: Jaeger
metadata:
  name: simplest
EOF
```

The query and notify module include a [OpenTelemetry Java agent JAR](https://github.com/open-telemetry/opentelemetry-java-instrumentation)
while the list module is manually instrumented. Tracing support can be enabled and configured per-module via environment variables. Here's
an example configuration assuming the tracing collector/agent was installed following the steps above:

```yaml
query:
  extraEnv:
    - name: JAVA_TOOL_OPTIONS
      value: "-javaagent:/opt/query/opentelemetry-javaagent.jar"
    - name: OTEL_METRICS_EXPORTER
      value: "none"
    - name: OTEL_LOGS_EXPORTER
      value: "none"
    - name: OTEL_TRACES_EXPORTER
      value: "jaeger"
    - name: OTEL_SERVICE_NAME
      value: "recruit-query"
    - name: OTEL_EXPORTER_JAEGER_ENDPOINT
      value: "http://simplest-collector.observability.svc:14250"

list:
  extraEnv:
    - name: TRACING_ENABLED
      value: "true"
    - name: OTEL_TRACES_EXPORTER
      value: "jaeger"
    - name: OTEL_SERVICE_NAME
      value: "recruit-list"
    - name: OTEL_EXPORTER_JAEGER_AGENT_HOST
      value: "simplest-agent.observability.svc"

notify:
  extraEnv:
    - name: JAVA_TOOL_OPTIONS
      value: "-javaagent:/opt/notify/opentelemetry-javaagent.jar"
    - name: OTEL_METRICS_EXPORTER
      value: "none"
    - name: OTEL_LOGS_EXPORTER
      value: "none"
    - name: OTEL_TRACES_EXPORTER
      value: "jaeger"
    - name: OTEL_SERVICE_NAME
      value: "recruit-notify"
    - name: OTEL_EXPORTER_JAEGER_ENDPOINT
      value: "http://simplest-collector.observability.svc:14250"

fhirserver:
  extraEnv:
    # the recruit tool relies on the FHIR server subscription mechanism to create notifications.
    # if you overwrite `fhirserver.extraEnv`, make sure to keep this setting enabled.
    - name: HAPI_FHIR_SUBSCRIPTION_RESTHOOK_ENABLED
      value: "true"
    - name: SPRING_FLYWAY_BASELINE_ON_MIGRATE
      value: "true"
    # OTel options
    - name: JAVA_TOOL_OPTIONS
      value: "-javaagent:/app/opentelemetry-javaagent.jar"
    - name: OTEL_METRICS_EXPORTER
      value: "none"
    - name: OTEL_LOGS_EXPORTER
      value: "none"
    - name: OTEL_TRACES_EXPORTER
      value: "jaeger"
    - name: OTEL_SERVICE_NAME
      value: "recruit-hapi-fhir-server"
    - name: OTEL_EXPORTER_JAEGER_ENDPOINT
      value: "http://simplest-collector.observability.svc:14250"
```
