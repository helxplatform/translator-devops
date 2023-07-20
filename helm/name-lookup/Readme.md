Name lookup Helm Chart
---
> [Source code for Name lookup/ Name resolution](https://github.com/TranslatorSRI/NameResolution)
>
> [Docker Image](https://hub.docker.com/layers/renciorg/name_lookup)

### Introduction

This chart installs [Name resolution service](https://github.com/TranslatorSRI/NameResolution) in a kubrnetes cluster.
A running instance can be found [here](http://name-resolution-sri.renci.org/docs).

### Parameters

Installation can be configured with the following parameters.

| Parameter | Description | Default |
| --------- | ----        | ----    | 
| `webServer.replicaCount` | Replica count for web server pods  | `1`
| `webServer.service.port` | Web server kubernetes service port  | `2433`
| `webServer.service.type` | Web server kubernetes service type  | `ClusterIP`
| `webServer.port` | Web server port  | `2433`
| `webServer.image.repository` | Web server docker image  | `renciorg/name_lookup`
| `webServer.image.tag` | Web server docker image tag   | `latest`
| `solr.service.port` | Solr server kubernetes service port  | `8983`
| `solr.service.type` |  Solr server kubernetes service type | `ClusterIP`
| `solr.port` | Solr server port   | `8983`
| `solr.image.repository` |  Solr server docker container | `solr`
| `solr.image.tag` |  Solr server docker container tag | `latest`
| `solr.resources.requests.memory` |  Solr server memory requests  | `5Gi`
| `solr.resources.limits.memory` |  Solr server memory limits | `5Gi`
| `nameOverride` | Release name override  | `nil`
| `fullnameOverride` | Release full name override  | `nil`
| `ingress.proxyConnectTimeout` | Ingress proxy time out for opening a connection to web services  | `600`
| `ingress.proxyReadTimeout` | Ingress proxy read timeout for connections to web services  | `600`
| `ingress.host` |  Ingress DNS host name  | `nil`
| `ingress.class` |  Ingress class  | `nil`


### Installing 

Note:  Any of the above parameters can be overridden using set argument. 
```shell script
<.../helm/name-lookup>$ helm install --set service.port=81  myrelease . 
```
 
 
### Uninstalling
```shell script
<.../helm/name-lookup>$ helm uninstall myrelease
```

### Upgrading
```shell script
<.../helm/name-lookup>$ helm upgrade --set service.port=80 myrelease . 
```

###Other deployment commands
To render your chart without deploying:
 
```shell script
$ helm template --debug -f <values_file> myrelease .
```
​
To dry run your chart install: 
```console
$ helm install -f <values_file> --dry-run --debug myrelease .
```

## Blocklist

Name Resolver/Name Lookup is set up to use a blocklist as a YAML file
from a GitHub repository. Once Solr database restoration is
complete, the restore script will use the blocklist to remove CURIEs
that may be problematic for any number of reasons.

If the blocklist is in a private GitHub repository, you will also need
to create a [GitHub Personal Access Token] and include that as a [Kubernetes secret]
in your pod. Two configuration variables control this:
- `blocklist.url`: Should be the URL of the Blocklist file, such as
  https://api.github.com/repos/NCATSTranslator/Blocklists/contents/main/blocklist.yaml?ref=main
- `blocklist.github_personal_access_token_secret`: if a GitHub personal access
  token is needed, you can store it in a [Kubernetes secret] with the key `github_personal_access_token`,
  and then set this configuration variable to the name of the secret.

The easiest way to create the Kubernetes secret for the GitHub personal access token
is by using `kubectl`:

```shell
$ kubectl -n $NAMESPACE create secret generic $SECRET_NAME --from-literal=github_personal_access_token=github_pat_...
```

You can then confirm that this has been set correctly by running:

```shell
$ kubectl -n $NAMESPACE describe secret/$SECRET_NAME
```

[GitHub Personal Access Token]: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token
[Kubernetes secret]: https://kubernetes.io/docs/concepts/configuration/secret/#creating-a-secret