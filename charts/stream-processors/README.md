# stream-processors

[Kafka Stream Processors](https://gitlab.miracum.org/miracum/etl/streams) - A Helm chart for deploying a set of Kafka stream processing apps.

## TL;DR;

```console
$ helm repo add miracum https://miracum.github.io/charts
$ helm repo update
$ helm install stream-processors miracum/stream-processors -n stream-processors
```

## Introduction

This chart deploys the Kafka Stream Processors on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes v1.16+
- Helm v3
- Strimzi Operator installed

## Installing the Chart

To install the chart with the release name `stream-processors`:

```console
$ helm install stream-processors miracum/stream-processors -n stream-processors
```

The command deploys the Kafka Stream Processors on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `stream-processors`:

```console
$ helm delete stream-processors -n stream-processors
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the `stream-processors` chart and their default values.

| Parameter                                | Description                                                                                                                                                               | Default         |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| commonAnnotations                        | annotations to apply to all deployments                                                                                                                                   | `{}`            |
| strimziClusterName                       | name of the strimzi cluster. Used to construct the bootstrap server URL.                                                                                                  | `kafka-cluster` |
| securityProtocol                         | The Kafka security protocol to use. See <https://kafka.apache.org/26/javadoc/org/apache/kafka/common/security/auth/SecurityProtocol.html> for a list of supported values. | `SSL`           |
| imagePullSecrets                         |                                                                                                                                                                           | `[]`            |
| nameOverride                             |                                                                                                                                                                           | `""`            |
| fullnameOverride                         |                                                                                                                                                                           | `""`            |
| podSecurityContext                       | PodSecurityContext applied to all deployments                                                                                                                             | `{}`            |
| securityContext.allowPrivilegeEscalation |                                                                                                                                                                           | `false`         |
| securityContext.privileged               |                                                                                                                                                                           | `false`         |
| securityContext.runAsNonRoot             |                                                                                                                                                                           | `true`          |
| securityContext.runAsUser                |                                                                                                                                                                           | `11111`         |
| securityContext.runAsGroup               |                                                                                                                                                                           | `11111`         |
| processors                               | list of stream processing deployments. See [values-test.yaml](values-test.yaml) for an example                                                                            | `{}`            |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```console
$ helm install stream-processors miracum/stream-processors -n stream-processors --set strimziClusterName=kafka-cluster
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while
installing the chart. For example:

```console
$ helm install stream-processors miracum/stream-processors -n stream-processors --values values.yaml
```
