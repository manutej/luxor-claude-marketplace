# MLOps Workflows Skill

A comprehensive skill for implementing production-grade MLOps workflows using MLflow. This skill covers the complete machine learning lifecycle from experimentation to production deployment and monitoring.

## Quick Start

### Installation

```bash
# Install MLflow and dependencies
pip install mlflow scikit-learn pandas numpy

# Start MLflow tracking server
mlflow server --host 0.0.0.0 --port 5000

# Optional: with backend store and artifact storage
mlflow server \
    --backend-store-uri postgresql://user:password@localhost/mlflow \
    --default-artifact-root s3://my-bucket/mlflow-artifacts \
    --host 0.0.0.0 \
    --port 5000
```

### Basic Usage

```python
import mlflow
from sklearn.ensemble import RandomForestClassifier

# Set tracking URI
mlflow.set_tracking_uri("http://localhost:5000")

# Enable autologging
mlflow.sklearn.autolog()

# Train model - everything logged automatically
with mlflow.start_run():
    model = RandomForestClassifier(n_estimators=100)
    model.fit(X_train, y_train)
```

## MLOps Architecture Overview

### Architecture Components

```
┌─────────────────────────────────────────────────────────────┐
│                    MLOps Architecture                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌──────────────┐     ┌────────────┐  │
│  │ Development  │──────│  MLflow      │─────│  Model     │  │
│  │ Environment  │      │  Tracking    │     │  Registry  │  │
│  └──────────────┘      └──────────────┘     └────────────┘  │
│         │                     │                    │         │
│         │                     ▼                    │         │
│         │              ┌──────────────┐            │         │
│         │              │  Experiment  │            │         │
│         │              │  Management  │            │         │
│         │              └──────────────┘            │         │
│         │                     │                    │         │
│         ▼                     ▼                    ▼         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           Feature Store & Data Versioning            │   │
│  └──────────────────────────────────────────────────────┘   │
│                           │                                  │
│                           ▼                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │            CI/CD Pipeline for ML Models              │   │
│  │  ┌────────┐  ┌────────┐  ┌────────┐  ┌──────────┐  │   │
│  │  │ Train  │→ │  Test  │→ │Package │→ │  Deploy  │  │   │
│  │  └────────┘  └────────┘  └────────┘  └──────────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
│                           │                                  │
│                           ▼                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Production Deployment Layer                  │   │
│  │  ┌─────────┐  ┌─────────┐  ┌──────────┐            │   │
│  │  │ REST    │  │ Batch   │  │ Real-time│            │   │
│  │  │ API     │  │ Scoring │  │ Streaming│            │   │
│  │  └─────────┘  └─────────┘  └──────────┘            │   │
│  └──────────────────────────────────────────────────────┘   │
│                           │                                  │
│                           ▼                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │    Monitoring & Observability Layer                  │   │
│  │  ┌──────────┐  ┌──────────┐  ┌────────────┐        │   │
│  │  │ Model    │  │ Data     │  │ Performance│        │   │
│  │  │ Metrics  │  │ Drift    │  │ Monitoring │        │   │
│  │  └──────────┘  └──────────┘  └────────────┘        │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Development**: Data scientists experiment and track runs with MLflow
2. **Registration**: Best models registered to Model Registry
3. **Validation**: Automated testing and validation pipelines
4. **Deployment**: Models deployed to various serving platforms
5. **Monitoring**: Track performance, drift, and business metrics
6. **Feedback Loop**: Insights feed back into development

## Common Workflows

### 1. Experiment Tracking Workflow

```python
import mlflow
from sklearn.model_selection import GridSearchCV
from sklearn.ensemble import RandomForestClassifier

# Set experiment
mlflow.set_experiment("customer-churn-prediction")

# Parameter grid
param_grid = {
    'n_estimators': [50, 100, 200],
    'max_depth': [5, 10, 15],
    'min_samples_split': [2, 5, 10]
}

