# Charts

[![OpenSSF Scorecard](https://img.shields.io/ossf-scorecard/github.com/miracum/charts?label=openssf%20scorecard&style=flat)](https://scorecard.dev/viewer/?uri=github.com/miracum/charts)

> A collection of Helm charts

```sh
helm repo add miracum https://miracum.github.io/charts
helm repo update
```

> [!NOTE]
> Also available as OCI artifacts: <https://github.com/orgs/miracum/packages?repo_name=charts>.

## Development

1. (Optional) Setup a KinD cluster with Ingress support

   Since v0.9.0, [cloud-provider-kind](https://github.com/kubernetes-sigs/cloud-provider-kind) natively implements
   `Service`s of type `LoadBalancer`, `Ingress` (IngressClass `cloud-provider-kind`, set as the cluster default) and the Gateway API
   (GatewayClass `cloud-provider-kind`). No separate ingress controller or special cluster config is required.
   See <https://kind.sigs.k8s.io/docs/user/ingress/>.

   ```sh
   kind create cluster
   # cloud-provider-kind runs outside the cluster and watches all kind clusters. Keep it running.
   docker run -d --name cloud-provider-kind --restart unless-stopped --network kind \
     -v /var/run/docker.sock:/var/run/docker.sock \
     registry.k8s.io/cloud-provider-kind/cloud-controller-manager:v0.12.0@sha256:1b97632e5dfec8f83c7e970cf18cedb9e6b707e272011d712cabf6ab59d323c9
   kubectl get ingressclass
   ```

   Alternatively, install the binary (`go install sigs.k8s.io/cloud-provider-kind@latest`) and run `cloud-provider-kind`
   (with `sudo` on macOS and Docker Desktop/WSL2).

   Each Ingress gets an IP address from the kind docker network (`kubectl get ingress -A`). On Linux, it is reachable directly.
   The chart defaults use `<name>.127.0.0.1.nip.io` hostnames, so either override the host (e.g. `opal.172.19.0.4.nip.io`)
   or set the `Host` header:

   ```sh
   INGRESS_IP=$(kubectl get ingress opal-opal -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
   curl -H "Host: opal.127.0.0.1.nip.io" "http://${INGRESS_IP}/"
   ```

   On macOS and Docker Desktop, node IPs aren't reachable from the host. cloud-provider-kind instead maps the
   load balancer port to a random `localhost` port (see `docker ps --filter name=kindccm`).

   > [!IMPORTANT]
   > kind's default CNI (kindnet) enforces NetworkPolicies. The ingress proxy (Envoy) runs as a container on the `kind`
   > docker network, not as a pod. Traffic from it is therefore blocked by charts that create NetworkPolicies, which shows as
   > `503 upstream connect error ... connection timeout`. Allow it via the chart's `networkPolicy.extraIngress`, e.g. for opal:
   >
   > ```yaml
   > opal:
   >   networkPolicy:
   >     extraIngress:
   >       - from:
   >           - ipBlock:
   >               cidr: 172.16.0.0/12 # docker network inspect kind
   >         ports:
   >           - port: http
   >             protocol: TCP
   > ```

1. (Optional) With Calico as a CNI to test NetworkPolicy resources

   ```sh
   kind create cluster --config hack/kind-config-calico.yaml
   kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/operator-crds.yaml
   kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/tigera-operator.yaml
   kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/custom-resources.yaml
   watch kubectl get pods -l k8s-app=calico-node -A
   ```

1. Make changes to the charts

1. Bump the version in the changed Chart.yaml according to SemVer (The `ct lint` step below will complain if you forget to update the version).

1. Mount the folder in the [kube-powertools](https://github.com/chgl/kube-powertools) container to easily run linters and checks

   ```sh
   docker run --rm -it -v $PWD:/root/workspace ghcr.io/chgl/kube-powertools:v2.7.1@sha256:5f51fd770eb92c70b8cf48c3dbb57634a1256bea2fce50984124055ffa93214c
   ```

1. Run chart-testing and the `chart-powerlint.sh` script to lint the chart

   ```sh
   ct lint --config .github/ct/ct.yaml && chart-powerlint.sh
   ```

   Info: Sometimes for that to work you need to update the commons chart, like e.g. for blaze:

   ```sh
   helm dependency update charts/blaze
   ```

   because else it will throw errors like:

   ```sh
   ==> Linting charts/blaze
   [ERROR] templates/: template: blaze/templates/tests/test-connection.yaml:25:21: executing "blaze/templates/tests/test-connection.yaml" at <include "common.resources.preset" (dict "type" .Values.tests.resourcesPreset)>: error calling include: template: no template "common.resources.preset" associated with template "gotpl"
   ```

1. (Optional) View the results of the [polaris audit check](https://github.com/FairwindsOps/polaris) in your browser

   ```sh
   $ docker run --rm -it -p 9090:8080 -v $PWD:/root/workspace ghcr.io/chgl/kube-powertools:v2.7.1@sha256:5f51fd770eb92c70b8cf48c3dbb57634a1256bea2fce50984124055ffa93214c
   bash-5.0: helm template charts/fhir-gateway/ | polaris dashboard --config .polaris.yaml --audit-path -
   ```

   You can now open your browser at <http://localhost:9090> and see the results and recommendations.

1. Run `generate-docs.sh` to auto-generate an updated README

   ```sh
   generate-docs.sh
   ```
