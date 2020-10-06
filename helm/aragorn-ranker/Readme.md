ARAGORN Ranker helm Chart
---
> [Source code for ARAGORN Ranker](https://github.com/ranking-agent/aragorn-ranker.git)
>
> [Docker Image](https://hub.docker.com/repository/docker/renciorg/aragorn-ranker)

This Chart deploys a single instance of ARAGORN Ranker.

Chart configured in values.yaml to suite needs.

By default this chart uses `Loadbalancer` service type this can be overridden for other environment by setting values. 

Eg: To deploy local environment (minikube) , in this directory do 
> $ helm install aragorn-ranker-helm --set service.type=NodePort ./ 
 
