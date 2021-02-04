Answer Coalesce helm Chart
---
> [Source code for Answer Coelesce](https://github.com/ranking-agent/AnswerCoalesce)
>
> [Docker Image](https://hub.docker.com/repository/docker/renciorg/ac)


This service accepts a translator reasoner standard message containing answers and returns the same format with 
answers that have been coalesced. A live version of the API can be found [here](https://answercoalesce.renci.org/docs).


### Parameters 

Installation can be configured with the following parameters.


| Parameter | Description | Default |
| --------- | ----        | ----    | 
| `image.repository` |   | `renciorg/automat`
| `image.tag` |   | `2.0`
| `nameOverride` |   | `nil`
| `fullnameOverride` |   | `nil`
| `service.type` |   | `ClusterIP`
| `service.port` |   | `80`
| `fullHostName` |   | `nil`
| `ingress.host` |   | `nil`
| `ingress.class` |   | `default`
| `ingress.tls` |   | `nil`
| `app.port` |   | `8080`


| Parameter | Description | Default |
| --------- | ----        | ----    | 
| `replicaCount` |  Web server replica count | `1` 
| `ac.image.repository` |  Web server docker image | `renciorg/ac`
| `ac.image.tag` |  Web server docker tag | `latest`
| `ac.service.type` |  Web server kubernetes service type | `ClusterIP`
| `ac.service.port` | Web server kubernetes service port  | `80`
| `ac.containerPort` |  Web server port | `80`
| `redis.image.repository` |  Redis docker image | `redis`
| `redis.image.tag` | Redis docker image tag  | `latest`
| `redis.service.type` |  Redis server kubernetes service type | `ClusterIP`
| `redis.service.loadBalancerIP` |  Redis server kubernetes load balancer IP , used if `redis.service.type` = `LoadBalancerIP`   | `nil`
| `redis.service.port` |  Redis server kubernetes service port | `6379`
| `redis.containerPort` |  Redis server port | `6379`
| `redis.pvcName` | Redis storage pvc name  | `nil`
| `redis.seedDB` |  If true an Init container is started and waits for redis dump file to be copied to `/data/dump.rdb` of the container.  | `nil`
| `redis.createPV` | Boolean if  evaluated to true creates PV, If you use previously create PVC set this to false.  | `nil`
| `redis.createPVC` | Boolean if evaluated to true creates PVC , if using existing PVC please set to False  | `nil`
| `redis.storage.pvName` |  Name of the PV to create / previously created | `nil`
| `redis.storage.pvcName` | Name of PVC to create / previously created  | `nil`
| `redis.storage.size` | Size of storage to request from Kubernetes  | `nil`
| `redis.storage.class` | Kubernetes  Storage class to use for PV creation  | `nil`
| `nameOverride` | Release name override  | `nil`
| `fullnameOverride` | Release full name override  | `nil`
| `ingress.enabled` | Enables Ingress  | `True`
| `ingress.host` |  Ingress DNS host name  | ``
| `ingress.annotations` | Dictionary for Ingress annotations  | ``


### Installing


To deploy Answer coalesce : 
```shell script
<.../helm/answer-coalesce>$ helm -n <your-namespace> install my-release .
```

### Uninstalling
```shell script
<.../helm/answer-coalesce>$ helm uninstall myrelease
```

### Upgrading
```shell script
<.../helm/answer-coalesce>$ helm upgrade --set app.port=80 myrelease .
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


 