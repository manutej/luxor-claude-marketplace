# Kubernetes Orchestration

A comprehensive guide to mastering Kubernetes container orchestration for production-grade deployments.

## Quick Start

### Prerequisites

Before diving into Kubernetes, ensure you have:

- **Container Knowledge**: Understanding of Docker and containerization concepts
- **YAML Proficiency**: Ability to read and write YAML configuration files
- **Networking Basics**: TCP/IP, DNS, load balancing fundamentals
- **Linux Familiarity**: Command-line navigation and basic system administration
- **Cloud Concepts**: Understanding of cloud infrastructure (helpful but not required)

### Installation Options

#### 1. Minikube (Local Development)

Minikube runs a single-node Kubernetes cluster on your local machine.

```bash
# macOS
brew install minikube
minikube start

# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube start

# Windows (using PowerShell as Administrator)
choco install minikube
minikube start
```

**Configuration:**
```bash
# Start with custom resources
minikube start --cpus=4 --memory=8192 --disk-size=50g

# Enable addons
minikube addons enable ingress
minikube addons enable metrics-server
minikube addons enable dashboard
```

#### 2. Kind (Kubernetes in Docker)

Kind creates Kubernetes clusters using Docker containers as nodes.

```bash
# Install
brew install kind  # macOS
# or
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64  # Linux
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Create cluster
kind create cluster --name dev-cluster

# Multi-node cluster
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
EOF
```

#### 3. Amazon EKS (Elastic Kubernetes Service)

```bash
# Install eksctl
brew install eksctl  # macOS
# or
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Create cluster
eksctl create cluster \
  --name production-cluster \
  --region us-west-2 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed
```

#### 4. Google Kubernetes Engine (GKE)

```bash
# Install gcloud CLI
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init

# Create cluster
gcloud container clusters create production-cluster \
  --zone us-central1-a \
  --num-nodes 3 \
  --machine-type n1-standard-2 \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 5

# Get credentials
gcloud container clusters get-credentials production-cluster --zone us-central1-a
```

#### 5. Azure Kubernetes Service (AKS)

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login
az login

# Create resource group
az group create --name myResourceGroup --location eastus

# Create cluster
az aks create \
  --resource-group myResourceGroup \
  --name productionCluster \
  --node-count 3 \
  --enable-addons monitoring \
  --generate-ssh-keys

# Get credentials
az aks get-credentials --resource-group myResourceGroup --name productionCluster
```

### Installing kubectl

kubectl is the Kubernetes command-line tool.

```bash
# macOS
brew install kubectl

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Windows (PowerShell)
curl.exe -LO "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"

# Verify installation
kubectl version --client
```

### First Application Deployment

```bash
# Create a deployment
kubectl create deployment nginx --image=nginx:1.21

# Expose the deployment
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Check status
kubectl get deployments
kubectl get pods
kubectl get services

# View logs
kubectl logs -l app=nginx

# Scale the deployment
kubectl scale deployment nginx --replicas=3

