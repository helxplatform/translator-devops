Edge normalization Helm Chart 
---
> [Source code for Edge normalization](https://github.com/TranslatorSRI/EdgeNormalization)
>
> [Docker Image](https://hub.docker.com/repository/docker/renciorg/edgenormalization)

### Introduction

This chart installs [Edge normalization service](https://github.com/TranslatorSRI/EdgeNormalization) in a kubrnetes cluster.
A running instance can be found [here](https://edgenormalization-sri.renci.org/apidocs/).



### Parameters

Installation can be configured with the following parameters.

| Parameter | Description | Default |
| --------- | ----        | ----    | 
| `replicaCount` | Replica count for web server  | `1`
| `image.repository` | Web server docker image repository  | `renciorg/edgenormalization`
| `image.tag` |  Web server image tag | `latest`
| `nameOverride` | Release name override  | `nil`
| `fullnameOverride` | Release full name override  | `nil`
| `service.type` | Web server kubernetes service type  | `ClusterIP`
| `service.port` |  Web server kubernetes service port  | `80`
| `ingress.host` |  Ingress host name | `nil`
| `ingress.class` |  Ingress class | `nil`


### Installing 

Note:  Any of the above parameters can be overridden using set argument. 
```shell script
<.../helm/edge-normalization>$ helm install --set service.port=81  myrelease . 
```
 
 
### Uninstalling
```shell script
<.../helm/edge-normalization>$ helm uninstall myrelease
```

### Upgrading
```shell script
<.../helm/edge-normalization>$ helm upgrade --set service.port=80 myrelease . 
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

