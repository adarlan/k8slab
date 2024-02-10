# K8sLab

Installing tfenv

```shell
git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile
```

Installing Terraform

```shell
tfenv install 1.7.3
tfenv use 1.7.3
```

Installing kubectl

```shell
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client   
```

Installing Argo CD CLI

```shell
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

Install Helm
https://helm.sh/docs/intro/install/

## TODO

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

## Testing Karpenter

apply a multi-replica deployment with CPU and memory requests that dont fit in the node group instance type

follow karpenter logs
kubectl logs -f -n karpenter

Whatch this in different windows
watch -n 1 -t kubectl get pods
watch -n 1 -t kubectl get nodes

Create the deployment with 5 replicas
kubectl apply -f deployment.yaml