# Delete resources
kubectl delete service nginx
kubectl delete deployment nginx
```

## Kubernetes Architecture

### Control Plane Components

The control plane manages the Kubernetes cluster and makes global decisions.

#### kube-apiserver

- **Function**: Front-end for the Kubernetes control plane
- **Responsibilities**:
  - Exposes the Kubernetes API
  - Processes REST operations
  - Validates and configures API objects
  - Serves as the gateway for all administrative tasks

#### etcd

- **Function**: Consistent and highly-available key-value store
- **Responsibilities**:
  - Stores all cluster data
  - Maintains cluster state
  - Provides the source of truth for the cluster
- **Characteristics**:
  - Distributed consensus using Raft algorithm
  - Strongly consistent
  - High availability through replication

#### kube-scheduler

- **Function**: Assigns Pods to nodes
- **Responsibilities**:
  - Watches for newly created Pods with no assigned node
  - Selects optimal node based on:
    - Resource requirements
    - Hardware/software constraints
    - Affinity/anti-affinity specifications
    - Data locality
    - Taints and tolerations

#### kube-controller-manager

- **Function**: Runs controller processes
- **Controllers Include**:
  - **Node Controller**: Monitors node health
  - **Replication Controller**: Maintains correct number of Pods
  - **Endpoints Controller**: Populates Endpoints objects
  - **Service Account Controller**: Creates default ServiceAccounts
  - **Namespace Controller**: Manages namespace lifecycle

#### cloud-controller-manager

- **Function**: Integrates with cloud provider APIs
- **Controllers Include**:
  - **Node Controller**: Checks cloud provider for node deletion
  - **Route Controller**: Sets up routes in cloud infrastructure
  - **Service Controller**: Creates/updates cloud load balancers

### Node Components

Node components run on every node, maintaining running Pods and providing the runtime environment.

#### kubelet

- **Function**: Primary node agent
- **Responsibilities**:
  - Registers node with API server
  - Ensures containers are running in Pods
  - Reports Pod and node status
  - Executes liveness and readiness probes
  - Manages volumes and secrets

#### kube-proxy

- **Function**: Network proxy
- **Responsibilities**:
  - Maintains network rules on nodes
  - Implements Services abstraction
  - Enables Pod-to-Pod and external communication
- **Modes**:
  - **iptables**: Default mode using iptables rules
  - **IPVS**: High-performance mode for large clusters
  - **userspace**: Legacy mode (rarely used)

#### Container Runtime

- **Function**: Software for running containers
- **Supported Runtimes**:
  - **containerd**: Default, lightweight runtime
  - **CRI-O**: OCI-compliant runtime
  - **Docker Engine**: Via dockershim (deprecated in 1.24+)

### Cluster Add-ons

Optional components that extend cluster functionality:

- **DNS**: CoreDNS for service discovery
- **Dashboard**: Web-based UI
- **Metrics Server**: Resource usage metrics
- **Ingress Controllers**: HTTP/HTTPS routing
- **CNI Plugins**: Network connectivity (Calico, Flannel, Weave)

## Common Deployment Patterns

### 1. Stateless Application Pattern

**Characteristics:**
- No persistent data storage
- Horizontally scalable
- Any Pod instance can handle any request
- Easy to replace and scale

**Example: Web Application**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: webapp:v1
        ports:
        - containerPort: 8080
        env:
        - name: ENV
          value: production
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

### 2. Stateful Application Pattern

**Characteristics:**
- Requires persistent storage
- Stable network identities
- Ordered deployment and scaling
- Data persistence across Pod restarts

**Example: Database Cluster**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres
spec:
  clusterIP: None
  selector:
    app: postgres
  ports:
  - port: 5432
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:14
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

### 3. Microservices Pattern

**Characteristics:**
- Multiple independent services
- Service mesh for communication
- API Gateway for external access
- Independent scaling and deployment

**Architecture:**

```
Internet → Ingress → API Gateway → Backend Services → Database
                                 ↓
                            Message Queue
```

### 4. Sidecar Pattern

**Characteristics:**
- Helper container alongside main container
- Shared resources (network, volumes)
- Common use cases: logging, monitoring, proxies

**Example: Logging Sidecar**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-sidecar
spec:
  containers:
  - name: app
    image: myapp:v1
    volumeMounts:
    - name: logs
      mountPath: /var/log/app
  - name: log-shipper
    image: fluent/fluentd:v1.15
    volumeMounts:
    - name: logs
      mountPath: /var/log/app
      readOnly: true
  volumes:
  - name: logs
    emptyDir: {}
```

### 5. Job and Batch Processing Pattern

**Characteristics:**
- Run-to-completion workloads
- Scheduled or triggered execution
- Parallel processing capabilities

**Example: Data Processing Job**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processor
spec:
  parallelism: 5
  completions: 10
  template:
    spec:
      containers:
      - name: processor
        image: data-processor:v1
        command: ["python", "process.py"]
      restartPolicy: OnFailure
```

## kubectl Commands Reference

### Cluster Management

```bash
# Cluster info
kubectl cluster-info
kubectl version
kubectl config view

# Context management
kubectl config get-contexts
kubectl config use-context <context-name>
kubectl config set-context <context-name> --namespace=<namespace>
```

### Resource Management

```bash
# Get resources
kubectl get pods
kubectl get deployments
kubectl get services
kubectl get nodes
kubectl get all  # All resources in namespace

