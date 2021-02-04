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


 