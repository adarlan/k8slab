
```bash
kubectl config use-context k8slab-janeops
# kubectl apply -f toolkit-installer.yaml

KUBECTL_APPLYSET=true \
kubectl apply -n default --prune --applyset=toolkit-installer -f toolkit-installer.yaml

# echo $(kubectl get secret toolkit-installer-token -o jsonpath='{.data.token}' | base64 --decode)
# kubectl exec -it toolkit-installer -- ls /var/run/secrets/kubernetes.io/serviceaccount
# kubectl exec -it toolkit-installer -- cat /var/run/secrets/kubernetes.io/serviceaccount/token

# kubectl exec -it toolkit-installer -- sh
# curl -k -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc/api/v1/namespaces/default/pods
# curl -k -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc/api/v1/namespaces/default/services

# kubectl --token=$(kubectl get secret toolkit-installer-token -o jsonpath='{.data.token}' | base64 --decode) get pods

# kubectl get secret toolkit-installer-token -o jsonpath='{.data.token}' | base64 --decode > toolkit-installer.token
```

### kubeconfig

```bash
kubectl config set-credentials k8slab-toolkit-installer --token=$(kubectl get secret toolkit-installer-token -o jsonpath='{.data.token}' | base64 --decode)
kubectl config set-context k8slab-toolkit-installer --cluster=k8slab --user=k8slab-toolkit-installer --namespace=default
kubectl config use-context k8slab-toolkit-installer
kubectl auth can-i --list
```

<!-- FUNCTION clean -->
```bash
kubectl config use-context k8slab-janeops

KUBECTL_APPLYSET=true \
kubectl delete -n default --applyset=toolkit-installer -f toolkit-installer.yaml

# kubectl delete -f toolkit-installer.yaml

git clean -Xf
```
