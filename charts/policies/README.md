# policies

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A Helm chart for deploying Kyverno policies verifying images of the github.com/miracum organization.

**Homepage:** <https://github.com/miracum/charts>

## Installation

```sh
$ helm upgrade --install policies oci://ghcr.io/miracum/charts/policies --create-namespace -n policies
```

## Values

| Key                     | Type   | Default                  | Description |
| ----------------------- | ------ | ------------------------ | ----------- |
| failurePolicy           | string | `"Fail"`                 |             |
| fullnameOverride        | string | `""`                     |             |
| images[0]               | string | `"fhir-gateway"`         |             |
| images[1]               | string | `"fhir-pseudonymizer"`   |             |
| images[2]               | string | `"loinc-conversion"`     |             |
| images[3]               | string | `"vfps"`                 |             |
| images[4]               | string | `"obds-to-fhir"`         |             |
| images[5]               | string | `"ohdsi-cohort-sync"`    |             |
| images[6]               | string | `"ahd2fhir"`             |             |
| images[7]               | string | `"kafka-fhir-to-server"` |             |
| nameOverride            | string | `""`                     |             |
| validationFailureAction | string | `"Enforce"`              |             |
| webhookTimeoutSeconds   | int    | `30`                     |             |
