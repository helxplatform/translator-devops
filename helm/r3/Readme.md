 Helm Chart
---
> [Source code for Nodenormalization](https://github.com/TranslatorSRI/NodeNormalization)
>
> [Docker Image](https://hub.docker.com/repository/docker/renciorg/r3_nodenorm)


### Introduction 

This Chart can be used to install [Node normalization service](https://nodenormalization-sri.renci.org/docs).

### Parameters

| Parameter | Description | Default |
| --------- | ----        | ----    | 
| `redisImage.repository` | Redis  docker image  | `redis`
| `redisImage.tag` |  Redis docker image tag | `latest`
| `webserverImage.repository` |  Web server docker image  | `renciorg/r3_nodenorm`
| `webserverImage.tag` | Web server docker tag  | `latest`
| `redis.service.type` | Redis server kubernetes service type  | `ClusterIP`
| `redis.port` | Redis server port | `6379`
| `redis.resources.limits.memory` | Redis server memory limit  | `nil`
| `redis.resources.requests.memory` | Redis server memory   | `nil`
| `redis.seedDB` |  This will create an init container that waits for loading data to redis before server starts. | `True`
| `redis.storage.size` |  Redis storage size  | `nil`
| `redis.args` |  Redis server args | `['--save', '', '--stop-writes-on-bgsave-error', 'no']`
| `web.replicaCount` | Web server replica count   | `1`
| `web.service.type` | Web server kubernetes service type  | `ClusterIP`
| `web.port` |  Web server port | `6380`
| `ingress.host` | Ingress DNS host name   | `nil`
| `ingress.class` | Ingress class  | `nil`
 

### Installing 

Note:  Any of the above parameters can be overridden using set argument. 
```shell script
<.../helm/r3>$ helm install  myrelease . 
```

### Uninstalling

```shell script
<.../helm/r3>$ helm uninstall myrelease
```

### Upgrading

```shell script
<.../helm/r3>$ helm upgrade --set web.port=80 myrelease . 
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

