ARAGORN helm Chart
---
> [Source code for ARAGORN](https://github.com/ranking-agent/aragorn.git)
>
> [Docker Image](https://hub.docker.com/repository/docker/renciorg/aragorn)

### Introduction
This Chart deploys a single instance of ARAGORN.

Chart configured in values.yaml to suite needs.

By default this chart uses `Loadbalancer` service type this can be overridden for other environment by setting values. 

Eg: To deploy local environment (minikube) , in this directory do 
> $ helm install aragorn-helm --set service.type=NodePort ./ 
 
 
 ### Parameters
 
 Installation can be configured with the following parameters.
 
 | Parameter | Description | Default |
| --------- | ----        | ----    | 
| `image.repository` | Docker image repository | `renciorg/aragorn`
| `image.tag` |  Docker image tag | `latest`
| `nameOverride` |  Release name override | `nil`
| `fullnameOverride` |  Release full name override | `nil`
| `service.type` |  Web server kubernetes service type | `ClusterIP`
| `service.port` |  Web server kubernetes service port | `8080`
| `ingress.host` |  Ingress DNS host name | `ingress_HOST`
| `ingress.class` |  Ingress class | `ingress_CLASS`
| `ingress.enabled` |  Enable / Disable ingress | `True`
| `ingress.annotations.kubernetes.io/ingress.class` |   | `translator`
| `app.port` | Web server port  | `4321`


### Installing


To deploy Aragon : 
```shell script
<.../helm/aragorn>$ helm -n <your-namespace> install my-release .
```

### Uninstalling
```shell script
<.../helm/aragorn>$ helm uninstall myrelease
```

### Upgrading
```shell script
<.../helm/aragorn>$ helm upgrade --set app.port=80 myrelease . 
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


 