Reasoner (ontology) tools Helm Chart
---
> [Source code for Resoner(ontology) tools](https://github.com/ncats-tangerine/reasoner-tools)
>
> [Bionames Api Docker image](https://hub.docker.com/repository/docker/renciorg/green-bionames)
>
> [Onto Api Docker image](https://hub.docker.com/repository/docker/renciorg/green-onto_gunicorn)


The following chart deploys [reasoner tools](https://github.com/ncats-tangerine/reasoner-tools). There are 
two apps in that this deployment is capable deploying. 

To deploy Bionames : 
```shell script
$ helm -n <your-namespace> install onto-lookup --set image.repository=renciorg/green-bionames .
```

To deploy Onto: 
```shell script
$ helm -n <your-namespace> install onto-lookup --set image.repository=renciorg/green-onto_gunicorn .
```