# translator-devops

The `*values-populated.yaml` and `ncats*-values.yaml` files are git-crypt encrypted because
some hold live secrets (for example `helm/name-lookup/values-populated.yaml` holds the GitHub
token that reads the blocklist). Never print one of these files whole: grep for the key you
need and report only whether it is set. A secret that has been displayed has to be rotated.
