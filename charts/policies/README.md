# policies

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A Helm chart for deploying Kyverno policies verifying images of the github.com/miracum organization.

**Homepage:** <https://github.com/miracum/charts>

## Installation

```sh
$ helm upgrade --install policies oci://ghcr.io/miracum/charts/policies --create-namespace -n policies
```

## Values

| Key                                 | Type   | Default    | Description                                                                                                                                                                                                                                                                                                                                                       |
| ----------------------------------- | ------ | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| failurePolicy                       | string | `"Fail"`   |                                                                                                                                                                                                                                                                                                                                                                   |
| fullnameOverride                    | string | `""`       |                                                                                                                                                                                                                                                                                                                                                                   |
| nameOverride                        | string | `""`       |                                                                                                                                                                                                                                                                                                                                                                   |
| validationActions                   | list   | `["Deny"]` | defaults to Audit rather than Deny: images built before the `standard-build.yaml` workflow was updated to emit a SLSA v1 provenance attestation via actions/attest-build-provenance will fail the provenance check (they only carry the old, no-longer-verifiable v0.2 attestation). Switch to Deny once your images have been rebuilt with the updated workflow. |
| webhookConfiguration.timeoutSeconds | int    | `30`       |                                                                                                                                                                                                                                                                                                                                                                   |
