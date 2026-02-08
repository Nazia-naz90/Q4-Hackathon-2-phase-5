@echo off
REM Deployment script for Todo Application using Helm on Windows

echo 🚀 Starting deployment of Todo Application...

REM Check if Helm is installed
helm version >nul 2>&1
if errorlevel 1 (
    echo ❌ Helm is not installed. Please install Helm first.
    exit /b 1
)

REM Check if kubectl is installed
kubectl version >nul 2>&1
if errorlevel 1 (
    echo ❌ kubectl is not installed. Please install kubectl first.
    exit /b 1
)

REM Check if we're connected to a Kubernetes cluster
kubectl cluster-info >nul 2>&1
if errorlevel 1 (
    echo ❌ Not connected to a Kubernetes cluster. Please start Minikube or connect to a cluster.
    exit /b 1
)

echo ✅ Prerequisites check passed

echo 📊 Installing/upgrading Helm release...

REM Install or upgrade the Helm release
helm upgrade --install todo-app ./helm/todo-app --namespace todo-app --create-namespace --timeout=10m

if errorlevel 1 (
    echo ❌ Helm installation failed
    exit /b 1
)

echo ✅ Helm release installed/updated successfully!

REM Wait for all deployments to be ready
echo ⏳ Waiting for deployments to be ready...
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=todo-app --timeout=300s -n todo-app

if errorlevel 1 (
    echo ⚠️  Timeout waiting for pods to be ready, but continuing...
) else (
    echo ✅ All pods are ready!
)

REM Show the services
echo 🌐 Services:
kubectl get svc -n todo-app

REM Show the deployments
echo 📦 Deployments:
kubectl get deployments -n todo-app

REM If using Minikube, provide the URL to access the frontend
where minikube >nul 2>&1
if not errorlevel 1 (
    minikube status >nul 2>&1
    if not errorlevel 1 (
        echo 💡 To access the frontend in Minikube:
        echo    minikube service todo-frontend -n todo-app --url
    )
)

echo 🎉 Deployment completed successfully!