# Get with output formats
kubectl get pods -o wide
kubectl get pods -o json
kubectl get pods -o yaml
kubectl get pods -o name

# Get with labels
kubectl get pods -l app=nginx
kubectl get pods -L app,version
kubectl get pods --show-labels

# Describe resources
kubectl describe pod <pod-name>
kubectl describe deployment <deployment-name>
kubectl describe node <node-name>
```

### Creating and Updating Resources

```bash
# Create from file
kubectl apply -f deployment.yaml
kubectl apply -f directory/
kubectl apply -k kustomize/

# Create from command
kubectl create deployment nginx --image=nginx:1.21
kubectl create service clusterip myapp --tcp=80:8080

# Update resources
kubectl set image deployment/nginx nginx=nginx:1.22
kubectl edit deployment nginx
kubectl patch deployment nginx -p '{"spec":{"replicas":5}}'

# Replace resource
kubectl replace -f deployment.yaml
kubectl replace --force -f deployment.yaml  # Delete and recreate
```

### Deleting Resources

```bash
# Delete specific resource
kubectl delete pod <pod-name>
kubectl delete deployment <deployment-name>
kubectl delete -f deployment.yaml

# Delete all resources
kubectl delete pods --all
kubectl delete all --all  # All resources in namespace

# Delete with label selector
kubectl delete pods -l app=nginx

# Force delete
kubectl delete pod <pod-name> --grace-period=0 --force
```

### Logs and Debugging

```bash
# View logs
kubectl logs <pod-name>
kubectl logs <pod-name> -c <container-name>
kubectl logs -f <pod-name>  # Follow logs
kubectl logs --previous <pod-name>  # Previous container instance
kubectl logs --tail=100 <pod-name>  # Last 100 lines
kubectl logs --since=1h <pod-name>  # Last hour

# Execute commands
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec <pod-name> -- ls /app
kubectl exec <pod-name> -c <container-name> -- env

# Port forwarding
kubectl port-forward pod/<pod-name> 8080:80
kubectl port-forward service/<service-name> 8080:80
kubectl port-forward deployment/<deployment-name> 8080:80

# Copy files
kubectl cp <pod-name>:/path/to/file ./local-file
kubectl cp ./local-file <pod-name>:/path/to/file
```

### Scaling and Rolling Updates

```bash
# Scale
kubectl scale deployment nginx --replicas=5
kubectl autoscale deployment nginx --min=2 --max=10 --cpu-percent=80

# Rolling updates
kubectl set image deployment/nginx nginx=nginx:1.22
kubectl rollout status deployment/nginx
kubectl rollout history deployment/nginx
kubectl rollout undo deployment/nginx
kubectl rollout undo deployment/nginx --to-revision=2

# Restart
kubectl rollout restart deployment/nginx
```

### Resource Monitoring

```bash
# Resource usage
kubectl top nodes
kubectl top pods
kubectl top pod <pod-name> --containers

# Events
kubectl get events
kubectl get events --sort-by='.lastTimestamp'
kubectl get events --field-selector involvedObject.name=<pod-name>

# Watch resources
kubectl get pods --watch
kubectl get pods -w
```

### Advanced Operations

```bash
# Label and annotate
kubectl label pods <pod-name> environment=production
kubectl label pods <pod-name> environment-  # Remove label
kubectl annotate pods <pod-name> description="Production pod"

# Taints and tolerations
kubectl taint nodes <node-name> key=value:NoSchedule
kubectl taint nodes <node-name> key:NoSchedule-  # Remove taint

# Cordon and drain
kubectl cordon <node-name>  # Mark unschedulable
kubectl drain <node-name>  # Evict pods
kubectl uncordon <node-name>  # Mark schedulable

