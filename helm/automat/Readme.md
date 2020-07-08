Automat helm Chart
---
> [Source code for automat](https://github.com/TranslatorIIPrototypes/KITCHEN/tree/master/KITCHEN/Automat)
>
> [Docker Image](https://hub.docker.com/repository/docker/renciorg/automat)

This Chart deploys a single instance of automat.

Chart configured in values.yaml to suite needs.

By default this chart uses `Loadbalancer` service type this can be overridden for other environment by setting values. 

Eg: To deploy local environment (minikube) , in this directory do 
> $ helm install automat-helm --set service.type=NodePort ./ 
 
