This Chart deploys a single instance of automat.

Chart configured in values.yaml to suite needs.

By default this chart uses `Loadbalancer` service type this can be overridden for other environment by setting values. 

Eg: To deploy local environment (minikube)
> $ helm install automat-helm --set service.type=NodePort ./

The above command will output set of shell commands that will let users easily discover the service. 
 
