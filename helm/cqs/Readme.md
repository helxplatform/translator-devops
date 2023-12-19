 Helm Chart
---
> [Source code for Curated Query Service (CQS)](https://github.com/TranslatorSRI/CQS)
>

### Introduction 

This Chart can be used to install [CQS](https://github.com/TranslatorSRI/CQS/wiki).

### Parameters

| Parameter |  Default |
| --------- |  ----    | 
| `replicaCount` | `1`
| `image.tag` | `0.1`
| `image.repository` | `ghcr.io/translatorsri/cqs`
| `service.type` | `ClusterIP`
| `service.port` | `8080`
| `ingress.class` | `ingress_CLASS`
| `ingress.host` | `ingress_HOST`

### Installing 

Note:  Any of the above parameters can be overridden using set argument. 
```shell script
$ helm install  <my-release> . 
```

### Uninstalling

```shell script
$ helm uninstall <my-release>
```

### Upgrading

```shell script
$ helm upgrade <my-release> . 
```

###Other deployment commands
To render your chart without deploying:
 
```shell script
$ helm template --debug -f <values_file> <my-release> .
```

To dry run your chart install: 
```shell script
$ helm install -f <values_file> --dry-run --debug <my-release> .
```