# Parent run
with mlflow.start_run(run_name="hyperparameter-search"):
    # Grid search
    grid_search = GridSearchCV(
        RandomForestClassifier(),
        param_grid,
        cv=5,
        scoring='accuracy'
    )

    grid_search.fit(X_train, y_train)

    # Log best parameters
    mlflow.log_params(grid_search.best_params_)
    mlflow.log_metric("best_cv_score", grid_search.best_score_)

    # Log best model
    mlflow.sklearn.log_model(
        sk_model=grid_search.best_estimator_,
        name="model",
        registered_model_name="ChurnPredictor"
    )
```

### 2. Model Registry Workflow

```python
from mlflow import MlflowClient

client = MlflowClient()

# Register model
model_uri = "runs:/run-id/model"
registered_model = mlflow.register_model(
    model_uri=model_uri,
    name="CustomerChurnModel"
)

# Add description
client.update_model_version(
    name="CustomerChurnModel",
    version=registered_model.version,
    description="Random Forest model trained on Q4 2024 data"
)

# Set alias for staging
client.set_registered_model_alias(
    name="CustomerChurnModel",
    alias="staging",
    version=registered_model.version
)

# After validation, promote to production
client.set_registered_model_alias(
    name="CustomerChurnModel",
    alias="production",
    version=registered_model.version
)
```

### 3. Deployment Workflow

```python
import mlflow

# Load production model
model = mlflow.pyfunc.load_model("models:/CustomerChurnModel@production")

# Serve as REST API
# Terminal: mlflow models serve -m models:/CustomerChurnModel@production -p 5001

# Or deploy to cloud platform
import mlflow.sagemaker

mlflow.sagemaker.deploy(
    app_name="churn-predictor",
    model_uri="models:/CustomerChurnModel@production",
    region_name="us-east-1",
    mode="create",
    execution_role_arn="arn:aws:iam::123456789:role/MLflowSagemakerRole",
    instance_type="ml.m5.large"
)
```

### 4. Monitoring Workflow

```python
import mlflow
from sklearn.metrics import accuracy_score, precision_score, recall_score
from datetime import datetime

mlflow.set_experiment("production-monitoring")

def monitor_predictions(y_true, y_pred, model_name):
    """Monitor production model performance"""
    with mlflow.start_run(run_name=f"monitoring-{datetime.now().isoformat()}"):
        # Calculate metrics
        metrics = {
            "accuracy": accuracy_score(y_true, y_pred),
            "precision": precision_score(y_true, y_pred, average='weighted'),
            "recall": recall_score(y_true, y_pred, average='weighted')
        }

        # Log metrics
        mlflow.log_metrics(metrics)
        mlflow.log_param("model_name", model_name)
        mlflow.log_param("timestamp", datetime.now().isoformat())

        # Alert on degradation
        if metrics['accuracy'] < 0.85:
            mlflow.set_tag("alert", "performance_degradation")
            # Trigger retraining pipeline
            trigger_retraining(model_name)

# Use in production
monitor_predictions(actual_labels, predictions, "CustomerChurnModel")
```

### 5. CI/CD Workflow

```python
# training_pipeline.py
import mlflow
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score

def training_pipeline(data_version, params, performance_threshold=0.85):
    """Automated training pipeline with validation gates"""

    mlflow.set_experiment("automated-training")

    with mlflow.start_run(run_name=f"pipeline-{data_version}"):
        # Load data
        X, y = load_data(data_version)
        mlflow.log_param("data_version", data_version)

        # Train model
        model = RandomForestClassifier(**params)
        cv_scores = cross_val_score(model, X, y, cv=5)
        mean_score = cv_scores.mean()

        mlflow.log_params(params)
        mlflow.log_metric("cv_score", mean_score)

        # Validation gate
        if mean_score >= performance_threshold:
            # Log and register model
            model.fit(X, y)
            mlflow.sklearn.log_model(
                sk_model=model,
                name="model",
                registered_model_name="ProductionModel"
            )
            mlflow.set_tag("status", "passed")
            return True
        else:
            mlflow.set_tag("status", "failed")
            return False