# Debug
kubectl debug <pod-name> -it --image=ubuntu
kubectl debug node/<node-name> -it --image=ubuntu
kubectl run debug --rm -it --image=busybox -- sh
```

## Learning Path

### Beginner Level (Weeks 1-2)

**Objectives:**
- Understand basic Kubernetes concepts
- Deploy simple applications
- Perform basic operations

**Topics:**
1. Kubernetes architecture and components
2. Pods and containers
3. Deployments and ReplicaSets
4. Services (ClusterIP, NodePort)
5. Basic kubectl commands
6. YAML syntax and structure

**Practice:**
- Set up local Kubernetes cluster (Minikube/Kind)
- Deploy a simple web application
- Scale deployments
- Expose services
- View logs and debug issues

### Intermediate Level (Weeks 3-6)

**Objectives:**
- Work with configuration and storage
- Understand networking
- Implement basic security

**Topics:**
1. ConfigMaps and Secrets
2. Persistent Volumes and Claims
3. StatefulSets
4. Ingress controllers and rules
5. Namespaces and resource quotas
6. Basic RBAC
7. Health checks and probes
8. DaemonSets and Jobs

**Practice:**
- Deploy multi-tier applications
- Configure persistent storage
- Set up Ingress with TLS
- Implement resource quotas
- Create service accounts and roles
- Schedule batch jobs

### Advanced Level (Weeks 7-12)

**Objectives:**
- Production-grade deployments
- Advanced networking and security
- Monitoring and troubleshooting

**Topics:**
1. Advanced RBAC and network policies
2. Horizontal and Vertical Pod Autoscaling
3. Cluster autoscaling
4. Custom Resource Definitions (CRDs)
5. Operators and Helm charts
6. Service mesh (Istio, Linkerd)
7. Monitoring (Prometheus, Grafana)
8. Logging (ELK, Loki)
9. CI/CD integration
10. Disaster recovery and backups

**Practice:**
- Deploy production-grade applications
- Implement comprehensive monitoring
- Set up centralized logging
- Create custom operators
- Implement GitOps workflows
- Perform cluster upgrades
- Troubleshoot complex issues

### Expert Level (3-6 Months)

**Objectives:**
- Multi-cluster management
- Advanced troubleshooting
- Performance optimization
- Contribute to ecosystem

**Topics:**
1. Multi-cluster and multi-region deployments
2. Advanced networking (eBPF, Cilium)
3. Security hardening and compliance
4. Performance tuning and optimization
5. Capacity planning
6. Custom scheduler development
7. Contributing to Kubernetes

**Practice:**
- Manage multi-cluster environments
- Implement advanced security policies
- Optimize cluster performance
- Design highly available architectures
- Contribute to open-source projects

## Best Practices

### Resource Management
- Always set resource requests and limits
- Use namespaces for resource isolation
- Implement resource quotas and limit ranges

### Security
- Use RBAC for access control
- Implement network policies
- Scan images for vulnerabilities
- Use Pod Security Standards
- Rotate secrets regularly

### High Availability
- Run multiple replicas
- Use Pod Disruption Budgets
- Implement anti-affinity rules
- Design for failure

### Monitoring and Logging
- Implement comprehensive monitoring
- Centralize logs
- Set up alerting
- Monitor resource usage

### Configuration
- Use ConfigMaps for configuration
- Store secrets securely
- Version control manifests
- Use GitOps workflows

## Additional Resources

### Official Documentation
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)
- [API Reference](https://kubernetes.io/docs/reference/kubernetes-api/)

### Interactive Learning
- [Kubernetes Tutorials](https://kubernetes.io/docs/tutorials/)
- [Play with Kubernetes](https://labs.play-with-k8s.com/)
- [Katacoda Scenarios](https://www.katacoda.com/courses/kubernetes)

### Books
- "Kubernetes Up & Running" by Kelsey Hightower
- "The Kubernetes Book" by Nigel Poulton
- "Production Kubernetes" by Josh Rosso

### Community
- [Kubernetes Slack](https://slack.k8s.io/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/kubernetes)
- [Kubernetes Forums](https://discuss.kubernetes.io/)

### Certification
- Certified Kubernetes Administrator (CKA)
- Certified Kubernetes Application Developer (CKAD)
- Certified Kubernetes Security Specialist (CKS)

This guide provides a solid foundation for mastering Kubernetes. Start with the basics, practice regularly, and gradually progress to more advanced topics. Happy orchestrating!
