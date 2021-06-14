Biolink Lookup Helm Chart
--- 
> [Source code for Biolink lookup](https://github.com/TranslatorSRI/bl_lookup)
>
> [Biolink lookup Docker image](https://hub.docker.com/repository/docker/renciorg/bl_lookup)

### Introduction 

The following chart deploys [Biolink lookup](https://github.com/TranslatorSRI/bl_lookup). Running instance can be found at [here](https://bl-lookup-sri.renci.org/apidocs/).

### Parameters

Installation can be configured with the following parameters.
 
| Parameter | Description | Default |
| --------- | ----        | ----    | 
| `replicaCount` | Replicas for web server   | `1`
| `image.repository` |  Image repository | `renciorg/bl_lookup`
| `image.tag` | Image tag | `latest`
| `service.type` | Web server kubernetes service type port  | `ClusterIP`
| `service.port` | Web server kubernetes service port for web server  | `80`
| `ingress.host` | Public DNS name   | `nil`
| `ingress.class` |  Ingress class name | `nil`

### Installing 

Note:  Any of the above parameters can be overridden using set argument. 
```shell script
<.../helm/biolink-lookup>$ helm install --set service.port=81  myrelease . 
```
 
 
### Uninstalling
```shell script
<.../helm/biolink-lookup>$ helm uninstall myrelease
```

### Upgrading
```shell script
<.../helm/biolink-lookup>$ helm upgrade --set service.port=80 myrelease . 
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


 
