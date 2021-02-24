#The helm deployment for Automat
##Introduction
This Chart deploys a single instance of Automat on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager. Please reference the following repos for more information on Automat and the underlying docker container image.

> [Source code for Automat](https://github.com/TranslatorIIPrototypes/KITCHEN/tree/master/KITCHEN/Automat)
>
> [Docker Image](https://hub.docker.com/repository/docker/renciorg/automat)

## Prerequisites
- Kubernetes 1.12+
- Helm 3.5.1

##File descriptions
- Chart.yaml - Describes the meta data for the deployment
- values.yaml - An example chart values file. Please reference this file for configurable deployment parameters.
- /templates/automat-deployment.yaml - Chart that deploys the container.
- /templates/ingress.yaml - Chart template that deploys the application's ingress.
- /templates/service.yaml - Chart template that deploys the containers service definition.

##Installation

These commands deploy Automat on the Kubernetes cluster in the default configuration. 
The values.yaml file included in this repo can be used for testing purposes. You must create your own configuration values file that reflects your working environment.

###Installing the chart: 
```console
$ helm install -f <values_file> automat-helm .
```
### Uninstalling the Chart
To uninstall/delete the automat deployment:

```console
$ helm delete automat-helm
```
### Configure the way to expose Automat

- **Ingress**: The ingress controller must be installed in the Kubernetes cluster.
- **ClusterIP**: Exposes the service on a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster. Set `service.type=ClusterIP` to choose this service type.
- **NodePort**: Exposes the service on each Node's IP at a static port (the NodePort). You’ll be able to contact the NodePort service, from outside the cluster, by requesting `NodeIP:NodePort`. Set `service.type=NodePort` to choose this service type.
- **LoadBalancer**: Exposes the service externally using a cloud provider's load balancer. Set `service.type=LoadBalancer` to choose this service type.
=======
### Introduction 

This Chart deploys a single instance of automat.

##Other deployment tools
To render your chart without deploying: 
```console
$ helm template --debug -f <values_file> automat-helm .
```

To dry run your chart install: 
```console
$ helm install -f <values_file> --dry-run --debug test_automat-helm .
```
=======
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
To dry run your chart install: 
```console
$ helm install -f <values_file> --dry-run --debug myrelease .
```