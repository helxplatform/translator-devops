ARAGORN helm Chart
---
> [Source code for ARAGORN](https://github.com/ranking-agent/aragorn.git)
>
> [Docker Image](https://hub.docker.com/repository/docker/renciorg/aragorn)

This Chart deploys a single instance of ARAGORN.

Chart configured in values.yaml to suite needs.

By default this chart uses `Loadbalancer` service type this can be overridden for other environment by setting values. 

Eg: To deploy local environment (minikube) , in this directory do 
> $ helm install aragorn-helm --set service.type=NodePort ./ 
 
