# References

Argo CD Helm Chart Documentation
https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd

Argo CD Ingress Configuration
https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/

Automate deletion of AWS resources by using aws-nuke
https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/automate-deletion-of-aws-resources-by-using-aws-nuke.html

Deploy and Access the Kubernetes Dashboard
https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

GitHub Actions Best Practices
https://exercism.org/docs/building/github/gha-best-practices

Horizontal Pod Autoscaling
https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

NGINX Ingress Annotations
https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/annotations.md

##

App manifests > ingress rules
how to make host as a parameter? helm values? Can argocd set this?

https://kubernetes.io/docs/concepts/services-networking/ingress/#path-types

https://nickjanetakis.com/blog/configuring-a-kind-cluster-with-nginx-ingress-using-terraform-and-helm

terraform destroy... if the cluster is broken, terraform can not remove the helm releases
and terraform will not destroy the cluster before removing the helm releases
the cluster provisioning should be separate

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
