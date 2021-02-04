Automat helm Chart
---
> [Source code for automat](https://github.com/TranslatorIIPrototypes/KITCHEN/tree/master/KITCHEN/Automat)
>
> [Docker Image](https://hub.docker.com/repository/docker/renciorg/automat)

### Introduction 

This Chart deploys a single instance of automat.

Chart configured in values.yaml to suite needs.

### Parameters

Installation can be configured with the following parameters.

| Parameter | Description | Default |
| --------- | ----        | ----    | 
| `image.repository` | Web server image repository   | `renciorg/automat`
| `image.tag` | Webserver image tag  | `2.0`
| `nameOverride` | Release name override when doing helm install.  | `nil`
| `fullnameOverride` | Release full name override.  | `nil`
| `service.type` | Web server kubernetes service type  | `ClusterIP`
| `service.port` | Web server kubernetes service port | `80`
| `fullHostName` | This will only be used populate server name in [openapi spec](https://swagger.io/specification/#oas-servers). | `nil`
| `ingress.host` | If behind ingress configure host url.| `nil`
| `ingress.class` | Ingress class  | `default`
| `ingress.tls` | If tls is needed provide tls configuration compatible with [Kubernetes Ingress tls config](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls)  | `nil`
| `app.port` | Port to expose on Container | `8080`

### Installing 

Note:  Any of the above parameters can be overridden using set argument. 
```shell script
<.../helm/automat>$ helm install --set service.port=81  myrelease . 
```
 
 
### Uninstalling
```shell script
<.../helm/automat>$ helm uninstall myrelease
```

### Upgrading
```shell script
<.../helm/automat>$ helm upgrade --set service.port=80 myrelease . 
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


 