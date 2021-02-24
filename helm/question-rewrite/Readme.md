Question rewrite Helm Chart
---
> [Source code for QuestionRewrite](https://github.com/ranking-agent/QuestionRewrite)
>
> [Docker Image](https://hub.docker.com/repository/docker/renciorg/qrw)


### Introduction 

[Question rewrite](https://github.com/ranking-agent/QuestionRewrite) service accepts a translator reasoner standard message containing a question graph and returns a set of similar questions that may yield better answers.
A live version of the API can be found [here](https://questionaugmentation.renci.org/apidocs/).

### Parameters

Installation can be configured with the following parameters.

| Parameter | Description | Default |
| --------- | ----        | ----    | 
| `replicaCount` | Web server replica count  | `1`
| `image.repository` | Web server docker image   | `renciorg/qrw`
| `image.tag` |  Web server docker image tag | `latest`
| `nameOverride` |  Release name override | `nil`
| `fullnameOverride` |  Release full name override | `nil`
| `containerPort` | Web server port  | `6380`
| `service.type` |  Web server kubernetes service type | `ClusterIP`
| `service.port` |  Web server kubernetes service port | `80`
| `ingress.enabled` | Enables ingress  | `True`
| `ingress.annotations.kubernetes.io/ingress.class` | Ingress class  | `nil`
| `ingress.host` |  Ingress DNS entry | `nil`


### Installing 

Note:  Any of the above parameters can be overridden using set argument. 
```shell script
<.../helm/question-rewrite>$ helm install  myrelease . 
```

### Uninstalling
```shell script
<.../helm/question-rewrite>$ helm uninstall myrelease
```

### Upgrading
```shell script
<.../helm/question-rewrite>$ helm upgrade --set service.port=80 myrelease . 
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

