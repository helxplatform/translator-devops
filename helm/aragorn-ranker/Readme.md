ARAGORN Ranker helm Chart
---
> [Source code for ARAGORN Ranker](https://github.com/ranking-agent/aragorn-ranker.git)
>
> [Docker Image](https://hub.docker.com/repository/docker/renciorg/aragorn-ranker)


### Introduction 


This Chart deploys a single instance of ARAGORN Ranker.

Chart configured in values.yaml to suite needs.

By default this chart uses `Loadbalancer` service type this can be overridden for other environment by setting values. 

Eg: To deploy local environment (minikube) , in this directory do 
> $ helm install aragorn-ranker-helm --set service.type=NodePort ./ 
 
### Parameters 

| Parameter | Description | Default |
| --------- | ----        | ----    | 
| `image.repository` | Web server docker image  | `renciorg/aragorn-ranker`
| `image.tag` | Web server docker tag  | `latest`
| `nameOverride` |  Install release name override | `nil`
| `fullnameOverride` | Install release full name override  | `nil`
| `service.type` | Web server kubernetes service type  | `ClusterIP`
| `service.port` | Web server kubernetes service port  | `8080`
| `ingress.host` | Ingress DNS host name  | `ingress_HOST`
| `ingress.enabled` | Enable / Disable ingress  | `True`
| `ingress.annotations` | Dictionary of annotations for ingress  | `kubernetes.io/ingress.class`: `translator`
| `app.port` |  Web application port | `4321`
| `omnicorpCache.port` | Omnicorp remote redis cache server port  | `5678`
| `omnicorpPostgres.dbName` | Omnicorp postgres database name  | `db_name`
| `omnicorpPostgres.dbUser` | Omnicorp postgres user name  | `db_user`
| `omnicorpPostgres.port` | Omnicorp postgres port  | `1234`
| `secrets.omnicorpHost` | Omnicorp remote host name  | `omnicorp_HOST`
| `secrets.omnicorpPassword` | Omnicorp postgres password  | `somePW`
| `secrets.omnicorpCacheHost` |  Omnicorp cache remote host name | `omnicorpCache_HOST`
| `secrets.omnicorpCachePassword` | Omnicorp cache password   | `somePW`


### Installing


To deploy Aragorn-Ranker : 
```shell script
<.../helm/aragorn-ranker>$ helm -n <your-namespace> install my-release .
```

To deploy Onto: 
```shell script
<../helm/aragorn-ranker>$ helm -n <your-namespace> install myrelease
```

### Uninstalling
```shell script
<.../helm/aragorn-ranker>$ helm uninstall myrelease
```

### Upgrading
```shell script
<.../helm/aragorn-ranker>$ helm upgrade --set service.port=80 myrelease . 
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