# GitHub Actions / Jenkins pipeline
if __name__ == "__main__":
    success = training_pipeline(
        data_version="v2.1.0",
        params={'n_estimators': 100, 'max_depth': 10}
    )
    if not success:
        exit(1)  # Fail pipeline
```

## Integration with Deployment Platforms

### AWS SageMaker

```python
import mlflow.sagemaker
from time import gmtime, strftime

# Deploy to SageMaker
app_name = f"mlflow-model-{strftime('%Y-%m-%d-%H-%M-%S', gmtime())}"

mlflow.sagemaker.deploy(
    app_name=app_name,
    model_uri="models:/MyModel@production",
    region_name="us-east-1",
    mode="create",
    execution_role_arn="arn:aws:iam::123456789:role/SageMakerRole",
    instance_type="ml.m5.xlarge",
    instance_count=2,
    vpc_config={
        "SecurityGroupIds": ["sg-12345678"],
        "Subnets": ["subnet-12345678", "subnet-87654321"]
    }
)

# Update existing deployment
mlflow.sagemaker.deploy(
    app_name=app_name,
    model_uri="models:/MyModel@production",
    region_name="us-east-1",
    mode="replace"
)

# Make predictions
import boto3
import json

runtime = boto3.client('sagemaker-runtime', region_name='us-east-1')

response = runtime.invoke_endpoint(
    EndpointName=app_name,
    ContentType='application/json',
    Body=json.dumps({
        "dataframe_split": {
            "columns": ["feature1", "feature2"],
            "data": [[1.0, 2.0]]
        }
    })
)

prediction = json.loads(response['Body'].read())
```

### Azure ML

```python
import mlflow.azureml
from azureml.core import Workspace
from azureml.core.webservice import AciWebservice, AksWebservice

# Connect to Azure workspace
ws = Workspace.from_config()

# Deploy to Azure Container Instance (dev/test)
aci_config = AciWebservice.deploy_configuration(
    cpu_cores=2,
    memory_gb=4,
    tags={"model": "churn-predictor", "env": "staging"},
    description="Customer churn prediction model"
)

mlflow.azureml.deploy(
    model_uri="models:/CustomerChurnModel@staging",
    workspace=ws,
    deployment_config=aci_config,
    service_name="churn-predictor-aci"
)

# Deploy to Azure Kubernetes Service (production)
aks_config = AksWebservice.deploy_configuration(
    cpu_cores=4,
    memory_gb=8,
    autoscale_enabled=True,
    autoscale_min_replicas=2,
    autoscale_max_replicas=10,
    autoscale_target_utilization=70
)

mlflow.azureml.deploy(
    model_uri="models:/CustomerChurnModel@production",
    workspace=ws,
    deployment_config=aks_config,
    service_name="churn-predictor-aks"
)
```

### GCP Vertex AI

```python
from google.cloud import aiplatform
import mlflow

# Initialize Vertex AI
aiplatform.init(
    project="my-project",
    location="us-central1",
    staging_bucket="gs://my-bucket"
)

# Upload model to Vertex AI
model = aiplatform.Model.upload(
    display_name="customer-churn-model",
    artifact_uri="models:/CustomerChurnModel@production",
    serving_container_image_uri="us-docker.pkg.dev/vertex-ai/prediction/sklearn-cpu.1-0:latest"
)

# Create endpoint
endpoint = aiplatform.Endpoint.create(
    display_name="churn-prediction-endpoint"
)

# Deploy model to endpoint
model.deploy(
    endpoint=endpoint,
    deployed_model_display_name="churn-v1",
    machine_type="n1-standard-4",
    min_replica_count=1,
    max_replica_count=5,
    traffic_percentage=100
)

# Make predictions
prediction = endpoint.predict(instances=[[1.0, 2.0, 3.0]])
```

### Kubernetes with Seldon Core

```yaml
# seldon-deployment.yaml
apiVersion: machinelearning.seldon.io/v1
kind: SeldonDeployment
metadata:
  name: mlflow-model
