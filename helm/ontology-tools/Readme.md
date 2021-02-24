Reasoner (ontology) tools Helm Chart
---
> [Source code for Resoner(ontology) tools](https://github.com/ncats-tangerine/reasoner-tools)
>
> [Bionames Api Docker image](https://hub.docker.com/repository/docker/renciorg/green-bionames)
>
> [Onto Api Docker image](https://hub.docker.com/repository/docker/renciorg/green-onto_gunicorn)

### Introduction

The following chart deploys [reasoner tools](https://github.com/ncats-tangerine/reasoner-tools). There are 
two apps in that this deployment is capable deploying. The two instances are available 
at [bionames.renci.org](https://bionames.renci.org/apidocs)
and [onto.renci.org](https://onto.renci.org/apidocs)

### Parameters

Installation can be configured with the following parameters.

| Parameter | Description | Default |
| --------- | ----        | ----    | 
| `replicaCount` | Web server instance count  | `1`
| `image.repository` | Web server image. Use either of these images `renciorg/green-onto_gunicorn` or `renciorg/green-bionames` |  `nil`
| `image.tag` | Web server image tag   | `latest`
| `nameOverride` |  Release name override | `nil`
| `fullnameOverride` | Release full name override  | `nil`
| `service.type` |  Web server kubernetes service type | `ClusterIP`
| `service.port` | Web server kubernetes service name  | `80`
| `ingress.host` |  Ingress DNS name | `nil`
| `ingress.class` | Ingress class name  | `nil`


### Installing


To deploy Bionames : 
```shell script
<.../helm/ontology-tools>$ helm -n <your-namespace> install onto-bio-names  .
```

To deploy Onto: 
```shell script
<../helm/ontology-tools>$ helm -n <your-namespace> install onto-lookup .
```

### Uninstalling
```shell script
<.../helm/ontology-tools>$ helm uninstall myrelease
```

### Upgrading
```shell script
<.../helm/ontology-tools>$ helm upgrade --set service.port=80 myrelease . 
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


 
