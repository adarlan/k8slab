
## TODO

App manifests > ingress rules
how to make host as a parameter? helm values? Can argocd set this?

Argo CD ingress configuration
https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/

argo cd chart documentation
https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd

https://kubernetes.io/docs/concepts/services-networking/ingress/#path-types

https://nickjanetakis.com/blog/configuring-a-kind-cluster-with-nginx-ingress-using-terraform-and-helm

terraform destroy... if the cluster is broken, terraform can not remove the helm releases
and terraform will not destroy the cluster before removing the helm releases
the cluster provisioning should be separate

kubernetes dashboard

aws nuke

Horizontal Pod Autoscaling
https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

https://codefresh.io/blog/argo-cd-best-practices/

https://piotrminkowski.com/2022/06/28/manage-kubernetes-cluster-with-terraform-and-argo-cd/
https://www.youtube.com/watch?v=TrTRy8ahIHc
https://blog.saintmalik.me/argocd-on-kubernetes-cluster/
https://betterprogramming.pub/how-to-set-up-argo-cd-with-terraform-to-implement-pure-gitops-d5a1d797926a

TODO high availability argo cd for production

https://aws.github.io/aws-eks-best-practices/networking/subnets/
https://medium.com/@leocherian/amazon-eks-cluster-with-private-endpoint-e1c70ea1be5f

https://www.youtube.com/watch?v=qHGKO69hMlw

Testing Karpenter
apply a multi-replica deployment with CPU and memory requests that dont fit in the node group instance type
follow karpenter logs
kubectl logs -f -n karpenter
Whatch this in different windows
watch -n 1 -t kubectl get pods
watch -n 1 -t kubectl get nodes
Create the deployment with 5 replicas
kubectl apply -f deployment.yaml
