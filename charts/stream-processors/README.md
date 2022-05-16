# stream-processors

[Kafka Stream Processors](https://gitlab.miracum.org/miracum/etl/streams) - A Helm chart for deploying a set of Kafka stream processing apps.

## TL;DR;

```console
$ helm repo add miracum https://miracum.github.io/charts
$ helm repo update
$ helm install stream-processors miracum/stream-processors -n stream-processors --version=1.1.8
```

## Introduction

This chart deploys the Kafka Stream Processors on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes v1.16+
- Helm v3
- Strimzi Kafka Operator installed

To install a simple Kafka cluster after the Strimzi Kafka Operator is installed, run:

```sh
kubectl apply -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/main/examples/kafka/kafka-ephemeral-single.yaml
```

## Installing the Chart

To install the chart with the release name `stream-processors`:

```console
$ helm install stream-processors miracum/stream-processors -n stream-processors --version=1.1.8
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

| Parameter                                | Description                                                                                                                                                               | Default                 |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| commonAnnotations                        | annotations to apply to all deployments                                                                                                                                   | <code>{}</code>         |
| strimziClusterName                       | name of the strimzi cluster. Used to construct the bootstrap server URL.                                                                                                  | <code>my-cluster</code> |
| securityProtocol                         | The Kafka security protocol to use. See <https://kafka.apache.org/26/javadoc/org/apache/kafka/common/security/auth/SecurityProtocol.html> for a list of supported values. | <code>SSL</code>        |
| imagePullSecrets                         |                                                                                                                                                                           | <code>[]</code>         |
| nameOverride                             |                                                                                                                                                                           | <code>""</code>         |
| fullnameOverride                         |                                                                                                                                                                           | <code>""</code>         |
| podSecurityContext                       | PodSecurityContext applied to all deployments                                                                                                                             | <code>{}</code>         |
| securityContext.allowPrivilegeEscalation |                                                                                                                                                                           | <code>false</code>      |
| securityContext.privileged               |                                                                                                                                                                           | <code>false</code>      |
| securityContext.runAsNonRoot             |                                                                                                                                                                           | <code>true</code>       |
| securityContext.runAsUser                |                                                                                                                                                                           | <code>11111</code>      |
| securityContext.runAsGroup               |                                                                                                                                                                           | <code>11111</code>      |
| defaultReplicaCount                      | sets the replicas value for all processor deployments unless overriden on a per-processor level as `.replicaCount`                                                        | <code>1</code>          |
| defaultRevisionHistoryLimit              | sets the revisionHistoryLimit value for all processor deployments unless overriden on a per-processor level as `.revisionHistoryLimit`                                    | <code>10</code>         |
| defaultTolerations                       | sets list of tolerations for all processor deployments unless overriden on a per-processor level as `.tolerations`                                                        | <code>[]</code>         |
| processors                               | list of stream processing deployments. See [values-test.yaml](values-test.yaml) for an example                                                                            | <code>{}</code>         |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```console
$ helm install stream-processors miracum/stream-processors -n stream-processors --version=1.1.8 --set strimziClusterName=my-cluster
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while
installing the chart. For example:

```console
$ helm install stream-processors miracum/stream-processors -n stream-processors --version=1.1.8 --values values.yaml
```
