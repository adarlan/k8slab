```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add aquasecurity https://aquasecurity.github.io/helm-charts
helm repo add argo https://argoproj.github.io/argo-helm

watch -n 1 kubectl get pods --namespace ingress
watch -n 1 kubectl get pods --namespace monitoring
watch -n 1 kubectl get pods --namespace trivy
watch -n 1 kubectl get pods --namespace argocd

helm install ingress-nginx ingress-nginx/ingress-nginx \
--version 4.10.0 \
--values ingress-nginx/values.yaml \
--namespace ingress \
--create-namespace

helm install loki grafana/loki \
--version 5.43.3 \
--values loki/values.yaml \
--namespace monitoring \
--create-namespace

helm install promtail grafana/promtail \
--version 6.15.5 \
--values promtail/values.yaml \
--namespace monitoring

helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
--version 56.6.2 \
--values kube-prometheus-stack/values.yaml \
--namespace monitoring

helm install trivy-operator aquasecurity/trivy-operator \
--version 0.20.6 \
--values trivy-operator/values.yaml \
--namespace trivy \
--create-namespace

helm install argo-cd argo/argo-cd \
--version 6.4.1 \
--values argo-cd/values.yaml \
--namespace argocd \
--create-namespace

helm uninstall argo-cd --namespace argocd
helm uninstall trivy-operator --namespace trivy
helm uninstall kube-prometheus-stack --namespace monitoring
helm uninstall promtail --namespace monitoring
helm uninstall loki --namespace monitoring
helm uninstall ingress-nginx --namespace ingress
```
