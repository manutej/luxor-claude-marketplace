# MLOps Workflows - Production Examples

This document contains 20+ detailed, production-ready examples demonstrating comprehensive MLOps workflows with MLflow.

## Table of Contents

1. [Experiment Tracking Examples](#experiment-tracking-examples)
2. [Model Registry Examples](#model-registry-examples)
3. [Deployment Examples](#deployment-examples)
4. [Monitoring Examples](#monitoring-examples)
5. [A/B Testing Examples](#ab-testing-examples)
6. [Feature Engineering Examples](#feature-engineering-examples)
7. [CI/CD Pipeline Examples](#cicd-pipeline-examples)
8. [Advanced Workflows](#advanced-workflows)

## Experiment Tracking Examples

### Example 1: Basic Experiment Tracking with Scikit-learn

**Description**: Track a complete ML experiment including parameters, metrics, and model artifacts.

**Use Case**: Initial model development and baseline establishment.

```python
import mlflow
import mlflow.sklearn
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score

# Set tracking URI and experiment
mlflow.set_tracking_uri("http://localhost:5000")
mlflow.set_experiment("iris-classification")

# Load and prepare data
iris = load_iris()
X_train, X_test, y_train, y_test = train_test_split(
    iris.data, iris.target, test_size=0.2, random_state=42
)

# Start MLflow run
with mlflow.start_run(run_name="random-forest-baseline"):
    # Define parameters
    params = {
        "n_estimators": 100,
        "max_depth": 5,
        "min_samples_split": 2,
        "min_samples_leaf": 1,
        "random_state": 42
    }

    # Train model
    model = RandomForestClassifier(**params)
    model.fit(X_train, y_train)

    # Make predictions
    y_pred = model.predict(X_test)

    # Calculate metrics
    metrics = {
        "accuracy": accuracy_score(y_test, y_pred),
        "precision": precision_score(y_test, y_pred, average='weighted'),
        "recall": recall_score(y_test, y_pred, average='weighted'),
        "f1": f1_score(y_test, y_pred, average='weighted')
    }

    # Log parameters and metrics
    mlflow.log_params(params)
    mlflow.log_metrics(metrics)

    # Log model with signature
    from mlflow.models import infer_signature
    signature = infer_signature(X_train, model.predict(X_train))

    mlflow.sklearn.log_model(
        sk_model=model,
        name="random_forest_model",
        signature=signature,
        input_example=X_train[:5],
        registered_model_name="IrisClassifier"
    )

    print(f"Model accuracy: {metrics['accuracy']:.3f}")
    print(f"Run ID: {mlflow.active_run().info.run_id}")
```

**Explanation**: This example demonstrates the complete tracking workflow - from setting up experiments to logging parameters, metrics, and models with proper signatures. The model is automatically registered in the Model Registry.

---

### Example 2: Autologging with Deep Learning (PyTorch)

**Description**: Use MLflow's autologging feature for automatic tracking of deep learning experiments.

**Use Case**: Streamlined experiment tracking for neural network training.

```python
import mlflow
import mlflow.pytorch
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, TensorDataset

# Enable PyTorch autologging
mlflow.pytorch.autolog()

mlflow.set_experiment("pytorch-neural-network")

# Define neural network
class NeuralNet(nn.Module):
    def __init__(self, input_size, hidden_size, num_classes):
        super(NeuralNet, self).__init__()
        self.fc1 = nn.Linear(input_size, hidden_size)
        self.relu = nn.ReLU()
        self.fc2 = nn.Linear(hidden_size, num_classes)

    def forward(self, x):
        out = self.fc1(x)
        out = self.relu(out)
        out = self.fc2(out)
        return out

# Prepare data
X_train_tensor = torch.FloatTensor(X_train)
y_train_tensor = torch.LongTensor(y_train)
train_dataset = TensorDataset(X_train_tensor, y_train_tensor)
train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)

# Training with autologging
with mlflow.start_run(run_name="pytorch-classifier"):
    # Model initialization
    input_size = X_train.shape[1]
    hidden_size = 64
    num_classes = len(set(y_train))

    model = NeuralNet(input_size, hidden_size, num_classes)
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=0.001)

    # Log additional parameters manually
    mlflow.log_param("hidden_size", hidden_size)
    mlflow.log_param("learning_rate", 0.001)
    mlflow.log_param("batch_size", 32)

    # Training loop
    epochs = 50
    for epoch in range(epochs):
        for inputs, labels in train_loader:
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()

        # Log metrics per epoch
        mlflow.log_metric("epoch_loss", loss.item(), step=epoch)

        if (epoch + 1) % 10 == 0:
            print(f'Epoch [{epoch+1}/{epochs}], Loss: {loss.item():.4f}')

    # Model is automatically logged by autolog
    print(f"Training complete. Run ID: {mlflow.active_run().info.run_id}")
```

**Explanation**: Autologging automatically captures model architecture, optimizer settings, and training metrics without manual logging calls. Additional custom parameters and per-epoch metrics can still be logged manually.

---

### Example 3: Hyperparameter Tuning with Nested Runs

**Description**: Track hyperparameter search with parent and child runs for organization.

**Use Case**: Systematic hyperparameter optimization with complete audit trail.

```python
import mlflow
from sklearn.model_selection import cross_val_score
from sklearn.ensemble import GradientBoostingClassifier
from itertools import product
import numpy as np

mlflow.set_experiment("hyperparameter-optimization")

# Define parameter grid
param_grid = {
    'learning_rate': [0.01, 0.05, 0.1],
    'n_estimators': [50, 100, 200],
    'max_depth': [3, 5, 7],
    'subsample': [0.8, 1.0]
}

# Generate all combinations
param_combinations = [
    dict(zip(param_grid.keys(), v))
    for v in product(*param_grid.values())
]

# Parent run
with mlflow.start_run(run_name="grid-search-parent") as parent_run:
    # Log search configuration
    mlflow.log_param("total_combinations", len(param_combinations))
    mlflow.log_param("cv_folds", 5)
    mlflow.log_param("scoring_metric", "accuracy")

    best_score = 0
    best_params = None
    best_run_id = None

    # Nested runs for each combination
    for idx, params in enumerate(param_combinations):
        with mlflow.start_run(
            run_name=f"combo_{idx}",
            nested=True
        ) as child_run:
            # Train model with current parameters
            model = GradientBoostingClassifier(**params, random_state=42)

            # Cross-validation
            cv_scores = cross_val_score(
                model, X_train, y_train,
                cv=5,
                scoring='accuracy'
            )

            mean_score = cv_scores.mean()
            std_score = cv_scores.std()

            # Log parameters and metrics
            mlflow.log_params(params)
            mlflow.log_metric("cv_mean_score", mean_score)
            mlflow.log_metric("cv_std_score", std_score)

            # Track best model
            if mean_score > best_score:
                best_score = mean_score
                best_params = params
                best_run_id = child_run.info.run_id

            print(f"Combination {idx+1}/{len(param_combinations)}: "
                  f"Score = {mean_score:.4f} (+/- {std_score:.4f})")

    # Log best results in parent run
    mlflow.log_params({f"best_{k}": v for k, v in best_params.items()})
    mlflow.log_metric("best_cv_score", best_score)
    mlflow.set_tag("best_run_id", best_run_id)

    # Train final model with best parameters
    final_model = GradientBoostingClassifier(**best_params, random_state=42)
    final_model.fit(X_train, y_train)

    # Log best model
    mlflow.sklearn.log_model(
        sk_model=final_model,
        name="best_model",
        registered_model_name="OptimizedGradientBoostingClassifier"
    )

    print(f"\nBest parameters: {best_params}")
    print(f"Best CV score: {best_score:.4f}")
```

**Explanation**: This example uses nested runs to organize hyperparameter search. The parent run contains the overall search configuration and best results, while child runs track individual parameter combinations. This structure makes it easy to compare and analyze different configurations.

---

### Example 4: Multi-Metric Tracking with Custom Visualizations

**Description**: Track multiple metrics over time and create custom visualizations.

**Use Case**: Detailed model training analysis with learning curves.

```python
import mlflow
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import learning_curve
from sklearn.ensemble import RandomForestClassifier

mlflow.set_experiment("learning-curve-analysis")

with mlflow.start_run(run_name="learning-curve-experiment"):
    # Model parameters
    params = {
        "n_estimators": 100,
        "max_depth": 10,
        "random_state": 42
    }
    mlflow.log_params(params)

    model = RandomForestClassifier(**params)

    # Generate learning curves
    train_sizes, train_scores, val_scores = learning_curve(
        model, X_train, y_train,
        cv=5,
        n_jobs=-1,
        train_sizes=np.linspace(0.1, 1.0, 10),
        scoring='accuracy'
    )

    # Calculate mean and std
    train_mean = train_scores.mean(axis=1)
    train_std = train_scores.std(axis=1)
    val_mean = val_scores.mean(axis=1)
    val_std = val_scores.std(axis=1)

    # Log metrics at different training sizes
    for i, size in enumerate(train_sizes):
        mlflow.log_metric("train_score", train_mean[i], step=int(size))
        mlflow.log_metric("val_score", val_mean[i], step=int(size))
        mlflow.log_metric("train_std", train_std[i], step=int(size))
        mlflow.log_metric("val_std", val_std[i], step=int(size))

    # Create learning curve plot
    plt.figure(figsize=(10, 6))
    plt.plot(train_sizes, train_mean, label='Training score', marker='o')
    plt.plot(train_sizes, val_mean, label='Validation score', marker='s')
    plt.fill_between(train_sizes, train_mean - train_std,
                     train_mean + train_std, alpha=0.1)
    plt.fill_between(train_sizes, val_mean - val_std,
                     val_mean + val_std, alpha=0.1)
    plt.xlabel('Training Examples')
    plt.ylabel('Score')
    plt.title('Learning Curves')
    plt.legend(loc='best')
    plt.grid(True)

    # Save and log plot
    plt.savefig('learning_curve.png', dpi=300, bbox_inches='tight')
    mlflow.log_artifact('learning_curve.png')
    plt.close()

    # Train final model and log
    model.fit(X_train, y_train)
    final_score = model.score(X_test, y_test)
    mlflow.log_metric("final_test_score", final_score)

    mlflow.sklearn.log_model(
        sk_model=model,
        name="model",
        registered_model_name="LearningCurveModel"
    )

    print(f"Final test score: {final_score:.4f}")
```

**Explanation**: This example demonstrates tracking multiple metrics at different stages of training and creating custom visualizations. The learning curve plot is saved as an artifact for later analysis.

---

## Model Registry Examples

### Example 5: Complete Model Registration Workflow

**Description**: Register, version, and manage models through their lifecycle.

**Use Case**: Production model management with versioning and staging.

```python
from mlflow import MlflowClient
import mlflow.sklearn
from sklearn.ensemble import RandomForestClassifier
from datetime import datetime

client = MlflowClient()
mlflow.set_tracking_uri("http://localhost:5000")

# Step 1: Create registered model
model_name = "CustomerChurnPredictor"

try:
    client.create_registered_model(
        name=model_name,
        description="Machine learning model for predicting customer churn"
    )
    print(f"Created registered model: {model_name}")
except Exception as e:
    print(f"Model {model_name} already exists")

# Step 2: Train and register version 1
with mlflow.start_run(run_name="churn-model-v1") as run:
    # Train model
    params_v1 = {"n_estimators": 50, "max_depth": 5}
    model_v1 = RandomForestClassifier(**params_v1)
    model_v1.fit(X_train, y_train)

    score_v1 = model_v1.score(X_test, y_test)

    # Log model
    mlflow.log_params(params_v1)
    mlflow.log_metric("accuracy", score_v1)

    model_uri_v1 = f"runs:/{run.info.run_id}/model"
    mlflow.sklearn.log_model(
        sk_model=model_v1,
        name="model",
        registered_model_name=model_name
    )

# Step 3: Add metadata to version 1
versions = client.search_model_versions(f"name='{model_name}'")
version_1 = versions[0].version

client.update_model_version(
    name=model_name,
    version=version_1,
    description="Baseline model trained on historical data (2023)"
)

# Set tags
client.set_model_version_tag(model_name, version_1, "training_date", datetime.now().isoformat())
client.set_model_version_tag(model_name, version_1, "data_version", "v1.0")
client.set_model_version_tag(model_name, version_1, "validated", "true")

# Step 4: Set alias for staging
client.set_registered_model_alias(
    name=model_name,
    alias="staging",
    version=version_1
)

print(f"Model version {version_1} set to staging")

# Step 5: Train improved version 2
with mlflow.start_run(run_name="churn-model-v2") as run:
    params_v2 = {"n_estimators": 100, "max_depth": 10}
    model_v2 = RandomForestClassifier(**params_v2)
    model_v2.fit(X_train, y_train)

    score_v2 = model_v2.score(X_test, y_test)

    mlflow.log_params(params_v2)
    mlflow.log_metric("accuracy", score_v2)

    mlflow.sklearn.log_model(
        sk_model=model_v2,
        name="model",
        registered_model_name=model_name
    )

# Step 6: Compare versions and promote
if score_v2 > score_v1:
    version_2 = str(int(version_1) + 1)

    # Update version 2 metadata
    client.update_model_version(
        name=model_name,
        version=version_2,
        description=f"Improved model - {(score_v2 - score_v1) / score_v1 * 100:.2f}% better than v1"
    )

    # Set to production
    client.set_registered_model_alias(
        name=model_name,
        alias="production",
        version=version_2
    )

    # Keep v1 as challenger for A/B testing
    client.set_registered_model_alias(
        name=model_name,
        alias="challenger",
        version=version_1
    )

    print(f"Version {version_2} promoted to production")
    print(f"Version {version_1} set as challenger")
else:
    print("New model not better than current version")

# Step 7: Load models by alias
production_model = mlflow.sklearn.load_model(f"models:/{model_name}@production")
staging_model = mlflow.sklearn.load_model(f"models:/{model_name}@staging")

print("\nModel registry workflow complete!")
```

**Explanation**: This comprehensive example shows the complete model registry workflow including creation, versioning, metadata management, aliasing, and comparison-based promotion. Models can be loaded by alias for consistent deployment.

---

### Example 6: Model Lifecycle Management with Validation Gates

**Description**: Implement automated validation before model promotion.

**Use Case**: Ensure only validated models reach production.

```python
from mlflow import MlflowClient
from sklearn.metrics import classification_report, confusion_matrix
import mlflow
import json

class ModelValidator:
    def __init__(self, model_name, thresholds):
        self.model_name = model_name
        self.thresholds = thresholds
        self.client = MlflowClient()

    def validate_model(self, version, X_test, y_test):
        """Validate model against defined thresholds"""

        # Load model version
        model_uri = f"models:/{self.model_name}/{version}"
        model = mlflow.sklearn.load_model(model_uri)

        # Make predictions
        y_pred = model.predict(X_test)

        # Generate classification report
        report = classification_report(y_test, y_pred, output_dict=True)

        # Check thresholds
        validation_results = {
            "passed": True,
            "metrics": {},
            "failures": []
        }

        for metric, threshold in self.thresholds.items():
            value = report['weighted avg'][metric]
            validation_results["metrics"][metric] = value

            if value < threshold:
                validation_results["passed"] = False
                validation_results["failures"].append(
                    f"{metric}: {value:.3f} < {threshold:.3f}"
                )

        # Save validation report
        with open("validation_report.json", "w") as f:
            json.dump(validation_results, f, indent=2)

        # Update model version with validation results
        self.client.set_model_version_tag(
            self.model_name,
            version,
            "validation_status",
            "passed" if validation_results["passed"] else "failed"
        )

        for metric, value in validation_results["metrics"].items():
            self.client.set_model_version_tag(
                self.model_name,
                version,
                f"validation_{metric}",
                f"{value:.4f}"
            )

        return validation_results

    def promote_if_valid(self, version, X_test, y_test, target_alias="production"):
        """Validate and promote model if it passes"""

        validation = self.validate_model(version, X_test, y_test)

        if validation["passed"]:
            self.client.set_registered_model_alias(
                name=self.model_name,
                alias=target_alias,
                version=version
            )
            print(f"✓ Model version {version} promoted to {target_alias}")
            return True
        else:
            print(f"✗ Model version {version} failed validation:")
            for failure in validation["failures"]:
                print(f"  - {failure}")
            return False

# Usage
validator = ModelValidator(
    model_name="CustomerChurnPredictor",
    thresholds={
        "precision": 0.85,
        "recall": 0.80,
        "f1-score": 0.82
    }
)

# Validate and promote
success = validator.promote_if_valid(
    version="3",
    X_test=X_test,
    y_test=y_test,
    target_alias="production"
)
```

**Explanation**: This example implements a validation framework that checks model performance against defined thresholds before allowing promotion to production. Validation results are stored as model version tags for auditing.

---

## Deployment Examples

### Example 7: REST API Deployment with Custom Inference

**Description**: Deploy model as REST API with custom preprocessing logic.

**Use Case**: Production serving with request preprocessing.

```python
import mlflow
from mlflow.pyfunc import PythonModel
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler

class CustomModelWrapper(PythonModel):
    """Custom model wrapper with preprocessing"""

    def load_context(self, context):
        """Load model and preprocessing artifacts"""
        import pickle

        # Load the ML model
        self.model = mlflow.sklearn.load_model(context.artifacts["model"])

        # Load preprocessing artifacts
        with open(context.artifacts["scaler"], "rb") as f:
            self.scaler = pickle.load(f)

    def predict(self, context, model_input):
        """Custom prediction with preprocessing"""

        # Preprocess input
        if isinstance(model_input, pd.DataFrame):
            # Handle missing values
            model_input = model_input.fillna(model_input.mean())

            # Scale features
            scaled_input = self.scaler.transform(model_input)

            # Make prediction
            predictions = self.model.predict(scaled_input)

            # Add confidence scores
            probabilities = self.model.predict_proba(scaled_input)
            max_probs = probabilities.max(axis=1)

            # Return predictions with metadata
            return pd.DataFrame({
                'prediction': predictions,
                'confidence': max_probs
            })
        else:
            raise ValueError("Input must be a pandas DataFrame")

# Save preprocessing artifacts
import pickle
scaler = StandardScaler()
scaler.fit(X_train)

with open("scaler.pkl", "wb") as f:
    pickle.dump(scaler, f)

# Train and save model
from sklearn.ensemble import RandomForestClassifier
model = RandomForestClassifier(n_estimators=100)
model.fit(scaler.transform(X_train), y_train)

with mlflow.start_run():
    # Define artifacts
    artifacts = {
        "model": "model",
        "scaler": "scaler.pkl"
    }

    # Log the base model first
    mlflow.sklearn.log_model(model, "model")

    # Create and log custom model
    mlflow.pyfunc.log_model(
        artifact_path="custom_model",
        python_model=CustomModelWrapper(),
        artifacts=artifacts,
        registered_model_name="CustomChurnPredictor"
    )

# Serve the model
# Terminal: mlflow models serve -m models:/CustomChurnPredictor@production -p 5001

# Client code to test the API
import requests
import json

url = "http://localhost:5001/invocations"
headers = {"Content-Type": "application/json"}

test_data = {
    "dataframe_split": {
        "columns": ["feature1", "feature2", "feature3"],
        "data": [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]
    }
}

response = requests.post(url, headers=headers, data=json.dumps(test_data))
predictions = response.json()
print("Predictions:", predictions)
```

**Explanation**: This example shows how to create a custom model wrapper that includes preprocessing logic. The wrapper is deployed as a REST API, providing a complete inference pipeline.

---

### Example 8: Batch Inference Pipeline

**Description**: Process large datasets in batches with progress tracking.

**Use Case**: Offline batch scoring for large customer bases.

```python
import mlflow
import pandas as pd
import numpy as np
from tqdm import tqdm
from datetime import datetime

class BatchInferencePipeline:
    def __init__(self, model_uri, batch_size=1000):
        self.model = mlflow.pyfunc.load_model(model_uri)
        self.batch_size = batch_size
        mlflow.set_experiment("batch-inference")

    def process_batch(self, data_path, output_path):
        """Process data in batches and save results"""

        with mlflow.start_run(run_name=f"batch-{datetime.now().isoformat()}"):
            # Log configuration
            mlflow.log_param("input_file", data_path)
            mlflow.log_param("batch_size", self.batch_size)

            # Load data
            print("Loading data...")
            data = pd.read_csv(data_path)
            total_rows = len(data)
            mlflow.log_param("total_rows", total_rows)

            # Process in batches
            predictions = []
            batch_times = []

            num_batches = (total_rows + self.batch_size - 1) // self.batch_size

            for i in tqdm(range(0, total_rows, self.batch_size), desc="Processing batches"):
                start_time = datetime.now()

                # Get batch
                batch = data.iloc[i:i + self.batch_size]

                # Predict
                batch_predictions = self.model.predict(batch)
                predictions.extend(batch_predictions)

                # Track timing
                batch_time = (datetime.now() - start_time).total_seconds()
                batch_times.append(batch_time)

                # Log metrics every 10 batches
                if (i // self.batch_size) % 10 == 0:
                    mlflow.log_metric("avg_batch_time", np.mean(batch_times), step=i)

            # Save results
            results = pd.DataFrame({
                'id': data['id'] if 'id' in data.columns else range(total_rows),
                'prediction': predictions,
                'processed_at': datetime.now().isoformat()
            })

            results.to_csv(output_path, index=False)

            # Log summary metrics
            mlflow.log_metric("total_predictions", total_rows)
            mlflow.log_metric("avg_batch_time_sec", np.mean(batch_times))
            mlflow.log_metric("total_time_sec", sum(batch_times))
            mlflow.log_metric("predictions_per_sec", total_rows / sum(batch_times))

            # Log output file
            mlflow.log_artifact(output_path)

            print(f"\nProcessed {total_rows} rows in {sum(batch_times):.2f} seconds")
            print(f"Average: {total_rows / sum(batch_times):.0f} predictions/second")

            return results

# Usage
pipeline = BatchInferencePipeline(
    model_uri="models:/CustomerChurnPredictor@production",
    batch_size=1000
)

results = pipeline.process_batch(
    data_path="customer_data.csv",
    output_path="churn_predictions.csv"
)
```

**Explanation**: This example implements a batch inference pipeline that processes large datasets efficiently. It tracks performance metrics and saves results, making it suitable for scheduled batch scoring jobs.

---

## Monitoring Examples

### Example 9: Production Model Performance Monitoring

**Description**: Monitor model performance in production with drift detection.

**Use Case**: Continuous monitoring of deployed models.

```python
import mlflow
import pandas as pd
import numpy as np
from sklearn.metrics import accuracy_score, precision_recall_fscore_support
from scipy import stats
from datetime import datetime, timedelta

class ProductionMonitor:
    def __init__(self, model_name, tracking_uri):
        self.model_name = model_name
        mlflow.set_tracking_uri(tracking_uri)
        mlflow.set_experiment(f"{model_name}-monitoring")

        # Load reference statistics (from training data)
        self.reference_stats = None

    def set_reference_data(self, X_reference):
        """Set reference data statistics for drift detection"""
        self.reference_stats = {
            col: {
                'mean': X_reference[col].mean(),
                'std': X_reference[col].std(),
                'min': X_reference[col].min(),
                'max': X_reference[col].max()
            }
            for col in X_reference.columns
        }

    def detect_data_drift(self, X_current):
        """Detect data drift using statistical tests"""
        if self.reference_stats is None:
            raise ValueError("Reference data not set")

        drift_results = {}

        for col in X_current.columns:
            if col not in self.reference_stats:
                continue

            # Kolmogorov-Smirnov test
            ref_mean = self.reference_stats[col]['mean']
            ref_std = self.reference_stats[col]['std']

            # Generate reference distribution
            ref_sample = np.random.normal(ref_mean, ref_std, len(X_current))

            # KS test
            ks_stat, p_value = stats.ks_2samp(ref_sample, X_current[col])

            drift_results[col] = {
                'ks_statistic': ks_stat,
                'p_value': p_value,
                'drift_detected': p_value < 0.05,
                'current_mean': X_current[col].mean(),
                'reference_mean': ref_mean,
                'mean_shift_percent': abs((X_current[col].mean() - ref_mean) / ref_mean * 100)
            }

        return drift_results

    def monitor_predictions(self, y_true, y_pred, X_current, timestamp=None):
        """Monitor model performance and data drift"""
        if timestamp is None:
            timestamp = datetime.now()

        with mlflow.start_run(run_name=f"monitor-{timestamp.isoformat()}"):
            # Log timestamp
            mlflow.log_param("timestamp", timestamp.isoformat())
            mlflow.log_param("sample_size", len(y_true))

            # Calculate performance metrics
            accuracy = accuracy_score(y_true, y_pred)
            precision, recall, f1, _ = precision_recall_fscore_support(
                y_true, y_pred, average='weighted'
            )

            metrics = {
                "accuracy": accuracy,
                "precision": precision,
                "recall": recall,
                "f1_score": f1
            }

            # Log performance metrics
            for metric_name, value in metrics.items():
                mlflow.log_metric(metric_name, value)

            # Performance alerts
            if accuracy < 0.85:
                mlflow.set_tag("alert_type", "performance_degradation")
                mlflow.set_tag("alert_severity", "high")
                print(f"⚠️  ALERT: Accuracy dropped to {accuracy:.3f}")

            # Data drift detection
            if self.reference_stats:
                drift_results = self.detect_data_drift(X_current)

                # Log drift metrics
                high_drift_features = []
                for feature, result in drift_results.items():
                    mlflow.log_metric(f"drift_{feature}_ks_stat", result['ks_statistic'])
                    mlflow.log_metric(f"drift_{feature}_p_value", result['p_value'])
                    mlflow.log_metric(f"drift_{feature}_mean_shift", result['mean_shift_percent'])

                    if result['drift_detected']:
                        high_drift_features.append(feature)

                if high_drift_features:
                    mlflow.set_tag("drift_detected", "yes")
                    mlflow.set_tag("drift_features", ",".join(high_drift_features))
                    print(f"⚠️  DATA DRIFT detected in: {', '.join(high_drift_features)}")

            # Prediction distribution
            unique, counts = np.unique(y_pred, return_counts=True)
            pred_dist = dict(zip(unique, counts))
            mlflow.log_params({f"pred_class_{k}_count": v for k, v in pred_dist.items()})

            return metrics

    def generate_monitoring_report(self, days=7):
        """Generate monitoring report for the last N days"""
        from mlflow.tracking import MlflowClient

        client = MlflowClient()
        experiment = client.get_experiment_by_name(f"{self.model_name}-monitoring")

        if experiment is None:
            print("No monitoring data found")
            return

        # Get runs from last N days
        cutoff_time = int((datetime.now() - timedelta(days=days)).timestamp() * 1000)
        runs = client.search_runs(
            experiment_ids=[experiment.experiment_id],
            filter_string=f"attributes.start_time > {cutoff_time}",
            order_by=["attributes.start_time DESC"]
        )

        # Aggregate metrics
        report_data = []
        for run in runs:
            report_data.append({
                'timestamp': datetime.fromtimestamp(run.info.start_time / 1000),
                'accuracy': run.data.metrics.get('accuracy'),
                'precision': run.data.metrics.get('precision'),
                'recall': run.data.metrics.get('recall'),
                'drift_detected': run.data.tags.get('drift_detected', 'no')
            })

        report_df = pd.DataFrame(report_data)

        # Create report visualizations
        import matplotlib.pyplot as plt

        fig, axes = plt.subplots(2, 1, figsize=(12, 8))

        # Performance over time
        axes[0].plot(report_df['timestamp'], report_df['accuracy'], marker='o', label='Accuracy')
        axes[0].plot(report_df['timestamp'], report_df['precision'], marker='s', label='Precision')
        axes[0].plot(report_df['timestamp'], report_df['recall'], marker='^', label='Recall')
        axes[0].axhline(y=0.85, color='r', linestyle='--', label='Threshold')
        axes[0].set_xlabel('Date')
        axes[0].set_ylabel('Score')
        axes[0].set_title('Model Performance Over Time')
        axes[0].legend()
        axes[0].grid(True)

        # Drift incidents
        drift_counts = report_df.groupby('drift_detected').size()
        axes[1].bar(drift_counts.index, drift_counts.values)
        axes[1].set_xlabel('Drift Detected')
        axes[1].set_ylabel('Count')
        axes[1].set_title('Data Drift Incidents')

        plt.tight_layout()
        plt.savefig('monitoring_report.png', dpi=300)

        print(f"Monitoring Report ({days} days):")
        print(f"  Total monitoring runs: {len(report_df)}")
        print(f"  Average accuracy: {report_df['accuracy'].mean():.3f}")
        print(f"  Drift incidents: {(report_df['drift_detected'] == 'yes').sum()}")

        return report_df

# Usage
monitor = ProductionMonitor(
    model_name="CustomerChurnPredictor",
    tracking_uri="http://localhost:5000"
)

# Set reference data
monitor.set_reference_data(X_train)

# Monitor daily predictions
metrics = monitor.monitor_predictions(
    y_true=actual_labels,
    y_pred=predictions,
    X_current=current_data
)

# Generate weekly report
report = monitor.generate_monitoring_report(days=7)
```

**Explanation**: This comprehensive monitoring example tracks model performance, detects data drift using statistical tests, and generates monitoring reports. It provides alerts for performance degradation and data distribution changes.

---

### Example 10: Prediction Logging and Audit Trail

**Description**: Log all predictions for compliance and debugging.

**Use Case**: Regulatory compliance and troubleshooting.

```python
import mlflow
import pandas as pd
import hashlib
from datetime import datetime
import json

class PredictionLogger:
    def __init__(self, model_name, model_version):
        self.model_name = model_name
        self.model_version = model_version
        mlflow.set_experiment(f"{model_name}-predictions")

    def log_prediction(self, input_data, prediction, metadata=None):
        """Log individual prediction with full audit trail"""

        # Generate unique prediction ID
        prediction_id = hashlib.md5(
            f"{datetime.now().isoformat()}{str(input_data)}".encode()
        ).hexdigest()

        with mlflow.start_run(run_name=f"pred-{prediction_id[:8]}"):
            # Log model info
            mlflow.log_param("model_name", self.model_name)
            mlflow.log_param("model_version", self.model_version)
            mlflow.log_param("prediction_id", prediction_id)
            mlflow.log_param("timestamp", datetime.now().isoformat())

            # Log input features
            if isinstance(input_data, pd.DataFrame):
                for col in input_data.columns:
                    mlflow.log_param(f"input_{col}", str(input_data[col].values[0]))
            elif isinstance(input_data, dict):
                mlflow.log_params({f"input_{k}": str(v) for k, v in input_data.items()})

            # Log prediction
            mlflow.log_metric("prediction", float(prediction))

            # Log metadata
            if metadata:
                mlflow.log_params({f"meta_{k}": str(v) for k, v in metadata.items()})

            # Save detailed log
            log_entry = {
                "prediction_id": prediction_id,
                "timestamp": datetime.now().isoformat(),
                "model": f"{self.model_name}:{self.model_version}",
                "input": input_data.to_dict() if hasattr(input_data, 'to_dict') else input_data,
                "prediction": float(prediction),
                "metadata": metadata or {}
            }

            with open(f"prediction_{prediction_id}.json", "w") as f:
                json.dump(log_entry, f, indent=2)

            mlflow.log_artifact(f"prediction_{prediction_id}.json")

        return prediction_id

    def log_batch_predictions(self, inputs, predictions, metadata=None):
        """Log batch of predictions"""

        with mlflow.start_run(run_name=f"batch-{datetime.now().isoformat()}"):
            # Log batch info
            mlflow.log_param("model_name", self.model_name)
            mlflow.log_param("model_version", self.model_version)
            mlflow.log_param("batch_size", len(predictions))
            mlflow.log_param("timestamp", datetime.now().isoformat())

            # Log prediction statistics
            mlflow.log_metric("mean_prediction", predictions.mean())
            mlflow.log_metric("std_prediction", predictions.std())
            mlflow.log_metric("min_prediction", predictions.min())
            mlflow.log_metric("max_prediction", predictions.max())

            # Save batch results
            results = pd.DataFrame({
                'input_data': [str(x) for x in inputs],
                'prediction': predictions
            })

            results_file = f"batch_predictions_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
            results.to_csv(results_file, index=False)
            mlflow.log_artifact(results_file)

            if metadata:
                mlflow.log_params({f"meta_{k}": str(v) for k, v in metadata.items()})

# Usage
logger = PredictionLogger(
    model_name="CustomerChurnPredictor",
    model_version="3"
)

# Log single prediction
input_data = pd.DataFrame([[1.0, 2.0, 3.0]], columns=['feature1', 'feature2', 'feature3'])
prediction = 0.85

prediction_id = logger.log_prediction(
    input_data=input_data,
    prediction=prediction,
    metadata={
        "user_id": "user123",
        "request_source": "mobile_app",
        "region": "us-west"
    }
)

print(f"Logged prediction: {prediction_id}")

# Log batch predictions
batch_inputs = X_test
batch_predictions = model.predict_proba(X_test)[:, 1]

logger.log_batch_predictions(
    inputs=batch_inputs,
    predictions=batch_predictions,
    metadata={"source": "daily_batch_job"}
)
```

**Explanation**: This example implements comprehensive prediction logging for audit trails and compliance. Each prediction is logged with full context including inputs, outputs, model version, and custom metadata.

---

## A/B Testing Examples

### Example 11: A/B Test Framework with Statistical Analysis

**Description**: Compare two model variants with proper statistical testing.

**Use Case**: Production A/B testing to validate new model versions.

```python
import mlflow
import numpy as np
from scipy import stats
from datetime import datetime
import pandas as pd

class ABTestFramework:
    def __init__(self, model_a_uri, model_b_uri, split_ratio=0.5):
        """
        Initialize A/B test framework

        Args:
            model_a_uri: URI for control model (champion)
            model_b_uri: URI for treatment model (challenger)
            split_ratio: Fraction of traffic to model A (default 0.5)
        """
        self.model_a = mlflow.pyfunc.load_model(model_a_uri)
        self.model_b = mlflow.pyfunc.load_model(model_b_uri)
        self.split_ratio = split_ratio

        # Results storage
        self.results_a = []
        self.results_b = []

        mlflow.set_experiment("ab-testing")

    def assign_variant(self, user_id):
        """Deterministic variant assignment based on user ID"""
        # Hash user ID to get consistent assignment
        hash_value = hash(str(user_id))
        return "A" if (hash_value % 100) < (self.split_ratio * 100) else "B"

    def predict(self, data, user_id, actual_outcome=None):
        """Make prediction with assigned variant"""

        variant = self.assign_variant(user_id)

        # Get prediction from assigned model
        if variant == "A":
            prediction = self.model_a.predict(data)[0]
            model_name = "model_a"
        else:
            prediction = self.model_b.predict(data)[0]
            model_name = "model_b"

        # Log prediction
        with mlflow.start_run(run_name=f"ab-prediction"):
            mlflow.log_param("variant", variant)
            mlflow.log_param("user_id", user_id)
            mlflow.log_metric("prediction", float(prediction))

            if actual_outcome is not None:
                mlflow.log_metric("actual_outcome", float(actual_outcome))
                mlflow.log_metric("correct", int(prediction == actual_outcome))

        # Store results for analysis
        if variant == "A":
            self.results_a.append({
                'prediction': prediction,
                'actual': actual_outcome,
                'user_id': user_id,
                'timestamp': datetime.now()
            })
        else:
            self.results_b.append({
                'prediction': prediction,
                'actual': actual_outcome,
                'user_id': user_id,
                'timestamp': datetime.now()
            })

        return prediction, variant

    def analyze_test(self, metric='accuracy'):
        """Analyze A/B test results with statistical significance"""

        with mlflow.start_run(run_name="ab-test-analysis"):
            # Convert to DataFrames
            df_a = pd.DataFrame(self.results_a)
            df_b = pd.DataFrame(self.results_b)

            # Calculate metrics
            if metric == 'accuracy':
                score_a = (df_a['prediction'] == df_a['actual']).mean()
                score_b = (df_b['prediction'] == df_b['actual']).mean()
            else:
                score_a = df_a['prediction'].mean()
                score_b = df_b['prediction'].mean()

            # Log sample sizes
            mlflow.log_param("sample_size_a", len(df_a))
            mlflow.log_param("sample_size_b", len(df_b))
            mlflow.log_param("metric", metric)

            # Log performance metrics
            mlflow.log_metric("score_a", score_a)
            mlflow.log_metric("score_b", score_b)
            mlflow.log_metric("score_diff", score_b - score_a)
            mlflow.log_metric("score_diff_percent", (score_b - score_a) / score_a * 100)

            # Statistical testing (t-test for continuous, chi-square for binary)
            if metric == 'accuracy':
                # Chi-square test for categorical outcomes
                contingency_table = pd.crosstab(
                    pd.concat([df_a['actual'], df_b['actual']]),
                    pd.concat([
                        pd.Series(['A'] * len(df_a)),
                        pd.Series(['B'] * len(df_b))
                    ])
                )
                chi2, p_value, _, _ = stats.chi2_contingency(contingency_table)
                mlflow.log_metric("chi2_statistic", chi2)
            else:
                # T-test for continuous outcomes
                t_stat, p_value = stats.ttest_ind(
                    df_a['prediction'],
                    df_b['prediction']
                )
                mlflow.log_metric("t_statistic", t_stat)

            mlflow.log_metric("p_value", p_value)

            # Determine significance and winner
            is_significant = p_value < 0.05
            mlflow.set_tag("statistically_significant", str(is_significant))

            if is_significant:
                winner = "B" if score_b > score_a else "A"
                mlflow.set_tag("winner", winner)
                mlflow.set_tag("recommendation",
                    f"Promote Model {winner} to production")
            else:
                mlflow.set_tag("winner", "None")
                mlflow.set_tag("recommendation",
                    "Continue test - no significant difference")

            # Generate report
            report = {
                "test_duration_days": (df_b['timestamp'].max() - df_b['timestamp'].min()).days,
                "sample_size_a": len(df_a),
                "sample_size_b": len(df_b),
                "score_a": score_a,
                "score_b": score_b,
                "improvement": (score_b - score_a) / score_a * 100,
                "p_value": p_value,
                "significant": is_significant,
                "winner": winner if is_significant else "None"
            }

            print("\n=== A/B Test Results ===")
            print(f"Model A ({len(df_a)} samples): {metric} = {score_a:.4f}")
            print(f"Model B ({len(df_b)} samples): {metric} = {score_b:.4f}")
            print(f"Improvement: {report['improvement']:.2f}%")
            print(f"P-value: {p_value:.4f}")
            print(f"Significant: {is_significant}")
            if is_significant:
                print(f"Winner: Model {winner}")

            return report

# Usage
ab_test = ABTestFramework(
    model_a_uri="models:/CustomerChurnModel@champion",
    model_b_uri="models:/CustomerChurnModel@challenger",
    split_ratio=0.5
)

# Run test with production traffic
for user_id in customer_ids:
    customer_data = get_customer_features(user_id)
    prediction, variant = ab_test.predict(customer_data, user_id)

    # After some time, record actual outcome
    actual_outcome = get_actual_outcome(user_id)
    ab_test.predict(customer_data, user_id, actual_outcome=actual_outcome)

# Analyze after collecting sufficient data
results = ab_test.analyze_test(metric='accuracy')
```

**Explanation**: This A/B testing framework provides deterministic user assignment, prediction tracking, and rigorous statistical analysis to determine if a new model variant should replace the current production model.

---

## More examples continue in next section...

### Example 12: Multi-Armed Bandit Testing

**Description**: Dynamically allocate traffic to best-performing model variant.

**Use Case**: Continuous optimization with exploration-exploitation trade-off.

```python
import mlflow
import numpy as np
from scipy.stats import beta
from datetime import datetime

class MultiArmedBandit:
    """Thompson Sampling for model selection"""

    def __init__(self, model_uris, model_names):
        """
        Initialize Multi-Armed Bandit

        Args:
            model_uris: List of model URIs
            model_names: List of model names
        """
        self.models = [mlflow.pyfunc.load_model(uri) for uri in model_uris]
        self.model_names = model_names
        self.n_models = len(model_uris)

        # Initialize priors (Beta distribution parameters)
        self.successes = np.ones(self.n_models)  # alpha
        self.failures = np.ones(self.n_models)   # beta

        mlflow.set_experiment("multi-armed-bandit")

    def select_model(self):
        """Select model using Thompson Sampling"""
        # Sample from each model's Beta distribution
        samples = [
            np.random.beta(self.successes[i], self.failures[i])
            for i in range(self.n_models)
        ]

        # Select model with highest sample
        selected_idx = np.argmax(samples)

        return selected_idx

    def predict_and_update(self, data, user_id, actual_outcome=None):
        """Make prediction and update model performance"""

        # Select model
        model_idx = self.select_model()
        model_name = self.model_names[model_idx]

        # Predict
        prediction = self.models[model_idx].predict(data)[0]

        # Log prediction
        with mlflow.start_run(run_name=f"mab-{datetime.now().isoformat()[:19]}"):
            mlflow.log_param("selected_model", model_name)
            mlflow.log_param("model_index", model_idx)
            mlflow.log_param("user_id", user_id)
            mlflow.log_metric("prediction", float(prediction))

            # Log current success rates
            for i, name in enumerate(self.model_names):
                success_rate = self.successes[i] / (self.successes[i] + self.failures[i])
                mlflow.log_metric(f"success_rate_{name}", success_rate)

            # Update if outcome is known
            if actual_outcome is not None:
                correct = int(prediction == actual_outcome)

                if correct:
                    self.successes[model_idx] += 1
                else:
                    self.failures[model_idx] += 1

                mlflow.log_metric("actual_outcome", float(actual_outcome))
                mlflow.log_metric("correct", correct)

                # Updated success rate
                updated_rate = self.successes[model_idx] / (
                    self.successes[model_idx] + self.failures[model_idx]
                )
                mlflow.log_metric("updated_success_rate", updated_rate)

        return prediction, model_name

    def get_statistics(self):
        """Get current bandit statistics"""
        stats = {}

        for i, name in enumerate(self.model_names):
            total = self.successes[i] + self.failures[i]
            success_rate = self.successes[i] / total

            stats[name] = {
                'success_rate': success_rate,
                'total_pulls': total - 2,  # Subtract prior
                'successes': self.successes[i] - 1,
                'failures': self.failures[i] - 1,
                'confidence_interval_95': beta.interval(
                    0.95, self.successes[i], self.failures[i]
                )
            }

        return stats

    def plot_distributions(self):
        """Visualize current belief distributions"""
        import matplotlib.pyplot as plt

        x = np.linspace(0, 1, 1000)

        plt.figure(figsize=(12, 6))
        for i, name in enumerate(self.model_names):
            y = beta.pdf(x, self.successes[i], self.failures[i])
            plt.plot(x, y, label=name, linewidth=2)

        plt.xlabel('Success Rate')
        plt.ylabel('Probability Density')
        plt.title('Model Performance Distributions')
        plt.legend()
        plt.grid(True, alpha=0.3)

        plt.savefig('mab_distributions.png', dpi=300, bbox_inches='tight')
        plt.close()

# Usage
mab = MultiArmedBandit(
    model_uris=[
        "models:/ChurnModel/1",
        "models:/ChurnModel/2",
        "models:/ChurnModel/3"
    ],
    model_names=["baseline", "improved", "experimental"]
)

# Run predictions
for user_id in customer_ids:
    customer_data = get_customer_features(user_id)

    # Predict
    prediction, selected_model = mab.predict_and_update(customer_data, user_id)

    # Later, update with actual outcome
    actual = get_actual_outcome(user_id)
    mab.predict_and_update(customer_data, user_id, actual_outcome=actual)

# View statistics
stats = mab.get_statistics()
for model, model_stats in stats.items():
    print(f"\n{model}:")
    print(f"  Success Rate: {model_stats['success_rate']:.3f}")
    print(f"  Total Pulls: {model_stats['total_pulls']}")
    print(f"  95% CI: {model_stats['confidence_interval_95']}")

# Plot distributions
mab.plot_distributions()
```

**Explanation**: The Multi-Armed Bandit approach dynamically allocates more traffic to better-performing models while still exploring alternatives. This is more efficient than fixed A/B testing when you want to minimize regret during the test period.

---

## Feature Engineering Examples

### Example 13: Feature Store with MLflow

**Description**: Version and track feature engineering pipelines.

**Use Case**: Reproducible feature engineering for model training and serving.

```python
import mlflow
import pandas as pd
import numpy as np
from datetime import datetime
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer

class MLflowFeatureStore:
    def __init__(self, experiment_name="feature-store"):
        mlflow.set_experiment(experiment_name)

    def create_feature_set(self, df, feature_set_name, transformers=None):
        """Create and version a feature set with transformations"""

        with mlflow.start_run(run_name=f"{feature_set_name}-{datetime.now().strftime('%Y%m%d')}"):
            # Log metadata
            mlflow.log_param("feature_set_name", feature_set_name)
            mlflow.log_param("num_rows", len(df))
            mlflow.log_param("num_features", len(df.columns))
            mlflow.log_param("created_at", datetime.now().isoformat())

            # Log feature names
            mlflow.set_tag("features", ",".join(df.columns))

            # Apply transformations if provided
            if transformers:
                transformed_df = transformers.fit_transform(df)
                mlflow.sklearn.log_model(transformers, "transformers")
            else:
                transformed_df = df

            # Log feature statistics
            stats = df.describe().to_dict()
            mlflow.log_dict(stats, "feature_statistics.json")

            # Save feature data
            feature_path = f"{feature_set_name}.parquet"
            df.to_parquet(feature_path)
            mlflow.log_artifact(feature_path)

            # Log data quality metrics
            mlflow.log_metric("missing_values", df.isnull().sum().sum())
            mlflow.log_metric("duplicate_rows", df.duplicated().sum())

            run_id = mlflow.active_run().info.run_id
            print(f"Feature set created with run_id: {run_id}")

            return run_id

    def load_feature_set(self, run_id):
        """Load a specific version of a feature set"""
        from mlflow.tracking import MlflowClient

        client = MlflowClient()
        artifact_path = client.download_artifacts(run_id, "")

        # Find parquet file
        import os
        for file in os.listdir(artifact_path):
            if file.endswith('.parquet'):
                df = pd.read_parquet(os.path.join(artifact_path, file))
                return df

        raise FileNotFoundError("No parquet file found in artifacts")

# Usage
store = MLflowFeatureStore()

# Create sample data
data = pd.DataFrame({
    'customer_id': range(1000),
    'age': np.random.randint(18, 80, 1000),
    'income': np.random.randint(20000, 150000, 1000),
    'tenure_months': np.random.randint(1, 120, 1000),
    'total_purchases': np.random.randint(0, 100, 1000)
})

# Create feature set
run_id = store.create_feature_set(
    df=data,
    feature_set_name="customer_features_v1"
)

# Load feature set
loaded_features = store.load_feature_set(run_id)
```

**Explanation**: This feature store implementation versions feature sets with full lineage tracking. It stores feature statistics, metadata, and data quality metrics alongside the features themselves.

---

### Example 14: Feature Engineering Pipeline Tracking

**Description**: Track complex feature engineering transformations.

**Use Case**: Reproducible feature engineering with lineage.

```python
import mlflow
import pandas as pd
from sklearn.preprocessing import StandardScaler, PolynomialFeatures
from sklearn.decomposition import PCA
from sklearn.pipeline import Pipeline

def track_feature_engineering(raw_data, pipeline_name="feature-pipeline"):
    """Track feature engineering with MLflow"""

    mlflow.set_experiment("feature-engineering")

    with mlflow.start_run(run_name=pipeline_name):
        # Log raw data stats
        mlflow.log_param("raw_features", len(raw_data.columns))
        mlflow.log_param("raw_samples", len(raw_data))

        # Create feature engineering pipeline
        pipeline = Pipeline([
            ('scaler', StandardScaler()),
            ('poly', PolynomialFeatures(degree=2, include_bias=False)),
            ('pca', PCA(n_components=0.95))
        ])

        # Fit and transform
        transformed_data = pipeline.fit_transform(raw_data)

        # Log pipeline
        mlflow.sklearn.log_model(pipeline, "feature_pipeline")

        # Log transformation stats
        mlflow.log_param("final_features", transformed_data.shape[1])
        mlflow.log_metric("dimensionality_reduction",
            (1 - transformed_data.shape[1] / (raw_data.shape[1] * (raw_data.shape[1] + 1) / 2)) * 100)

        # Log PCA explained variance
        mlflow.log_metric("explained_variance_ratio",
            pipeline.named_steps['pca'].explained_variance_ratio_.sum())

        # Create feature importance visualization
        import matplotlib.pyplot as plt

        plt.figure(figsize=(10, 6))
        plt.bar(range(len(pipeline.named_steps['pca'].explained_variance_ratio_)),
                pipeline.named_steps['pca'].explained_variance_ratio_)
        plt.xlabel('Principal Component')
        plt.ylabel('Explained Variance Ratio')
        plt.title('PCA Explained Variance')
        plt.savefig('pca_variance.png')
        mlflow.log_artifact('pca_variance.png')
        plt.close()

        return transformed_data, pipeline

# Usage
transformed_features, pipeline = track_feature_engineering(X_train)
```

**Explanation**: This example tracks the complete feature engineering pipeline including transformations, dimensionality reduction, and variance explained. The pipeline is saved for consistent transformation in production.

---

## CI/CD Pipeline Examples

### Example 15: Automated Model Training Pipeline

**Description**: End-to-end automated training with validation gates.

**Use Case**: CI/CD integration for automated model deployment.

```python
import mlflow
from sklearn.model_selection import cross_val_score
from sklearn.ensemble import RandomForestClassifier
import sys

def automated_training_pipeline(
    data_version,
    model_params,
    performance_threshold=0.85,
    register_model=True
):
    """
    Automated training pipeline with quality gates

    Returns:
        bool: True if model meets criteria and is registered
    """

    mlflow.set_experiment("automated-training-pipeline")

    with mlflow.start_run(run_name=f"pipeline-{data_version}") as run:
        # Log data version
        mlflow.log_param("data_version", data_version)
        mlflow.log_param("performance_threshold", performance_threshold)

        # Load data (mock for example)
        X_train, y_train, X_test, y_test = load_versioned_data(data_version)

        # Log data statistics
        mlflow.log_param("train_samples", len(X_train))
        mlflow.log_param("test_samples", len(X_test))
        mlflow.log_param("num_features", X_train.shape[1])

        # Train model
        model = RandomForestClassifier(**model_params, random_state=42)

        # Cross-validation
        cv_scores = cross_val_score(model, X_train, y_train, cv=5, scoring='accuracy')
        cv_mean = cv_scores.mean()
        cv_std = cv_scores.std()

        mlflow.log_params(model_params)
        mlflow.log_metric("cv_mean_score", cv_mean)
        mlflow.log_metric("cv_std_score", cv_std)

        # Quality Gate 1: Cross-validation score
        if cv_mean < performance_threshold:
            mlflow.set_tag("status", "rejected")
            mlflow.set_tag("rejection_reason", "cv_score_below_threshold")
            print(f"FAILED: CV score {cv_mean:.3f} below threshold {performance_threshold}")
            return False

        # Train final model
        model.fit(X_train, y_train)

        # Test set evaluation
        test_score = model.score(X_test, y_test)
        mlflow.log_metric("test_score", test_score)

        # Quality Gate 2: Test score
        if test_score < performance_threshold:
            mlflow.set_tag("status", "rejected")
            mlflow.set_tag("rejection_reason", "test_score_below_threshold")
            print(f"FAILED: Test score {test_score:.3f} below threshold")
            return False

        # Quality Gate 3: Overfitting check
        overfit_gap = cv_mean - test_score
        mlflow.log_metric("overfit_gap", overfit_gap)

        if overfit_gap > 0.05:  # 5% gap threshold
            mlflow.set_tag("status", "rejected")
            mlflow.set_tag("rejection_reason", "overfitting_detected")
            print(f"FAILED: Overfitting detected (gap: {overfit_gap:.3f})")
            return False

        # All gates passed - register model
        if register_model:
            from mlflow.models import infer_signature
            signature = infer_signature(X_train, model.predict(X_train))

            mlflow.sklearn.log_model(
                sk_model=model,
                name="model",
                signature=signature,
                registered_model_name="AutomatedModel"
            )

        mlflow.set_tag("status", "approved")
        mlflow.set_tag("ready_for_production", "true")

        print(f"SUCCESS: Model passed all quality gates")
        print(f"CV Score: {cv_mean:.3f}, Test Score: {test_score:.3f}")

        return True

# Usage in CI/CD (e.g., GitHub Actions)
if __name__ == "__main__":
    success = automated_training_pipeline(
        data_version="v2.1.0",
        model_params={
            'n_estimators': 100,
            'max_depth': 10,
            'min_samples_split': 5
        },
        performance_threshold=0.85
    )

    # Exit with error code if pipeline failed
    sys.exit(0 if success else 1)
```

**Explanation**: This automated pipeline implements multiple quality gates including cross-validation thresholds, test performance, and overfitting detection. It's designed to be integrated into CI/CD systems.

---

### Example 16: Model Promotion Workflow

**Description**: Automated model promotion from staging to production.

**Use Case**: Safe model deployment with automated validation.

```python
from mlflow import MlflowClient
import mlflow
from datetime import datetime

def automated_model_promotion(
    model_name,
    candidate_version,
    validation_data,
    promotion_criteria
):
    """
    Automated model promotion workflow with comprehensive validation

    Args:
        model_name: Name of registered model
        candidate_version: Version to potentially promote
        validation_data: (X_val, y_val) for validation
        promotion_criteria: Dict of metric thresholds
    """

    client = MlflowClient()
    mlflow.set_experiment("model-promotion")

    with mlflow.start_run(run_name=f"promote-{candidate_version}"):
        X_val, y_val = validation_data

        # Load candidate model
        candidate_uri = f"models:/{model_name}/{candidate_version}"
        candidate_model = mlflow.sklearn.load_model(candidate_uri)

        # Load current production model (if exists)
        try:
            production_model = mlflow.sklearn.load_model(
                f"models:/{model_name}@production"
            )
            has_production = True
        except:
            has_production = False
            production_model = None

        # Evaluate candidate
        from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score

        candidate_pred = candidate_model.predict(X_val)
        candidate_metrics = {
            'accuracy': accuracy_score(y_val, candidate_pred),
            'precision': precision_score(y_val, candidate_pred, average='weighted'),
            'recall': recall_score(y_val, candidate_pred, average='weighted'),
            'f1': f1_score(y_val, candidate_pred, average='weighted')
        }

        # Log candidate metrics
        for metric, value in candidate_metrics.items():
            mlflow.log_metric(f"candidate_{metric}", value)

        # Check promotion criteria
        passed_criteria = True
        for metric, threshold in promotion_criteria.items():
            if candidate_metrics[metric] < threshold:
                mlflow.set_tag(f"failed_{metric}", f"{candidate_metrics[metric]:.3f} < {threshold}")
                passed_criteria = False

        if not passed_criteria:
            mlflow.set_tag("promotion_status", "rejected_criteria")
            print("Candidate failed promotion criteria")
            return False

        # Compare with production (if exists)
        if has_production:
            production_pred = production_model.predict(X_val)
            production_metrics = {
                'accuracy': accuracy_score(y_val, production_pred),
                'precision': precision_score(y_val, production_pred, average='weighted'),
                'recall': recall_score(y_val, production_pred, average='weighted'),
                'f1': f1_score(y_val, production_pred, average='weighted')
            }

            # Log production metrics
            for metric, value in production_metrics.items():
                mlflow.log_metric(f"production_{metric}", value)

            # Require improvement
            if candidate_metrics['accuracy'] <= production_metrics['accuracy']:
                mlflow.set_tag("promotion_status", "rejected_no_improvement")
                print("Candidate not better than production")
                return False

        # All checks passed - promote to production
        client.set_registered_model_alias(
            name=model_name,
            alias="production",
            version=candidate_version
        )

        # Tag the promoted version
        client.set_model_version_tag(
            name=model_name,
            version=candidate_version,
            key="promoted_at",
            value=datetime.now().isoformat()
        )

        client.set_model_version_tag(
            name=model_name,
            version=candidate_version,
            key="promotion_validated",
            value="true"
        )

        mlflow.set_tag("promotion_status", "success")
        print(f"Model version {candidate_version} promoted to production")

        return True

# Usage
success = automated_model_promotion(
    model_name="CustomerChurnModel",
    candidate_version="5",
    validation_data=(X_val, y_val),
    promotion_criteria={
        'accuracy': 0.85,
        'precision': 0.80,
        'recall': 0.80,
        'f1': 0.82
    }
)
```

**Explanation**: This promotion workflow validates candidate models against both absolute criteria and current production performance before automatically promoting them.

---

## Advanced Workflows

### Example 17: Model Ensemble Tracking

**Description**: Track and manage ensemble models with MLflow.

**Use Case**: Combine multiple models for improved performance.

```python
import mlflow
import numpy as np
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import VotingClassifier

def track_ensemble_model(X_train, y_train, X_test, y_test):
    """Track individual models and ensemble"""

    mlflow.set_experiment("ensemble-modeling")

    # Parent run for ensemble
    with mlflow.start_run(run_name="ensemble-parent") as parent_run:
        # Individual models as nested runs
        models = {}

        # Random Forest
        with mlflow.start_run(run_name="random-forest", nested=True):
            rf = RandomForestClassifier(n_estimators=100, random_state=42)
            rf.fit(X_train, y_train)
            rf_score = rf.score(X_test, y_test)

            mlflow.log_param("model_type", "random_forest")
            mlflow.log_metric("accuracy", rf_score)
            mlflow.sklearn.log_model(rf, "model")

            models['rf'] = rf

        # Gradient Boosting
        with mlflow.start_run(run_name="gradient-boosting", nested=True):
            gb = GradientBoostingClassifier(n_estimators=100, random_state=42)
            gb.fit(X_train, y_train)
            gb_score = gb.score(X_test, y_test)

            mlflow.log_param("model_type", "gradient_boosting")
            mlflow.log_metric("accuracy", gb_score)
            mlflow.sklearn.log_model(gb, "model")

            models['gb'] = gb

        # Logistic Regression
        with mlflow.start_run(run_name="logistic-regression", nested=True):
            lr = LogisticRegression(max_iter=1000, random_state=42)
            lr.fit(X_train, y_train)
            lr_score = lr.score(X_test, y_test)

            mlflow.log_param("model_type", "logistic_regression")
            mlflow.log_metric("accuracy", lr_score)
            mlflow.sklearn.log_model(lr, "model")

            models['lr'] = lr

        # Create ensemble
        ensemble = VotingClassifier(
            estimators=[
                ('rf', models['rf']),
                ('gb', models['gb']),
                ('lr', models['lr'])
            ],
            voting='soft'
        )

        ensemble.fit(X_train, y_train)
        ensemble_score = ensemble.score(X_test, y_test)

        # Log ensemble results
        mlflow.log_param("ensemble_type", "voting")
        mlflow.log_param("num_models", len(models))
        mlflow.log_metric("ensemble_accuracy", ensemble_score)
        mlflow.log_metric("rf_accuracy", rf_score)
        mlflow.log_metric("gb_accuracy", gb_score)
        mlflow.log_metric("lr_accuracy", lr_score)

        # Log improvement
        best_individual = max(rf_score, gb_score, lr_score)
        improvement = (ensemble_score - best_individual) / best_individual * 100
        mlflow.log_metric("improvement_over_best", improvement)

        # Log ensemble model
        mlflow.sklearn.log_model(
            ensemble,
            "ensemble_model",
            registered_model_name="EnsembleClassifier"
        )

        print(f"Ensemble accuracy: {ensemble_score:.3f}")
        print(f"Improvement over best individual: {improvement:.2f}%")

# Usage
track_ensemble_model(X_train, y_train, X_test, y_test)
```

**Explanation**: This example tracks individual models and their ensemble, showing performance comparisons and improvements from combining models.

---

### Example 18: Cross-Framework Model Comparison

**Description**: Compare models across different ML frameworks.

**Use Case**: Framework-agnostic model evaluation.

```python
import mlflow
from sklearn.ensemble import RandomForestClassifier
from xgboost import XGBClassifier
from lightgbm import LGBMClassifier

def compare_frameworks(X_train, y_train, X_test, y_test):
    """Compare models from different frameworks"""

    mlflow.set_experiment("framework-comparison")

    results = {}

    # Scikit-learn Random Forest
    with mlflow.start_run(run_name="sklearn-rf"):
        mlflow.sklearn.autolog()

        model = RandomForestClassifier(n_estimators=100, random_state=42)
        model.fit(X_train, y_train)
        score = model.score(X_test, y_test)

        mlflow.log_param("framework", "sklearn")
        results['sklearn'] = score

    # XGBoost
    with mlflow.start_run(run_name="xgboost"):
        mlflow.xgboost.autolog()

        model = XGBClassifier(n_estimators=100, random_state=42)
        model.fit(X_train, y_train)
        score = model.score(X_test, y_test)

        mlflow.log_param("framework", "xgboost")
        results['xgboost'] = score

    # LightGBM
    with mlflow.start_run(run_name="lightgbm"):
        mlflow.lightgbm.autolog()

        model = LGBMClassifier(n_estimators=100, random_state=42)
        model.fit(X_train, y_train)
        score = model.score(X_test, y_test)

        mlflow.log_param("framework", "lightgbm")
        results['lightgbm'] = score

    # Summary run
    with mlflow.start_run(run_name="framework-comparison-summary"):
        for framework, score in results.items():
            mlflow.log_metric(f"{framework}_accuracy", score)

        best_framework = max(results, key=results.get)
        mlflow.log_param("best_framework", best_framework)
        mlflow.log_metric("best_accuracy", results[best_framework])

        print("\nFramework Comparison Results:")
        for framework, score in sorted(results.items(), key=lambda x: x[1], reverse=True):
            print(f"  {framework}: {score:.4f}")

    return results

# Usage
results = compare_frameworks(X_train, y_train, X_test, y_test)
```

**Explanation**: This example demonstrates comparing models across different ML frameworks while using MLflow's autologging to capture framework-specific details automatically.

---

### Example 19: Model Retraining Detection

**Description**: Detect when models need retraining based on performance drift.

**Use Case**: Automated trigger for model retraining pipelines.

```python
import mlflow
from mlflow.tracking import MlflowClient
from datetime import datetime, timedelta
import numpy as np

def check_retraining_needed(
    model_name,
    lookback_days=7,
    performance_threshold=0.85,
    drift_threshold=0.05
):
    """
    Check if model needs retraining based on performance drift

    Args:
        model_name: Name of the model to check
        lookback_days: Days of monitoring data to analyze
        performance_threshold: Minimum acceptable performance
        drift_threshold: Maximum acceptable drift from baseline
    """

    client = MlflowClient()

    # Get monitoring experiment
    experiment = client.get_experiment_by_name(f"{model_name}-monitoring")

    if not experiment:
        print("No monitoring data found")
        return False

    # Get recent monitoring runs
    cutoff_time = int((datetime.now() - timedelta(days=lookback_days)).timestamp() * 1000)
    runs = client.search_runs(
        experiment_ids=[experiment.experiment_id],
        filter_string=f"attributes.start_time > {cutoff_time}",
        order_by=["attributes.start_time ASC"]
    )

    if len(runs) < 3:
        print("Insufficient monitoring data")
        return False

    # Extract performance metrics
    accuracies = [run.data.metrics.get('accuracy', 0) for run in runs]

    # Calculate statistics
    current_performance = np.mean(accuracies[-3:])  # Last 3 runs
    baseline_performance = np.mean(accuracies[:3])  # First 3 runs
    performance_drift = baseline_performance - current_performance
    trend = np.polyfit(range(len(accuracies)), accuracies, 1)[0]  # Linear trend

    # Log retraining check
    mlflow.set_experiment(f"{model_name}-retraining-checks")

    with mlflow.start_run(run_name=f"check-{datetime.now().isoformat()}"):
        mlflow.log_param("lookback_days", lookback_days)
        mlflow.log_param("num_monitoring_runs", len(runs))

        mlflow.log_metric("current_performance", current_performance)
        mlflow.log_metric("baseline_performance", baseline_performance)
        mlflow.log_metric("performance_drift", performance_drift)
        mlflow.log_metric("performance_trend", trend)

        # Decision logic
        needs_retraining = False
        reasons = []

        # Check 1: Absolute performance
        if current_performance < performance_threshold:
            needs_retraining = True
            reasons.append(f"performance_below_threshold: {current_performance:.3f} < {performance_threshold}")

        # Check 2: Performance drift
        if performance_drift > drift_threshold:
            needs_retraining = True
            reasons.append(f"excessive_drift: {performance_drift:.3f} > {drift_threshold}")

        # Check 3: Negative trend
        if trend < -0.01:  # Declining performance
            needs_retraining = True
            reasons.append(f"declining_trend: {trend:.4f}")

        mlflow.set_tag("needs_retraining", str(needs_retraining))

        if needs_retraining:
            mlflow.set_tag("retraining_reasons", ", ".join(reasons))
            print(f"⚠️  RETRAINING NEEDED:")
            for reason in reasons:
                print(f"   - {reason}")
        else:
            print("✓ Model performance stable")

        return needs_retraining

# Usage
needs_retraining = check_retraining_needed(
    model_name="CustomerChurnModel",
    lookback_days=7,
    performance_threshold=0.85,
    drift_threshold=0.05
)

if needs_retraining:
    # Trigger retraining pipeline
    trigger_training_pipeline()
```

**Explanation**: This example analyzes monitoring data to automatically detect when models need retraining based on performance degradation, drift, and negative trends.

---

### Example 20: Shadow Mode Deployment

**Description**: Deploy new models in shadow mode for safe validation.

**Use Case**: Zero-risk production validation of new models.

```python
import mlflow
from datetime import datetime
import numpy as np

class ShadowModeDeployment:
    """Deploy model in shadow mode - predictions logged but not used"""

    def __init__(self, production_model_uri, shadow_model_uri, model_name):
        self.production_model = mlflow.pyfunc.load_model(production_model_uri)
        self.shadow_model = mlflow.pyfunc.load_model(shadow_model_uri)
        self.model_name = model_name

        mlflow.set_experiment(f"{model_name}-shadow-deployment")

    def predict(self, data, user_id=None):
        """Make predictions with both models, return production prediction"""

        # Production prediction (used)
        production_pred = self.production_model.predict(data)[0]

        # Shadow prediction (logged only)
        shadow_pred = self.shadow_model.predict(data)[0]

        # Log both predictions
        with mlflow.start_run(run_name=f"shadow-{datetime.now().isoformat()[:19]}"):
            mlflow.log_param("user_id", user_id)
            mlflow.log_metric("production_prediction", float(production_pred))
            mlflow.log_metric("shadow_prediction", float(shadow_pred))
            mlflow.log_metric("predictions_match", int(production_pred == shadow_pred))

        return production_pred  # Only production prediction is used

    def analyze_shadow_performance(self, lookback_hours=24):
        """Analyze shadow model performance vs production"""

        from mlflow.tracking import MlflowClient
        from datetime import timedelta

        client = MlflowClient()
        experiment = client.get_experiment_by_name(f"{self.model_name}-shadow-deployment")

        cutoff_time = int((datetime.now() - timedelta(hours=lookback_hours)).timestamp() * 1000)
        runs = client.search_runs(
            experiment_ids=[experiment.experiment_id],
            filter_string=f"attributes.start_time > {cutoff_time}"
        )

        # Extract predictions
        production_preds = []
        shadow_preds = []
        matches = []

        for run in runs:
            production_preds.append(run.data.metrics.get('production_prediction', 0))
            shadow_preds.append(run.data.metrics.get('shadow_prediction', 0))
            matches.append(run.data.metrics.get('predictions_match', 0))

        # Analyze
        agreement_rate = np.mean(matches)
        avg_diff = np.mean([abs(p - s) for p, s in zip(production_preds, shadow_preds)])

        with mlflow.start_run(run_name="shadow-analysis"):
            mlflow.log_param("lookback_hours", lookback_hours)
            mlflow.log_param("num_predictions", len(runs))
            mlflow.log_metric("agreement_rate", agreement_rate)
            mlflow.log_metric("avg_prediction_diff", avg_diff)

            # Decision
            if agreement_rate > 0.95 and avg_diff < 0.05:
                mlflow.set_tag("recommendation", "promote_shadow_to_production")
                print(f"✓ Shadow model ready for production")
                print(f"  Agreement: {agreement_rate:.1%}")
                print(f"  Avg diff: {avg_diff:.3f}")
            else:
                mlflow.set_tag("recommendation", "continue_shadow_testing")
                print(f"⚠️  Shadow model needs more validation")
                print(f"  Agreement: {agreement_rate:.1%}")
                print(f"  Avg diff: {avg_diff:.3f}")

# Usage
shadow_deployment = ShadowModeDeployment(
    production_model_uri="models:/CustomerChurnModel@production",
    shadow_model_uri="models:/CustomerChurnModel@challenger",
    model_name="CustomerChurnModel"
)

# Use in production
for customer in customers:
    prediction = shadow_deployment.predict(customer.features, customer.id)
    # Only production prediction is used

# Analyze after collecting data
shadow_deployment.analyze_shadow_performance(lookback_hours=24)
```

**Explanation**: Shadow mode deployment allows testing new models in production without risk. The shadow model's predictions are logged for analysis but not used, enabling safe validation before full deployment.

---

## Summary

This comprehensive examples document provides 20 production-ready examples covering:

1. **Experiment Tracking**: Basic tracking, autologging, hyperparameter tuning, multi-metric tracking
2. **Model Registry**: Complete registration, lifecycle management with validation
3. **Deployment**: REST API, batch inference with custom logic
4. **Monitoring**: Performance monitoring, drift detection, prediction logging
5. **A/B Testing**: Statistical A/B testing, multi-armed bandits
6. **Feature Engineering**: Feature stores, pipeline tracking
7. **CI/CD**: Automated training, model promotion workflows
8. **Advanced**: Ensemble models, cross-framework comparison, retraining detection, shadow deployments

Each example includes:
- Clear description and use case
- Complete, production-ready code
- Detailed explanation of concepts
- MLflow best practices from official documentation