spec:
  predictors:
  - name: default
    graph:
      name: classifier
      implementation: MLFLOW_SERVER
      modelUri: models:/CustomerChurnModel@production
      envSecretRefName: mlflow-credentials
    replicas: 3
    engineResources:
      requests:
        cpu: 500m
        memory: 1Gi
      limits:
        cpu: 1000m
        memory: 2Gi
```

```bash
# Deploy to Kubernetes
kubectl apply -f seldon-deployment.yaml

# Access predictions
curl -X POST http://mlflow-model-default.default.svc.cluster.local/api/v1.0/predictions \
  -H 'Content-Type: application/json' \
  -d '{"data":{"ndarray":[[1.0, 2.0, 3.0]]}}'
```

## Best Practices

### 1. Experiment Organization

- Use meaningful experiment names (e.g., "customer-churn-q4-2024")
- Tag runs with metadata (model type, data version, developer)
- Use nested runs for hyperparameter tuning
- Document experiments with descriptions

### 2. Model Registry

- Always use model aliases (champion/challenger) instead of deprecated stages
- Add comprehensive descriptions and tags to model versions
- Document model requirements and dependencies
- Version control model code alongside MLflow artifacts

### 3. Deployment

- Always include model signatures for input/output validation
- Use input examples for automatic schema inference
- Implement health check endpoints
- Set up automated rollback mechanisms

### 4. Monitoring

- Track business metrics alongside ML metrics
- Monitor for data drift and concept drift
- Set up alerting for performance degradation
- Log prediction distributions

### 5. Security

- Use authentication for MLflow tracking server
- Encrypt artifacts at rest and in transit
- Implement access control for model registry
- Audit model deployments and access

## Environment Setup Examples

### Local Development

```bash
# Install dependencies
pip install mlflow scikit-learn pandas numpy

# Start local tracking server
mlflow server --host 127.0.0.1 --port 5000

# Set tracking URI in code
export MLFLOW_TRACKING_URI=http://localhost:5000
```

### Production with PostgreSQL and S3

```bash
# Start MLflow server with backend store and artifact storage
mlflow server \
    --backend-store-uri postgresql://user:password@postgres-host:5432/mlflow \
    --default-artifact-root s3://my-mlflow-bucket/artifacts \
    --host 0.0.0.0 \
    --port 5000 \
    --workers 4
```

### Docker Deployment

```dockerfile
# Dockerfile
FROM python:3.9-slim

RUN pip install mlflow psycopg2-binary boto3

ENV MLFLOW_BACKEND_STORE_URI=postgresql://user:password@db:5432/mlflow
ENV MLFLOW_DEFAULT_ARTIFACT_ROOT=s3://mlflow-artifacts

EXPOSE 5000

CMD ["mlflow", "server", \
     "--backend-store-uri", "${MLFLOW_BACKEND_STORE_URI}", \
     "--default-artifact-root", "${MLFLOW_DEFAULT_ARTIFACT_ROOT}", \
     "--host", "0.0.0.0", \
     "--port", "5000"]
```

## Troubleshooting

### Common Issues

1. **Connection Issues**: Verify tracking URI is set correctly
2. **Artifact Storage**: Ensure proper credentials for cloud storage
3. **Model Loading**: Check model signature matches input data format
4. **Performance**: Use batch predictions for large datasets

### Debug Mode

```python
import mlflow
import logging

# Enable debug logging
logging.basicConfig(level=logging.DEBUG)
mlflow.set_tracking_uri("http://localhost:5000")

# Verify connection
client = mlflow.tracking.MlflowClient()
experiments = client.search_experiments()
print(f"Found {len(experiments)} experiments")
```

## Resources

- MLflow Documentation: https://mlflow.org/docs/latest/index.html
- Model Registry: https://mlflow.org/docs/latest/model-registry.html
- Tracking API: https://mlflow.org/docs/latest/tracking.html
- Deployment: https://mlflow.org/docs/latest/models.html

## License

This skill is provided as-is for educational and production use with MLflow.
