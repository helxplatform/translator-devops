 Helm Chart
---
> [Source code for CAM-KP-API](https://github.com/NCATS-Tangerine/cam-kp-api)
>

### Introduction 

This Chart can be used to install [CAM-KP-API](https://github.com/NCATS-Tangerine/cam-kp-api/wiki).

### Parameters

| Parameter |  Default |
| --------- |  ----    | 
| `replicaCount` | `1`
| `image.tag` | `0.1`
| `image.repository` | `renciorg/cam-kp-api`
| `service.type` | `ClusterIP`
| `service.port` | `8080`
| `ingress.class` | `translator`
| `ingress.host` | `cam-kp-api.renci.org`

### Installing 

Note:  Any of the above parameters can be overridden using set argument. 
```shell script
$ helm install  myrelease . 
```

### Uninstalling

```shell script
$ helm uninstall myrelease
```

### Upgrading

```shell script
$ helm upgrade --set service.port=80 myrelease . 
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
