 Helm Chart
---
> [Source code for Strider](https://github.com/ranking-agent/strider)
> [Source code for KP-registry](https://github.com/ranking-agent/kp_registry)
>
> [Docker KP registry](https://github.com/orgs/ranking-agent/packages/container/package/kp_registry)
> [Docker Image Strider](https://github.com/orgs/ranking-agent/packages/container/package/strider)

### Introduction 

This Chart can be used to install [Strider](https://strider.renci.org/docs) along with [KP registry](https://kp-registry.renci.org/docs).

### Parameters

| Parameter |  Default |
| --------- |  ----    | 
| `replicaCount` | `1`
| `kpRegistry.image.tag` | `v0.2.0`
| `kpRegistry.image.repository` | `ghcr.io/ranking-agent/kp_registry`
| `kpRegistry.service.type` | `ClusterIP`
| `kpRegistry.service.port` | `80`
| `strider.image.tag` | `v1.0.0`
| `strider.image.repository` | `ghcr.io/ranking-agent/strider`
| `strider.env.OMNICORP_URL` | `http://robokop.renci.org:3210`
| `strider.env.SERVER_URL` | `http://localhost:8881`
| `strider.service.type` | `ClusterIP`
| `strider.service.port` | `5781`
| `redis.image.tag` | `latest`
| `redis.image.repository` | `redis`
| `redis.service.port` | `6379`
| `redis.service.type` | `ClusterIP`
| `redis.resources.limits.memory` | `10Gi`
| `redis.resources.requests.memory` | `10Gi`
| `ingress.class` | `translator`
| `ingress.strider.host` | `strider.renci.org`
| `ingress.kpRegistry.host` | `kp-registry.renci.org`

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
$ helm upgrade --set strider.service.port=80 myrelease . 
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

