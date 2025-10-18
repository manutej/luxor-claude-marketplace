# Kubernetes Orchestration Examples

This document provides production-ready examples demonstrating Kubernetes patterns and best practices.

## Table of Contents

1. [Rolling Update Deployment](#1-rolling-update-deployment)
2. [StatefulSet for Database Cluster](#2-statefulset-for-database-cluster)
3. [Ingress with TLS Termination](#3-ingress-with-tls-termination)
4. [ConfigMap and Secret Management](#4-configmap-and-secret-management)
5. [PersistentVolume and PVC Setup](#5-persistentvolume-and-pvc-setup)
6. [RBAC Configuration](#6-rbac-configuration)
7. [Horizontal Pod Autoscaler](#7-horizontal-pod-autoscaler)
8. [DaemonSet for Log Collection](#8-daemonset-for-log-collection)
9. [CronJob for Scheduled Tasks](#9-cronjob-for-scheduled-tasks)
10. [Multi-Container Pod with Sidecar](#10-multi-container-pod-with-sidecar)
11. [Init Container Pattern](#11-init-container-pattern)
12. [Service Mesh with Ambassador Pattern](#12-service-mesh-with-ambassador-pattern)
13. [Blue-Green Deployment](#13-blue-green-deployment)
14. [Canary Deployment](#14-canary-deployment)
15. [Network Policy for Security](#15-network-policy-for-security)
16. [Resource Quotas and Limits](#16-resource-quotas-and-limits)
17. [Pod Disruption Budget](#17-pod-disruption-budget)
18. [Job for Batch Processing](#18-job-for-batch-processing)
19. [Multi-Tier Application Stack](#19-multi-tier-application-stack)
20. [Monitoring with Prometheus](#20-monitoring-with-prometheus)

---

## 1. Rolling Update Deployment

**Description:** Demonstrates zero-downtime deployments with rolling update strategy.

**Use Case:** Deploy new application versions without service interruption, automatically rolling back on failure.

**Complete YAML:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-rolling
  namespace: production
  labels:
    app: web-app
    version: v2.0
  annotations:
    kubernetes.io/change-cause: "Update to version 2.0 with new features"
spec:
  replicas: 5
  revisionHistoryLimit: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2        # Max 2 additional pods during update
      maxUnavailable: 1  # Max 1 pod can be unavailable
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
        version: v2.0
    spec:
      containers:
      - name: web-app
        image: myregistry.io/web-app:v2.0
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
        env:
        - name: APP_ENV
          value: "production"
        - name: LOG_LEVEL
          value: "info"
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 1000m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 3
        lifecycle:
          preStop:
            exec:
              command: ["/bin/sh", "-c", "sleep 15"]
---
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
  namespace: production
spec:
  type: ClusterIP
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
    name: http
  sessionAffinity: None
```

**Explanation:**
- `maxSurge: 2` allows 2 extra pods during updates (7 total instead of 5)
- `maxUnavailable: 1` ensures at least 4 pods remain available during updates
- `revisionHistoryLimit: 10` keeps the last 10 ReplicaSets for rollback
- Liveness probe ensures unhealthy pods are restarted
- Readiness probe prevents traffic to pods that aren't ready
- `preStop` hook allows graceful shutdown with 15-second delay
- Service maintains stable endpoint while pods are updated

**Operations:**
```bash
# Apply the deployment
kubectl apply -f rolling-deployment.yaml

# Watch the rollout
kubectl rollout status deployment/web-app-rolling -n production

# View rollout history
kubectl rollout history deployment/web-app-rolling -n production

# Rollback to previous version
kubectl rollout undo deployment/web-app-rolling -n production

# Rollback to specific revision
kubectl rollout undo deployment/web-app-rolling --to-revision=3 -n production
```

---

## 2. StatefulSet for Database Cluster

**Description:** Deploys a PostgreSQL cluster with stable network identities and persistent storage.

**Use Case:** Running stateful applications like databases that require stable hostnames and persistent data.

**Complete YAML:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-headless
  namespace: databases
  labels:
    app: postgres
spec:
  clusterIP: None
  ports:
  - port: 5432
    targetPort: 5432
    name: postgres
  selector:
    app: postgres
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-read
  namespace: databases
  labels:
    app: postgres
    type: read
spec:
  type: ClusterIP
  ports:
  - port: 5432
    targetPort: 5432
    name: postgres
  selector:
    app: postgres
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: databases
spec:
  serviceName: postgres-headless
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  updateStrategy:
    type: RollingUpdate
  podManagementPolicy: OrderedReady
  template:
    metadata:
      labels:
        app: postgres
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - postgres
            topologyKey: kubernetes.io/hostname
      securityContext:
        runAsUser: 999
        fsGroup: 999
      containers:
      - name: postgres
        image: postgres:14-alpine
        ports:
        - containerPort: 5432
          name: postgres
        env:
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        - name: POSTGRES_USER
          value: "postgres"
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 2000m
            memory: 2Gi
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
        - name: config
          mountPath: /etc/postgresql/postgresql.conf
          subPath: postgresql.conf
        livenessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - pg_isready -U postgres -h 127.0.0.1
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - pg_isready -U postgres -h 127.0.0.1
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
      volumes:
      - name: config
        configMap:
          name: postgres-config
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 50Gi
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-config
  namespace: databases
data:
  postgresql.conf: |
    max_connections = 200
    shared_buffers = 512MB
    effective_cache_size = 1536MB
    maintenance_work_mem = 128MB
    checkpoint_completion_target = 0.9
    wal_buffers = 16MB
    default_statistics_target = 100
    random_page_cost = 1.1
    effective_io_concurrency = 200
    work_mem = 2621kB
    min_wal_size = 1GB
    max_wal_size = 4GB
---
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
  namespace: databases
type: Opaque
stringData:
  password: "your-secure-password-here"
```

**Explanation:**
- Headless service provides stable DNS names: `postgres-0.postgres-headless`, `postgres-1.postgres-headless`, etc.
- `podAntiAffinity` ensures pods run on different nodes for high availability
- `OrderedReady` ensures pods are created/updated sequentially
- Each pod gets its own PersistentVolumeClaim from `volumeClaimTemplates`
- ConfigMap provides PostgreSQL configuration
- Security context runs containers as postgres user (UID 999)
- Probes use `pg_isready` to verify database availability

**Access Patterns:**
```bash
# Connect to specific pod
kubectl exec -it postgres-0 -n databases -- psql -U postgres

# Connect to any read replica
psql -h postgres-read.databases.svc.cluster.local -U postgres

# Scale the StatefulSet
kubectl scale statefulset postgres --replicas=5 -n databases
```

---

## 3. Ingress with TLS Termination

**Description:** Configures Ingress with automatic TLS certificate management and path-based routing.

**Use Case:** Expose multiple services through a single load balancer with HTTPS encryption.

**Complete YAML:**

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: web-apps
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-app-ingress
  namespace: web-apps
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/limit-rps: "10"
    nginx.ingress.kubernetes.io/enable-cors: "true"
    nginx.ingress.kubernetes.io/cors-allow-origin: "https://example.com"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - www.example.com
    - api.example.com
    - admin.example.com
    secretName: example-tls-cert
  rules:
  - host: www.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
  - host: api.example.com
    http:
      paths:
      - path: /v1
        pathType: Prefix
        backend:
          service:
            name: api-v1-service
            port:
              number: 8080
      - path: /v2
        pathType: Prefix
        backend:
          service:
            name: api-v2-service
            port:
              number: 8080
  - host: admin.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: admin-service
            port:
              number: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: web-apps
spec:
  type: ClusterIP
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: api-v1-service
  namespace: web-apps
spec:
  type: ClusterIP
  selector:
    app: api
    version: v1
  ports:
  - port: 8080
    targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: api-v2-service
  namespace: web-apps
spec:
  type: ClusterIP
  selector:
    app: api
    version: v2
  ports:
  - port: 8080
    targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: admin-service
  namespace: web-apps
spec:
  type: ClusterIP
  selector:
    app: admin
  ports:
  - port: 3000
    targetPort: 3000
---
# cert-manager ClusterIssuer for Let's Encrypt
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-prod-key
    solvers:
    - http01:
        ingress:
          class: nginx
```

**Explanation:**
- `cert-manager` automatically provisions and renews TLS certificates from Let's Encrypt
- Path-based routing directs traffic to different services based on URL path
- NGINX annotations enable SSL redirect, CORS, rate limiting, and other features
- Each host can have multiple paths pointing to different backend services
- ClusterIssuer automates certificate management using ACME protocol
- `ssl-redirect` ensures all HTTP traffic is redirected to HTTPS

**Testing:**
```bash
# Check Ingress status
kubectl get ingress -n web-apps
kubectl describe ingress multi-app-ingress -n web-apps

# Test endpoints
curl https://www.example.com
curl https://api.example.com/v1/health
curl https://admin.example.com

# Check certificate
kubectl get certificate -n web-apps
kubectl describe certificate example-tls-cert -n web-apps
```

---

## 4. ConfigMap and Secret Management

**Description:** Demonstrates various methods of injecting configuration and secrets into applications.

**Use Case:** Separate configuration from application code, manage sensitive data securely.

**Complete YAML:**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: production
data:
  # Simple key-value pairs
  database.host: "postgres.databases.svc.cluster.local"
  database.port: "5432"
  database.name: "myapp"
  log.level: "INFO"
  cache.ttl: "3600"

  # Configuration file
  app.properties: |
    server.port=8080
    server.max-threads=200
    feature.new-ui=enabled
    feature.beta=disabled

  # JSON configuration
  settings.json: |
    {
      "timeout": 30,
      "retries": 3,
      "endpoints": {
        "primary": "https://api.example.com",
        "fallback": "https://api-backup.example.com"
      }
    }
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: production
type: Opaque
stringData:
  # Database credentials
  db.username: "app_user"
  db.password: "super-secret-password"

  # API keys
  stripe.api.key: "sk_live_xxxxxxxxxxxx"
  sendgrid.api.key: "SG.xxxxxxxxxxxx"

  # OAuth credentials
  oauth.client.id: "client-id-here"
  oauth.client.secret: "client-secret-here"

  # Connection strings
  redis.url: "redis://redis-master.databases.svc.cluster.local:6379"
  mongodb.uri: "mongodb://user:password@mongo-0.mongo.databases.svc.cluster.local:27017,mongo-1.mongo.databases.svc.cluster.local:27017,mongo-2.mongo.databases.svc.cluster.local:27017/myapp?replicaSet=rs0"
---
apiVersion: v1
kind: Secret
metadata:
  name: tls-certs
  namespace: production
type: kubernetes.io/tls
stringData:
  tls.crt: |
    -----BEGIN CERTIFICATE-----
    MIIDXTCCAkWgAwIBAgIJAKJ...
    -----END CERTIFICATE-----
  tls.key: |
    -----BEGIN PRIVATE KEY-----
    MIIEvQIBADANBgkqhkiG9w0...
    -----END PRIVATE KEY-----
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-config
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: app
        image: myapp:v1.0
        ports:
        - containerPort: 8080

        # Environment variables from ConfigMap
        env:
        - name: DATABASE_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database.host
        - name: DATABASE_PORT
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database.port
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: log.level

        # Environment variables from Secret
        - name: DATABASE_USERNAME
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: db.username
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: db.password
        - name: STRIPE_API_KEY
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: stripe.api.key

        # All ConfigMap keys as environment variables
        envFrom:
        - configMapRef:
            name: app-config
        - secretRef:
            name: app-secrets

        volumeMounts:
        # Mount ConfigMap as files
        - name: config-volume
          mountPath: /etc/config
          readOnly: true

        # Mount Secret as files
        - name: secret-volume
          mountPath: /etc/secrets
          readOnly: true

        # Mount specific ConfigMap key as file
        - name: app-properties
          mountPath: /app/config/application.properties
          subPath: app.properties
          readOnly: true

        # Mount TLS certificates
        - name: tls-volume
          mountPath: /etc/tls
          readOnly: true

      volumes:
      # ConfigMap volume
      - name: config-volume
        configMap:
          name: app-config

      # Secret volume
      - name: secret-volume
        secret:
          secretName: app-secrets
          defaultMode: 0400  # Read-only for owner

      # Specific ConfigMap key
      - name: app-properties
        configMap:
          name: app-config
          items:
          - key: app.properties
            path: app.properties

      # TLS Secret
      - name: tls-volume
        secret:
          secretName: tls-certs
```

**Explanation:**
- ConfigMaps store non-sensitive configuration data in key-value format
- Secrets store sensitive data with base64 encoding
- Multiple injection methods: environment variables, volume mounts, or both
- `envFrom` imports all keys from ConfigMap/Secret as environment variables
- `subPath` mounts specific keys as individual files without overwriting directory
- `defaultMode: 0400` sets file permissions for secrets (read-only)
- Volume mounts allow applications to reload configuration without restarts

**Operations:**
```bash
# Create Secret from file
kubectl create secret generic tls-certs \
  --from-file=tls.crt=./cert.pem \
  --from-file=tls.key=./key.pem \
  -n production

# Create Secret from literal
kubectl create secret generic db-password \
  --from-literal=password='myP@ssw0rd' \
  -n production

# Update ConfigMap (triggers rolling update if mounted as volume)
kubectl create configmap app-config \
  --from-file=app.properties \
  --dry-run=client -o yaml | kubectl apply -f -

# View Secret (base64 encoded)
kubectl get secret app-secrets -o yaml -n production

# Decode Secret value
kubectl get secret app-secrets -n production -o jsonpath='{.data.db\.password}' | base64 --decode
```

---

## 5. PersistentVolume and PVC Setup

**Description:** Configures storage with different access modes and StorageClasses.

**Use Case:** Provide persistent storage for stateful applications with various performance characteristics.

**Complete YAML:**

```yaml
# StorageClass for fast SSD storage
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
  annotations:
    storageclass.kubernetes.io/is-default-class: "false"
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
  encrypted: "true"
  fsType: ext4
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
reclaimPolicy: Retain
---
# StorageClass for standard HDD storage
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard-hdd
provisioner: kubernetes.io/aws-ebs
parameters:
  type: st1
  encrypted: "true"
volumeBindingMode: Immediate
allowVolumeExpansion: true
reclaimPolicy: Delete
---
# StorageClass for NFS shared storage
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-shared
provisioner: example.com/nfs
parameters:
  server: nfs-server.example.com
  path: /exports
  readOnly: "false"
volumeBindingMode: Immediate
allowVolumeExpansion: false
reclaimPolicy: Retain
---
# Manual PersistentVolume (hostPath for development)
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-local-storage
  labels:
    type: local
    environment: development
spec:
  capacity:
    storage: 10Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/data
    type: DirectoryOrCreate
---
# NFS PersistentVolume
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs-shared
  labels:
    type: nfs
    tier: shared
spec:
  capacity:
    storage: 100Gi
  accessModes:
  - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: nfs-shared
  nfs:
    server: nfs-server.example.com
    path: /exports/shared
    readOnly: false
---
# PVC for database with fast SSD
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: database-pvc
  namespace: databases
  labels:
    app: postgres
    tier: database
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 50Gi
---
# PVC for file uploads with standard storage
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: uploads-pvc
  namespace: production
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: standard-hdd
  resources:
    requests:
      storage: 200Gi
---
# PVC for shared media with ReadWriteMany
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: shared-media-pvc
  namespace: production
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: nfs-shared
  resources:
    requests:
      storage: 500Gi
---
# Deployment using PVC
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-storage
  namespace: production
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: app
        image: myapp:v1.0
        volumeMounts:
        - name: data
          mountPath: /app/data
        - name: uploads
          mountPath: /app/uploads
        - name: shared
          mountPath: /app/shared
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: database-pvc
      - name: uploads
        persistentVolumeClaim:
          claimName: uploads-pvc
      - name: shared
        persistentVolumeClaim:
          claimName: shared-media-pvc
---
# StatefulSet with VolumeClaimTemplates
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
  namespace: production
spec:
  serviceName: nginx
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 10Gi
```

**Explanation:**
- **StorageClass** defines storage types with different performance/cost profiles
- `volumeBindingMode: WaitForFirstConsumer` delays volume binding until pod is scheduled
- `allowVolumeExpansion: true` enables dynamic volume resizing
- `reclaimPolicy: Retain` preserves data after PVC deletion
- **Access Modes**:
  - `ReadWriteOnce` (RWO): Single node read-write
  - `ReadWriteMany` (RWX): Multiple nodes read-write
  - `ReadOnlyMany` (ROX): Multiple nodes read-only
- `volumeClaimTemplates` in StatefulSet creates unique PVC for each pod

**Operations:**
```bash
# List StorageClasses
kubectl get storageclass

# Create PVC
kubectl apply -f pvc.yaml

# Check PVC status
kubectl get pvc -n production
kubectl describe pvc database-pvc -n production

# List PVs
kubectl get pv

# Expand PVC (if allowVolumeExpansion is true)
kubectl patch pvc database-pvc -n production -p '{"spec":{"resources":{"requests":{"storage":"100Gi"}}}}'

# Check volume usage
kubectl exec -it <pod-name> -n production -- df -h /app/data
```

---

## 6. RBAC Configuration

**Description:** Implements Role-Based Access Control for secure cluster access.

**Use Case:** Grant appropriate permissions to users, service accounts, and applications while following least privilege principle.

**Complete YAML:**

```yaml
# Namespace for development team
apiVersion: v1
kind: Namespace
metadata:
  name: dev-team
---
# ServiceAccount for applications
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-service-account
  namespace: dev-team
---
# Role for pod management (namespace-scoped)
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-manager
  namespace: dev-team
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create"]
- apiGroups: [""]
  resources: ["pods/portforward"]
  verbs: ["create"]
---
# Role for deployment management
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployment-manager
  namespace: dev-team
rules:
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments/scale"]
  verbs: ["update"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
---
# Role for read-only access
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: viewer
  namespace: dev-team
rules:
- apiGroups: ["", "apps", "batch"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get", "list"]
---
# ClusterRole for cluster-wide node viewing
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["nodes/status"]
  verbs: ["get"]
---
# ClusterRole for namespace management
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: namespace-admin
rules:
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["resourcequotas", "limitranges"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
# ClusterRole for monitoring
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring
rules:
- apiGroups: [""]
  resources: ["nodes", "nodes/metrics", "services", "endpoints", "pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
---
# RoleBinding for developer user
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-pod-manager
  namespace: dev-team
subjects:
- kind: User
  name: john@example.com
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-manager
  apiGroup: rbac.authorization.k8s.io
---
# RoleBinding for service account
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-deployment-manager
  namespace: dev-team
subjects:
- kind: ServiceAccount
  name: app-service-account
  namespace: dev-team
roleRef:
  kind: Role
  name: deployment-manager
  apiGroup: rbac.authorization.k8s.io
---
# RoleBinding for group
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-team-viewers
  namespace: dev-team
subjects:
- kind: Group
  name: dev-team-members
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: viewer
  apiGroup: rbac.authorization.k8s.io
---
# ClusterRoleBinding for cluster-wide access
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ops-team-node-readers
subjects:
- kind: Group
  name: ops-team
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: node-reader
  apiGroup: rbac.authorization.k8s.io
---
# ClusterRoleBinding for monitoring service account
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus-monitoring
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: monitoring
roleRef:
  kind: ClusterRole
  name: monitoring
  apiGroup: rbac.authorization.k8s.io
---
# Pod using ServiceAccount with RBAC
apiVersion: v1
kind: Pod
metadata:
  name: app-with-rbac
  namespace: dev-team
spec:
  serviceAccountName: app-service-account
  containers:
  - name: app
    image: myapp:v1.0
    env:
    - name: KUBERNETES_NAMESPACE
      valueFrom:
        fieldRef:
          fieldPath: metadata.namespace
```

**Explanation:**
- **Role** grants permissions within a specific namespace
- **ClusterRole** grants permissions cluster-wide
- **RoleBinding** binds Role to subjects (users, groups, service accounts) in a namespace
- **ClusterRoleBinding** binds ClusterRole to subjects cluster-wide
- Subjects can be Users, Groups, or ServiceAccounts
- `verbs` define allowed actions: get, list, watch, create, update, patch, delete
- ServiceAccounts enable pods to interact with the Kubernetes API

**Testing:**
```bash
# Check permissions for user
kubectl auth can-i create pods --namespace=dev-team --as=john@example.com

# Check permissions for service account
kubectl auth can-i list deployments --namespace=dev-team --as=system:serviceaccount:dev-team:app-service-account

# View role bindings
kubectl get rolebindings -n dev-team
kubectl describe rolebinding developer-pod-manager -n dev-team

# View cluster role bindings
kubectl get clusterrolebindings
kubectl describe clusterrolebinding ops-team-node-readers

# Test from within pod
kubectl exec -it app-with-rbac -n dev-team -- sh
# Inside pod:
# kubectl get pods -n dev-team
```

---

## 7. Horizontal Pod Autoscaler

**Description:** Automatically scales pods based on CPU, memory, and custom metrics.

**Use Case:** Handle variable traffic patterns efficiently by dynamically adjusting pod count.

**Complete YAML:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-autoscale
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: myapp:v1.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 1000m
            memory: 512Mi
---
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
  namespace: production
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app-autoscale
  minReplicas: 3
  maxReplicas: 20
  metrics:
  # CPU utilization
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  # Memory utilization
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  # Custom metric: HTTP requests per second
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "1000"
  # External metric: SQS queue depth
  - type: External
    external:
      metric:
        name: sqs_queue_depth
        selector:
          matchLabels:
            queue_name: work-queue
      target:
        type: Value
        value: "30"
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300  # Wait 5 minutes before scaling down
      policies:
      - type: Percent
        value: 50  # Scale down max 50% of pods
        periodSeconds: 60
      - type: Pods
        value: 2  # Or scale down max 2 pods
        periodSeconds: 60
      selectPolicy: Min  # Choose the policy that scales down the least
    scaleUp:
      stabilizationWindowSeconds: 0  # Scale up immediately
      policies:
      - type: Percent
        value: 100  # Scale up max 100% of pods (double)
        periodSeconds: 30
      - type: Pods
        value: 4  # Or scale up max 4 pods
        periodSeconds: 30
      selectPolicy: Max  # Choose the policy that scales up the most
```

**Explanation:**
- HPA requires metrics-server to be installed in the cluster
- `minReplicas: 3` ensures high availability even during low traffic
- `maxReplicas: 20` sets an upper bound to control costs
- Multiple metrics can trigger scaling (CPU, memory, custom, external)
- `behavior` section controls scaling speed and stability
- `stabilizationWindowSeconds` prevents flapping
- `selectPolicy` determines which policy to use when multiple apply
- Resource requests must be set for CPU/memory-based autoscaling

**Operations:**
```bash
# Check HPA status
kubectl get hpa -n production
kubectl describe hpa web-app-hpa -n production

# Watch HPA in real-time
kubectl get hpa -n production --watch

# Generate load to test autoscaling
kubectl run -it --rm load-generator --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://web-app-service; done"

# Check metrics
kubectl top pods -n production
kubectl top nodes

# View HPA events
kubectl get events --field-selector involvedObject.name=web-app-hpa -n production
```

---

## 8. DaemonSet for Log Collection

**Description:** Deploys a log collection agent on every node in the cluster.

**Use Case:** Centralize application and system logs from all nodes for analysis and troubleshooting.

**Complete YAML:**

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: logging
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fluentd
  namespace: logging
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: fluentd
rules:
- apiGroups: [""]
  resources: ["pods", "namespaces"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: fluentd
subjects:
- kind: ServiceAccount
  name: fluentd
  namespace: logging
roleRef:
  kind: ClusterRole
  name: fluentd
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
  namespace: logging
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      read_from_head true
      <parse>
        @type json
        time_format %Y-%m-%dT%H:%M:%S.%NZ
      </parse>
    </source>

    <filter kubernetes.**>
      @type kubernetes_metadata
      @id filter_kube_metadata
    </filter>

    <filter kubernetes.**>
      @type record_transformer
      <record>
        cluster_name "#{ENV['CLUSTER_NAME']}"
        environment "#{ENV['ENVIRONMENT']}"
      </record>
    </filter>

    <match kubernetes.**>
      @type elasticsearch
      host "#{ENV['ELASTICSEARCH_HOST']}"
      port "#{ENV['ELASTICSEARCH_PORT']}"
      logstash_format true
      logstash_prefix kubernetes
      <buffer>
        @type file
        path /var/log/fluentd-buffers/kubernetes.buffer
        flush_mode interval
        retry_type exponential_backoff
        flush_thread_count 2
        flush_interval 5s
        retry_forever false
        retry_max_interval 30
        chunk_limit_size 2M
        queue_limit_length 8
        overflow_action block
      </buffer>
    </match>
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: logging
  labels:
    app: fluentd
    version: v1
spec:
  selector:
    matchLabels:
      app: fluentd
      version: v1
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  template:
    metadata:
      labels:
        app: fluentd
        version: v1
    spec:
      serviceAccountName: fluentd
      tolerations:
      # Run on master nodes too
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      - key: node-role.kubernetes.io/control-plane
        effect: NoSchedule
      containers:
      - name: fluentd
        image: fluent/fluentd-kubernetes-daemonset:v1.15-debian-elasticsearch7-1
        env:
        - name: ELASTICSEARCH_HOST
          value: "elasticsearch.logging.svc.cluster.local"
        - name: ELASTICSEARCH_PORT
          value: "9200"
        - name: CLUSTER_NAME
          value: "production-cluster"
        - name: ENVIRONMENT
          value: "production"
        - name: FLUENT_ELASTICSEARCH_SED_DISABLE
          value: "true"
        resources:
          requests:
            cpu: 100m
            memory: 200Mi
          limits:
            cpu: 500m
            memory: 500Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
          readOnly: true
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: config-volume
          mountPath: /fluentd/etc/fluent.conf
          subPath: fluent.conf
        - name: buffer
          mountPath: /var/log/fluentd-buffers
      terminationGracePeriodSeconds: 30
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
          type: Directory
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
          type: Directory
      - name: config-volume
        configMap:
          name: fluentd-config
      - name: buffer
        emptyDir: {}
```

**Explanation:**
- DaemonSet ensures one fluentd pod runs on each node
- `tolerations` allow pods to run on master/control-plane nodes
- Host path volumes access container logs from node filesystem
- ConfigMap provides fluentd configuration
- RBAC permissions enable metadata enrichment
- `updateStrategy: RollingUpdate` updates one node at a time
- Elasticsearch is used as the log aggregation backend

**Verification:**
```bash
# Check DaemonSet status
kubectl get daemonset -n logging
kubectl describe daemonset fluentd -n logging

# Verify pods on all nodes
kubectl get pods -n logging -o wide

# Check logs from fluentd
kubectl logs -n logging -l app=fluentd --tail=50

# Test log collection
kubectl run test-logger --image=busybox --restart=Never -- sh -c 'for i in $(seq 1 100); do echo "Log message $i"; sleep 1; done'
```

---

## 9. CronJob for Scheduled Tasks

**Description:** Runs automated backup jobs on a daily schedule.

**Use Case:** Perform regular maintenance tasks like database backups, report generation, or data cleanup.

**Complete YAML:**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: database-backup
  namespace: databases
spec:
  # Run daily at 2 AM UTC
  schedule: "0 2 * * *"
  timeZone: "UTC"
  # Keep last 3 successful and 1 failed job history
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  # Don't start new job if previous is still running
  concurrencyPolicy: Forbid
  # Start job within 5 minutes of scheduled time or skip
  startingDeadlineSeconds: 300
  # Suspend execution (useful for maintenance)
  suspend: false
  jobTemplate:
    metadata:
      labels:
        app: backup
        type: database
    spec:
      # Keep completed job for 1 hour
      ttlSecondsAfterFinished: 3600
      # Retry up to 3 times on failure
      backoffLimit: 3
      # Pod template
      template:
        metadata:
          labels:
            app: backup
            type: database
        spec:
          restartPolicy: OnFailure
          serviceAccountName: backup-sa
          containers:
          - name: backup
            image: postgres:14-alpine
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - |
              set -e
              echo "Starting backup at $(date)"

              # Create backup directory with timestamp
              BACKUP_DIR="/backup/$(date +%Y%m%d-%H%M%S)"
              mkdir -p "$BACKUP_DIR"

              # Perform database backup
              pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME -F c -f "$BACKUP_DIR/backup.dump"

              # Compress backup
              gzip "$BACKUP_DIR/backup.dump"

              # Create manifest file
              cat > "$BACKUP_DIR/manifest.json" <<EOF
              {
                "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
                "database": "$DB_NAME",
                "size": "$(stat -f%z "$BACKUP_DIR/backup.dump.gz")",
                "checksum": "$(md5sum "$BACKUP_DIR/backup.dump.gz" | cut -d' ' -f1)"
              }
              EOF

              # Delete backups older than 7 days
              find /backup -type d -mtime +7 -exec rm -rf {} +

              echo "Backup completed successfully at $(date)"
            env:
            - name: DB_HOST
              value: "postgres.databases.svc.cluster.local"
            - name: DB_NAME
              value: "production_db"
            - name: DB_USER
              valueFrom:
                secretKeyRef:
                  name: postgres-credentials
                  key: username
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-credentials
                  key: password
            - name: TZ
              value: "UTC"
            resources:
              requests:
                cpu: 500m
                memory: 512Mi
              limits:
                cpu: 2000m
                memory: 2Gi
            volumeMounts:
            - name: backup-storage
              mountPath: /backup
          volumes:
          - name: backup-storage
            persistentVolumeClaim:
              claimName: backup-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: backup-pvc
  namespace: databases
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: standard-hdd
  resources:
    requests:
      storage: 500Gi
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: backup-sa
  namespace: databases
---
apiVersion: v1
kind: Secret
metadata:
  name: postgres-credentials
  namespace: databases
type: Opaque
stringData:
  username: "backup_user"
  password: "secure-password-here"
---
# Additional CronJob for weekly report generation
apiVersion: batch/v1
kind: CronJob
metadata:
  name: weekly-report
  namespace: analytics
spec:
  # Run every Monday at 8 AM
  schedule: "0 8 * * 1"
  timeZone: "America/New_York"
  successfulJobsHistoryLimit: 4
  failedJobsHistoryLimit: 2
  concurrencyPolicy: Replace
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: Never
          containers:
          - name: report-generator
            image: report-tool:v2.0
            command: ["python", "/app/generate_report.py"]
            args:
            - "--format=pdf"
            - "--period=weekly"
            - "--email=team@example.com"
            resources:
              requests:
                cpu: 1000m
                memory: 1Gi
              limits:
                cpu: 2000m
                memory: 2Gi
```

**Explanation:**
- `schedule` uses cron syntax: minute hour day month weekday
- `concurrencyPolicy: Forbid` prevents overlapping job executions
- `startingDeadlineSeconds` defines how late a job can start
- `ttlSecondsAfterFinished` automatically cleans up completed jobs
- `backoffLimit` controls retry attempts on failure
- PersistentVolume stores backups with retention policy
- ServiceAccount provides necessary permissions
- Secrets securely inject database credentials

**Schedule Examples:**
```
"0 */6 * * *"      # Every 6 hours
"30 3 * * *"       # Daily at 3:30 AM
"0 0 * * 0"        # Weekly on Sunday at midnight
"0 0 1 * *"        # Monthly on the 1st at midnight
"*/15 * * * *"     # Every 15 minutes
"0 9-17 * * 1-5"   # Hourly during business hours (9 AM-5 PM, Mon-Fri)
```

**Operations:**
```bash
# View CronJobs
kubectl get cronjobs -n databases

# Manually trigger a CronJob
kubectl create job --from=cronjob/database-backup manual-backup-1 -n databases

# View job history
kubectl get jobs -n databases
kubectl describe job database-backup-<timestamp> -n databases

# View pod logs from job
kubectl logs -l job-name=database-backup-<timestamp> -n databases

# Suspend CronJob (no new jobs will be created)
kubectl patch cronjob database-backup -n databases -p '{"spec":{"suspend":true}}'

# Resume CronJob
kubectl patch cronjob database-backup -n databases -p '{"spec":{"suspend":false}}'

# Delete old jobs manually
kubectl delete job -l app=backup -n databases --field-selector status.successful=1
```

---

## 10. Multi-Container Pod with Sidecar

**Description:** Demonstrates sidecar pattern with nginx and log collector.

**Use Case:** Extend application functionality without modifying main container, such as logging, monitoring, or configuration management.

**Complete YAML:**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: production
data:
  nginx.conf: |
    user nginx;
    worker_processes auto;
    error_log /var/log/nginx/error.log warn;
    pid /var/run/nginx.pid;

    events {
      worker_connections 1024;
    }

    http {
      include /etc/nginx/mime.types;
      default_type application/octet-stream;

      log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

      access_log /var/log/nginx/access.log main;

      sendfile on;
      keepalive_timeout 65;

      server {
        listen 80;
        server_name _;

        location / {
          root /usr/share/nginx/html;
          index index.html;
        }

        location /health {
          access_log off;
          return 200 "healthy\n";
          add_header Content-Type text/plain;
        }
      }
    }
---
apiVersion: v1
kind: Pod
metadata:
  name: webapp-with-sidecar
  namespace: production
  labels:
    app: webapp
    version: v1
spec:
  # Shared process namespace allows containers to see each other's processes
  shareProcessNamespace: true

  initContainers:
  # Init container to set up shared volume
  - name: setup
    image: busybox:1.35
    command:
    - sh
    - -c
    - |
      echo "Initializing shared directories..."
      mkdir -p /shared/logs
      chmod 777 /shared/logs
      echo "Setup complete"
    volumeMounts:
    - name: shared-logs
      mountPath: /shared

  containers:
  # Main application container
  - name: nginx
    image: nginx:1.21-alpine
    ports:
    - containerPort: 80
      name: http
      protocol: TCP
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 256Mi
    volumeMounts:
    - name: nginx-config
      mountPath: /etc/nginx/nginx.conf
      subPath: nginx.conf
      readOnly: true
    - name: shared-logs
      mountPath: /var/log/nginx
    - name: html-content
      mountPath: /usr/share/nginx/html
    livenessProbe:
      httpGet:
        path: /health
        port: 80
      initialDelaySeconds: 10
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /health
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5

  # Log processing sidecar
  - name: log-processor
    image: busybox:1.35
    command:
    - sh
    - -c
    - |
      echo "Log processor started"
      while true; do
        if [ -f /logs/access.log ]; then
          # Process access logs
          tail -f /logs/access.log | while read line; do
            echo "[PROCESSED] $line" >> /logs/processed.log
          done &
        fi
        if [ -f /logs/error.log ]; then
          # Process error logs
          tail -f /logs/error.log | while read line; do
            echo "[ERROR] $(date -u +%Y-%m-%dT%H:%M:%SZ) $line" >> /logs/errors-processed.log
          done &
        fi
        sleep 10
      done
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
      limits:
        cpu: 200m
        memory: 128Mi
    volumeMounts:
    - name: shared-logs
      mountPath: /logs

  # Metrics exporter sidecar
  - name: metrics-exporter
    image: nginx/nginx-prometheus-exporter:0.11
    args:
    - -nginx.scrape-uri=http://localhost:80/stub_status
    ports:
    - containerPort: 9113
      name: metrics
      protocol: TCP
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
      limits:
        cpu: 100m
        memory: 128Mi

  # Configuration reloader sidecar
  - name: config-reloader
    image: jimmidyson/configmap-reload:v0.7.1
    args:
    - --volume-dir=/config
    - --webhook-url=http://localhost:80/reload
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
      limits:
        cpu: 100m
        memory: 128Mi
    volumeMounts:
    - name: nginx-config
      mountPath: /config
      readOnly: true

  volumes:
  # ConfigMap for nginx configuration
  - name: nginx-config
    configMap:
      name: nginx-config

  # Shared volume for logs
  - name: shared-logs
    emptyDir: {}

  # HTML content volume
  - name: html-content
    emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
  namespace: production
  labels:
    app: webapp
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9113"
    prometheus.io/path: "/metrics"
spec:
  type: ClusterIP
  selector:
    app: webapp
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  - name: metrics
    port: 9113
    targetPort: 9113
    protocol: TCP
```

**Explanation:**
- **Main Container (nginx)**: Serves web traffic
- **Log Processor Sidecar**: Processes and enriches logs in real-time
- **Metrics Exporter Sidecar**: Exposes Prometheus metrics
- **Config Reloader Sidecar**: Watches for configuration changes and triggers reload
- **Init Container**: Sets up shared directories before main containers start
- `shareProcessNamespace: true` allows containers to see each other's processes
- `emptyDir` volumes provide shared storage that exists for pod lifetime
- All containers in the pod share the same network namespace (can communicate via localhost)

**Access and Testing:**
```bash
# Access nginx
kubectl port-forward webapp-with-sidecar 8080:80 -n production
curl http://localhost:8080

# View metrics
kubectl port-forward webapp-with-sidecar 9113:9113 -n production
curl http://localhost:9113/metrics

# Check logs from each container
kubectl logs webapp-with-sidecar -c nginx -n production
kubectl logs webapp-with-sidecar -c log-processor -n production
kubectl logs webapp-with-sidecar -c metrics-exporter -n production

# Execute command in specific container
kubectl exec -it webapp-with-sidecar -c nginx -n production -- sh

# View shared volume contents
kubectl exec webapp-with-sidecar -c log-processor -n production -- ls -la /logs
```

---

## 11. Init Container Pattern

**Description:** Uses init containers to prepare environment before main application starts.

**Use Case:** Database migrations, dependency checks, configuration generation, or waiting for dependencies.

**Complete YAML:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-init
  namespace: production
  labels:
    app: myapp
spec:
  initContainers:
  # Wait for database to be ready
  - name: wait-for-db
    image: busybox:1.35
    command:
    - sh
    - -c
    - |
      echo "Waiting for database..."
      until nc -z postgres.databases.svc.cluster.local 5432; do
        echo "Database not ready, waiting..."
        sleep 2
      done
      echo "Database is ready!"

  # Run database migrations
  - name: migrate-db
    image: myapp:v1.0-migration
    command: ["python", "/app/migrate.py"]
    env:
    - name: DATABASE_URL
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: connection-string
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 512Mi

  # Download configuration from remote source
  - name: fetch-config
    image: curlimages/curl:7.85.0
    command:
    - sh
    - -c
    - |
      echo "Fetching configuration..."
      curl -o /config/app-config.json https://config.example.com/api/config
      echo "Configuration downloaded"
    volumeMounts:
    - name: config
      mountPath: /config

  # Generate SSL certificates
  - name: generate-certs
    image: alpine/openssl:latest
    command:
    - sh
    - -c
    - |
      if [ ! -f /certs/tls.key ]; then
        echo "Generating self-signed certificate..."
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
          -keyout /certs/tls.key \
          -out /certs/tls.crt \
          -subj "/CN=myapp.example.com"
        echo "Certificate generated"
      else
        echo "Certificate already exists"
      fi
    volumeMounts:
    - name: certs
      mountPath: /certs

  # Pre-populate cache
  - name: warmup-cache
    image: redis:7-alpine
    command:
    - sh
    - -c
    - |
      echo "Warming up cache..."
      redis-cli -h redis.databases.svc.cluster.local PING
      redis-cli -h redis.databases.svc.cluster.local SET warmup:timestamp "$(date)"
      echo "Cache warmed up"

  # Main application container
  containers:
  - name: app
    image: myapp:v1.0
    ports:
    - containerPort: 8080
      name: http
    - containerPort: 8443
      name: https
    env:
    - name: CONFIG_PATH
      value: "/config/app-config.json"
    - name: DATABASE_URL
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: connection-string
    resources:
      requests:
        cpu: 200m
        memory: 256Mi
      limits:
        cpu: 1000m
        memory: 512Mi
    volumeMounts:
    - name: config
      mountPath: /config
      readOnly: true
    - name: certs
      mountPath: /etc/tls
      readOnly: true
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 5

  volumes:
  - name: config
    emptyDir: {}
  - name: certs
    emptyDir: {}
---
# More complex example with Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-with-init
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      initContainers:
      # Clone git repository
      - name: git-clone
        image: alpine/git:latest
        command:
        - sh
        - -c
        - |
          if [ ! -d /app/.git ]; then
            git clone https://github.com/example/app.git /app
          else
            cd /app && git pull
          fi
        volumeMounts:
        - name: app-code
          mountPath: /app

      # Install dependencies
      - name: install-deps
        image: node:18-alpine
        command: ["npm", "install"]
        workingDir: /app
        volumeMounts:
        - name: app-code
          mountPath: /app
        - name: npm-cache
          mountPath: /root/.npm

      # Build application
      - name: build
        image: node:18-alpine
        command: ["npm", "run", "build"]
        workingDir: /app
        volumeMounts:
        - name: app-code
          mountPath: /app

      containers:
      - name: web-server
        image: nginx:1.21-alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: app-code
          mountPath: /usr/share/nginx/html
          subPath: dist
          readOnly: true

      volumes:
      - name: app-code
        emptyDir: {}
      - name: npm-cache
        emptyDir: {}
```

**Explanation:**
- Init containers run sequentially before main containers start
- Each init container must complete successfully before the next starts
- If an init container fails, Kubernetes restarts the pod
- Init containers share volumes with main containers
- Common use cases:
  - Waiting for dependencies (databases, services)
  - Running database migrations
  - Pre-populating data or cache
  - Generating configuration files
  - Downloading assets or code
  - Security checks

**Monitoring:**
```bash
# Watch pod initialization
kubectl get pod app-with-init -n production --watch

# Check init container logs
kubectl logs app-with-init -c wait-for-db -n production
kubectl logs app-with-init -c migrate-db -n production

# Describe pod to see init container status
kubectl describe pod app-with-init -n production

# If init container fails, check events
kubectl get events --field-selector involvedObject.name=app-with-init -n production
```

This comprehensive examples document provides production-ready patterns for Kubernetes orchestration. Each example includes detailed explanations, use cases, and operational commands to help you implement and manage these patterns effectively.

---

## 12. Service Mesh with Ambassador Pattern

**Description:** Implements an ambassador container pattern for service mesh capabilities.

**Use Case:** Add protocol translation, authentication, or circuit breaking without modifying the main application.

**Complete YAML:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-ambassador
  namespace: production
  labels:
    app: myapp
    version: v1
spec:
  containers:
  # Main application container
  - name: app
    image: myapp:v1.0
    ports:
    - containerPort: 8080
      name: app-port
    env:
    - name: PROXY_URL
      value: "http://localhost:8888"
    resources:
      requests:
        cpu: 200m
        memory: 256Mi
      limits:
        cpu: 1000m
        memory: 512Mi

  # Ambassador/Proxy container
  - name: envoy-proxy
    image: envoyproxy/envoy:v1.24.0
    ports:
    - containerPort: 8888
      name: proxy-port
    - containerPort: 9901
      name: admin-port
    volumeMounts:
    - name: envoy-config
      mountPath: /etc/envoy
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 256Mi

  volumes:
  - name: envoy-config
    configMap:
      name: envoy-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: envoy-config
  namespace: production
data:
  envoy.yaml: |
    admin:
      address:
        socket_address:
          address: 0.0.0.0
          port_value: 9901

    static_resources:
      listeners:
      - name: listener_0
        address:
          socket_address:
            address: 0.0.0.0
            port_value: 8888
        filter_chains:
        - filters:
          - name: envoy.filters.network.http_connection_manager
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
              stat_prefix: ingress_http
              route_config:
                name: local_route
                virtual_hosts:
                - name: backend
                  domains: ["*"]
                  routes:
                  - match:
                      prefix: "/"
                    route:
                      cluster: local_service
                      retry_policy:
                        retry_on: "5xx"
                        num_retries: 3
              http_filters:
              - name: envoy.filters.http.router
                typed_config:
                  "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router

      clusters:
      - name: local_service
        connect_timeout: 0.25s
        type: STRICT_DNS
        lb_policy: ROUND_ROBIN
        load_assignment:
          cluster_name: local_service
          endpoints:
          - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: 127.0.0.1
                    port_value: 8080
        circuit_breakers:
          thresholds:
          - max_connections: 1000
            max_pending_requests: 1000
            max_requests: 1000
            max_retries: 3
```

**Explanation:**
- Ambassador pattern places a proxy container alongside the application
- Envoy proxy handles traffic management, retries, and circuit breaking
- Application connects through localhost to the ambassador
- Provides service mesh features without a full mesh deployment
- Circuit breaker prevents cascading failures
- Retry policy automatically retries failed requests

---

## 13. Blue-Green Deployment

**Description:** Implements blue-green deployment strategy for zero-downtime releases.

**Use Case:** Deploy new versions with instant rollback capability and zero downtime.

**Complete YAML:**

```yaml
# Blue deployment (current production)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-blue
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: blue
  template:
    metadata:
      labels:
        app: myapp
        version: blue
    spec:
      containers:
      - name: app
        image: myapp:v1.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
---
# Green deployment (new version)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-green
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: green
  template:
    metadata:
      labels:
        app: myapp
        version: green
    spec:
      containers:
      - name: app
        image: myapp:v2.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
---
# Service (initially pointing to blue)
apiVersion: v1
kind: Service
metadata:
  name: app-service
  namespace: production
spec:
  selector:
    app: myapp
    version: blue  # Change to 'green' to switch traffic
  ports:
  - port: 80
    targetPort: 8080
```

**Explanation:**
- Two identical environments run simultaneously (blue and green)
- Service selector controls which deployment receives traffic
- Switch traffic by updating service selector
- Instant rollback by switching selector back
- Both versions can run for testing before switching

**Switching Traffic:**
```bash
# Deploy green version
kubectl apply -f app-green-deployment.yaml

# Test green deployment
kubectl port-forward deployment/app-green 8080:8080 -n production

# Switch traffic to green
kubectl patch service app-service -n production -p '{"spec":{"selector":{"version":"green"}}}'

# Rollback to blue if needed
kubectl patch service app-service -n production -p '{"spec":{"selector":{"version":"blue"}}}'

# After successful deployment, scale down blue
kubectl scale deployment app-blue --replicas=0 -n production
```

---

## 14. Canary Deployment

**Description:** Gradually rolls out new version to subset of users.

**Use Case:** Test new versions with real traffic before full rollout, minimizing risk.

**Complete YAML:**

```yaml
# Stable deployment (90% of traffic)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-stable
  namespace: production
spec:
  replicas: 9
  selector:
    matchLabels:
      app: myapp
      track: stable
  template:
    metadata:
      labels:
        app: myapp
        track: stable
        version: v1.0
    spec:
      containers:
      - name: app
        image: myapp:v1.0
        ports:
        - containerPort: 8080
---
# Canary deployment (10% of traffic)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-canary
  namespace: production
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
      track: canary
  template:
    metadata:
      labels:
        app: myapp
        track: canary
        version: v2.0
    spec:
      containers:
      - name: app
        image: myapp:v2.0
        ports:
        - containerPort: 8080
---
# Service (routes to both stable and canary)
apiVersion: v1
kind: Service
metadata:
  name: app-service
  namespace: production
spec:
  selector:
    app: myapp  # Matches both stable and canary
  ports:
  - port: 80
    targetPort: 8080
```

**Explanation:**
- Traffic distributed based on replica count ratio
- 9 stable replicas + 1 canary replica = 10% canary traffic
- Monitor canary metrics before increasing traffic
- Gradually increase canary replicas while decreasing stable
- Rollback by scaling canary to 0

**Progressive Rollout:**
```bash
# Start with 10% canary
kubectl scale deployment app-canary --replicas=1 -n production

# If metrics look good, increase to 25%
kubectl scale deployment app-stable --replicas=3 -n production
kubectl scale deployment app-canary --replicas=1 -n production

# Increase to 50%
kubectl scale deployment app-stable --replicas=1 -n production
kubectl scale deployment app-canary --replicas=1 -n production

# Complete rollout to 100%
kubectl scale deployment app-stable --replicas=0 -n production
kubectl scale deployment app-canary --replicas=3 -n production
```

---

## 15. Network Policy for Security

**Description:** Implements network segmentation and access control.

**Use Case:** Enforce security boundaries between applications and tiers.

**Complete YAML:**

```yaml
# Deny all ingress traffic by default
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
---
# Allow frontend to access backend
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: production
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 8080
---
# Allow backend to access database
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-to-database
  namespace: production
spec:
  podSelector:
    matchLabels:
      tier: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 5432
---
# Allow ingress controller access
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-controller
  namespace: production
spec:
  podSelector:
    matchLabels:
      tier: frontend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 80
---
# Egress control
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-and-api
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  # Allow DNS
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
  # Allow Kubernetes API
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 443
```

**Explanation:**
- Default deny policy blocks all ingress traffic
- Specific policies whitelist allowed connections
- Policies are namespace-scoped
- Can control ingress and/or egress
- Use pod selectors and namespace selectors for fine-grained control

---

## 16. Resource Quotas and Limits

**Description:** Enforces resource consumption limits at namespace level.

**Use Case:** Prevent resource exhaustion and ensure fair resource allocation across teams.

**Complete YAML:**

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev-team
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: dev-team
spec:
  hard:
    requests.cpu: "20"
    requests.memory: 40Gi
    limits.cpu: "40"
    limits.memory: 80Gi
    pods: "50"
    services: "10"
    persistentvolumeclaims: "20"
    requests.storage: "500Gi"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: resource-limits
  namespace: dev-team
spec:
  limits:
  - max:
      cpu: "4"
      memory: 8Gi
    min:
      cpu: 100m
      memory: 128Mi
    default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 200m
      memory: 256Mi
    type: Container
  - max:
      storage: 50Gi
    min:
      storage: 1Gi
    type: PersistentVolumeClaim
```

**Explanation:**
- ResourceQuota limits total resources in namespace
- LimitRange sets defaults and bounds for individual resources
- Prevents runaway resource consumption
- Enforces resource requests and limits on all pods

---

## 17. Pod Disruption Budget

**Description:** Maintains minimum availability during voluntary disruptions.

**Use Case:** Ensure high availability during cluster maintenance or node upgrades.

**Complete YAML:**

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb
  namespace: production
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: myapp
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: database-pdb
  namespace: databases
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      app: postgres
```

**Explanation:**
- PDB ensures minimum pods available during voluntary disruptions
- `minAvailable: 2` ensures at least 2 pods remain running
- `maxUnavailable: 1` allows maximum 1 pod to be unavailable
- Protects against simultaneous pod evictions during maintenance

---

## 18. Job for Batch Processing

**Description:** Runs parallel batch processing with completion tracking.

**Use Case:** Process large datasets in parallel with automatic retry and completion tracking.

**Complete YAML:**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processor
  namespace: production
spec:
  completions: 10
  parallelism: 3
  backoffLimit: 5
  activeDeadlineSeconds: 3600
  template:
    spec:
      restartPolicy: OnFailure
      containers:
      - name: processor
        image: data-processor:v1.0
        command: ["python", "process.py"]
        args: ["--batch-id", "$(JOB_COMPLETION_INDEX)"]
        env:
        - name: JOB_COMPLETION_INDEX
          value: "$(JOB_COMPLETION_INDEX)"
        resources:
          requests:
            cpu: 1000m
            memory: 2Gi
          limits:
            cpu: 2000m
            memory: 4Gi
```

**Explanation:**
- `completions: 10` requires 10 successful pod completions
- `parallelism: 3` runs 3 pods simultaneously
- `backoffLimit: 5` retries failed pods up to 5 times
- `activeDeadlineSeconds` sets maximum job duration
- `JOB_COMPLETION_INDEX` provides unique index to each pod

---

## 19. Multi-Tier Application Stack

**Description:** Complete multi-tier application with frontend, backend, and database.

**Use Case:** Deploy a production-ready web application stack with proper separation of concerns.

**Complete YAML:**

```yaml
# Database tier
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: production
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
      tier: database
  template:
    metadata:
      labels:
        app: postgres
        tier: database
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
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: production
spec:
  clusterIP: None
  selector:
    app: postgres
  ports:
  - port: 5432
---
# Backend tier
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
      tier: backend
  template:
    metadata:
      labels:
        app: backend
        tier: backend
    spec:
      containers:
      - name: backend
        image: backend-api:v1.0
        ports:
        - containerPort: 8080
        env:
        - name: DATABASE_URL
          value: "postgresql://postgres:5432/mydb"
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 1000m
            memory: 512Mi
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: production
spec:
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 8080
---
# Frontend tier
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
      tier: frontend
  template:
    metadata:
      labels:
        app: frontend
        tier: frontend
    spec:
      containers:
      - name: frontend
        image: frontend-app:v1.0
        ports:
        - containerPort: 80
        env:
        - name: API_URL
          value: "http://backend"
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: production
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
---
# Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: production
spec:
  ingressClassName: nginx
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend
            port:
              number: 80
```

**Explanation:**
- Three-tier architecture: frontend, backend, database
- StatefulSet for database with persistent storage
- Deployments for stateless frontend and backend
- Services provide stable endpoints
- Ingress routes external traffic

---

## 20. Monitoring with Prometheus

**Description:** Deploys Prometheus for metrics collection and monitoring.

**Use Case:** Monitor application and infrastructure metrics for observability.

**Complete YAML:**

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  namespace: monitoring
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources: ["nodes", "services", "endpoints", "pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: monitoring
roleRef:
  kind: ClusterRole
  name: prometheus
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s

    scrape_configs:
    - job_name: 'kubernetes-pods'
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      serviceAccountName: prometheus
      containers:
      - name: prometheus
        image: prom/prometheus:v2.40.0
        args:
        - '--config.file=/etc/prometheus/prometheus.yml'
        - '--storage.tsdb.path=/prometheus'
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: config
          mountPath: /etc/prometheus
        - name: storage
          mountPath: /prometheus
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 2000m
            memory: 2Gi
      volumes:
      - name: config
        configMap:
          name: prometheus-config
      - name: storage
        persistentVolumeClaim:
          claimName: prometheus-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: monitoring
spec:
  selector:
    app: prometheus
  ports:
  - port: 9090
    targetPort: 9090
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prometheus-pvc
  namespace: monitoring
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
```

**Explanation:**
- Prometheus automatically discovers and scrapes metrics from annotated pods
- ServiceAccount and RBAC enable cluster-wide discovery
- ConfigMap defines scrape configurations
- PersistentVolume stores metrics data
- Pods expose metrics via annotations:
  ```yaml
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9090"
    prometheus.io/path: "/metrics"
  ```

This completes the comprehensive Kubernetes orchestration examples covering 20 production-ready patterns and use cases.
