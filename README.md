# Charts

[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/miracum/charts/badge)](https://api.securityscorecards.dev/projects/github.com/miracum/charts)

> A collection of Helm charts

```sh
helm repo add miracum https://miracum.github.io/charts
helm repo update
```

> [!NOTE]
> Also available as OCI artifacts: <https://github.com/orgs/miracum/packages?repo_name=charts>.

## Development

1. (Optional) Setup a KinD cluster with Nginx ingress support

   ```sh
   kind create cluster --config=hack/kind-config.yaml
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
   ```

1. Make changes to the charts

1. Bump the version in the changed Chart.yaml according to SemVer (The `ct lint` step below will complain if you forget to update the version).

1. Mount the folder in the [kube-powertools](https://github.com/chgl/kube-powertools) container to easily run linters and checks

   ```sh
   docker run --rm -it -v $PWD:/root/workspace ghcr.io/chgl/kube-powertools:v2.3.68@sha256:9a0a5d10b58765cff42bf65e672d98f051d27b74eb555a8d954aea22ab9bb180
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
   $ docker run --rm -it -p 9090:8080 -v $PWD:/root/workspace ghcr.io/chgl/kube-powertools:v2.3.68@sha256:9a0a5d10b58765cff42bf65e672d98f051d27b74eb555a8d954aea22ab9bb180
   bash-5.0: helm template charts/fhir-gateway/ | polaris dashboard --config .polaris.yaml --audit-path -
   ```

   You can now open your browser at <http://localhost:9090> and see the results and recommendations.

1. Run `generate-docs.sh` to auto-generate an updated README

   ```sh
   generate-docs.sh
   ```
