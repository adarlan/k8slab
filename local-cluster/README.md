# Local Cluster

## Create the cluster using `kind`

## Create the cluster using `terraform`

Use `terraform` to create a KinD (Kubernetes-in-Docker) cluster in your local environment.
You could use the `kind` CLI, but if you plan to use Terraform in production, maybe you should use it in development too.

```bash
tfenv install 1.7.3
tfenv use 1.7.3

terraform init

TF_LOG="INFO" terraform apply

TF_LOG="INFO" terraform destroy
```

## Increasing the maximum number of file system notification subscribers

Applications can use the `fs.inotify` Linux kernel subsystem to register for notifications when specific files or directories are modified, accessed, or deleted.
Let's increase the value of the `fs.inotify.max_user_instances` kernel parameter to prevent some containers in the monitoring stack from crashing due to "too many open files" while watching for changes in the log files.
Since both host and containers share the same kernel, configuring it on the host also applies to the Docker containers used as cluster nodes, and also to the containers running inside those nodes.
This value is reset when the system restarts.

```bash
# see the current value
sysctl fs.inotify.max_user_instances

# set a new value
sudo sysctl -w fs.inotify.max_user_instances=1024
```
