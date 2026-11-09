# translator-devops

Files matching the `.gitattributes` patterns `values-populated.yaml` (that exact name),
`ncats*-values.yaml`, `renci*.yaml` and `plater*.yaml` are git-crypt encrypted because some
hold live secrets (for example `helm/name-lookup/values-populated.yaml` holds the GitHub
token that reads the blocklist). Never print one of these files whole: grep for the key you
need and report only whether it is set. A secret that has been displayed has to be rotated.

Other files named `*-values-populated.yaml`, such as `helm/name-lookup/robokop-values-populated.yaml`,
are **not** encrypted despite the name. Never put a secret in one; put it in an encrypted file
instead. `git-crypt status <path>` tells you which files are encrypted.
