# stream-processors

[Kafka Stream Processors](https://gitlab.miracum.org/miracum/etl/streams) - A Helm chart for deploying a set of Kafka stream processing apps.

## TL;DR;

```console
$ helm install stream-processors oci://ghcr.io/miracum/charts/stream-processors --create-namespace -n stream-processors
```

## Introduction

This chart deploys the Kafka Stream Processors on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes v1.16+
- Helm v3
- Strimzi Kafka Operator installed

To install a simple Kafka cluster using the Strimzi Operator, run:

```sh
helm upgrade --install strimzi-operator oci://quay.io/strimzi-helm/strimzi-kafka-operator
kubectl apply -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/main/examples/kafka/kafka-ephemeral-single.yaml

# Optional: install the Kube Prometheus stack to test the ServiceMonitor integration:
helm upgrade --install kube-prom-stack oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack \
    --set=kubeStateMetrics.enabled=false \
    --set=nodeExporter.enabled=false \
    --set=grafana.enabled=false
```

## Installing the Chart

To install the chart with the release name `stream-processors`:

```console
$ helm install stream-processors oci://ghcr.io/miracum/charts/stream-processors --create-namespace -n stream-processors
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

| Parameter                                                            | Description                                                                                                                                                                                                                                                                                                              | Default                               |
| -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------- |
| strimziClusterName                                                   | name of the strimzi cluster. Used to construct the bootstrap server URL.                                                                                                                                                                                                                                                 | <code>my-cluster</code>               |
| securityProtocol                                                     | The Kafka security protocol to use. See <https://kafka.apache.org/26/javadoc/org/apache/kafka/common/security/auth/SecurityProtocol.html> for a list of supported values.                                                                                                                                                | <code>SSL</code>                      |
| nameOverride                                                         |                                                                                                                                                                                                                                                                                                                          | <code>""</code>                       |
| fullnameOverride                                                     |                                                                                                                                                                                                                                                                                                                          | <code>""</code>                       |
| securityContext.allowPrivilegeEscalation                             |                                                                                                                                                                                                                                                                                                                          | <code>false</code>                    |
| securityContext.privileged                                           |                                                                                                                                                                                                                                                                                                                          | <code>false</code>                    |
| securityContext.readOnlyRootFilesystem                               |                                                                                                                                                                                                                                                                                                                          | <code>false</code>                    |
| securityContext.runAsNonRoot                                         |                                                                                                                                                                                                                                                                                                                          | <code>true</code>                     |
| securityContext.runAsUser                                            |                                                                                                                                                                                                                                                                                                                          | <code>11111</code>                    |
| securityContext.runAsGroup                                           |                                                                                                                                                                                                                                                                                                                          | <code>11111</code>                    |
| securityContext.seccompProfile.type                                  |                                                                                                                                                                                                                                                                                                                          | <code>RuntimeDefault</code>           |
| defaultReplicaCount                                                  | sets the replicas value for all processor deployments unless overridden on a per-processor level as `.replicaCount`                                                                                                                                                                                                      | <code>1</code>                        |
| defaultRevisionHistoryLimit                                          | sets the revisionHistoryLimit value for all processor deployments unless overridden on a per-processor level as `.revisionHistoryLimit`                                                                                                                                                                                  | <code>10</code>                       |
| default.timezone                                                     | Set container timezone                                                                                                                                                                                                                                                                                                   | <code>"Europe/Berlin"</code>          |
| default.persistence.enabled                                          | Enable persistence. This changes the processor's type from Deployment to a StatefulSet                                                                                                                                                                                                                                   | <code>false</code>                    |
| default.persistence.volumeName                                       | Name to assign the volume                                                                                                                                                                                                                                                                                                | <code>"data"</code>                   |
| default.persistence.existingClaim                                    | Name of an existing PVC to use                                                                                                                                                                                                                                                                                           | <code>""</code>                       |
| default.persistence.mountPath                                        | The path the volume will be mounted at. Also sets the `SPRING_KAFKA_STREAMS_STATE_DIR` environment variable to this value.                                                                                                                                                                                               | <code>/opt/kafka/streams/state</code> |
| default.persistence.storageClass                                     | PVC Storage Class for the data volume If defined, storageClassName: <storageClass> If set to "-", storageClassName: "", which disables dynamic provisioning If undefined (the default) or set to null, no storageClassName spec is set, choosing the default provisioner. (gp2 on AWS, standard on GKE, AWS & OpenStack) | <code>""</code>                       |
| default.persistence.size                                             | PVC Storage Request for volume                                                                                                                                                                                                                                                                                           | <code>8Gi</code>                      |
| default.persistence.persistentVolumeClaimRetentionPolicy.enabled     | Enable Persistent volume retention policy for Statefulset                                                                                                                                                                                                                                                                | <code>false</code>                    |
| default.persistence.persistentVolumeClaimRetentionPolicy.whenScaled  | Volume retention behavior when the replica count of the StatefulSet is reduced                                                                                                                                                                                                                                           | <code>Retain</code>                   |
| default.persistence.persistentVolumeClaimRetentionPolicy.whenDeleted | Volume retention behavior that applies when the StatefulSet is deleted                                                                                                                                                                                                                                                   | <code>Retain</code>                   |
| defaultNetworkPolicy.enabled                                         | whether to create a default NetworkPolicy for each processor deployment. extra rules can be added on a per-processor level as `.networkPolicy.extraIngress/Egress`                                                                                                                                                       | <code>false</code>                    |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```console
$ helm install stream-processors oci://ghcr.io/miracum/charts/stream-processors -n stream-processors --set strimziClusterName=my-cluster
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while
installing the chart. For example:

```console
$ helm install stream-processors oci://ghcr.io/miracum/charts/stream-processors -n stream-processors --values values.yaml
```
