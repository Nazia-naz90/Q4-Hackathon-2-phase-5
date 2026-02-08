#!/bin/bash

# Verification script for Todo Application deployment

set -e  # Exit on any error

echo "🔍 Verifying Todo Application deployment..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if the todo-app namespace exists
if ! kubectl get namespace todo-app &> /dev/null; then
    echo "❌ Namespace 'todo-app' does not exist"
    echo "💡 Run the deployment script first: ./deploy-with-helm.sh"
    exit 1
fi

echo "✅ Namespace 'todo-app' exists"

# Check deployments
echo "📊 Checking deployments..."

DEPLOYMENTS=("todo-backend" "todo-frontend" "todo-ai-agent")

for deployment in "${DEPLOYMENTS[@]}"; do
    if kubectl get deployment "$deployment" -n todo-app &> /dev/null; then
        READY_REPLICAS=$(kubectl get deployment "$deployment" -n todo-app -o jsonpath='{.status.readyReplicas}')
        DESIRED_REPLICAS=$(kubectl get deployment "$deployment" -n todo-app -o jsonpath='{.spec.replicas}')

        if [ "$READY_REPLICAS" -eq "$DESIRED_REPLICAS" ] && [ "$READY_REPLICAS" -gt 0 ]; then
            echo "✅ Deployment '$deployment' is ready ($READY_REPLICAS/$DESIRED_REPLICAS replicas)"
        else
            echo "❌ Deployment '$deployment' is not ready ($READY_REPLICAS/$DESIRED_REPLICAS replicas)"
            STATUS_FAILED=true
        fi
    else
        echo "❌ Deployment '$deployment' does not exist"
        STATUS_FAILED=true
    fi
done

# Check services
echo "🌐 Checking services..."

SERVICES=("todo-backend" "todo-frontend" "todo-ai-agent")

for service in "${SERVICES[@]}"; do
    if kubectl get service "$service" -n todo-app &> /dev/null; then
        echo "✅ Service '$service' exists"
    else
        echo "❌ Service '$service' does not exist"
        STATUS_FAILED=true
    fi
done

# Check secrets
if kubectl get secret todo-secrets -n todo-app &> /dev/null; then
    echo "✅ Secret 'todo-secrets' exists"
else
    echo "⚠️  Secret 'todo-secrets' does not exist (this may be intentional for security)"
fi

# Check pods
echo "📦 Checking pods..."

PODS=$(kubectl get pods -n todo-app -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo "")
if [ -z "$PODS" ]; then
    echo "❌ No pods found in 'todo-app' namespace"
    STATUS_FAILED=true
else
    for pod in $PODS; do
        POD_STATUS=$(kubectl get pod "$pod" -n todo-app -o jsonpath='{.status.phase}')
        if [ "$POD_STATUS" = "Running" ]; then
            echo "✅ Pod '$pod' is Running"
        elif [ "$POD_STATUS" = "Succeeded" ]; then
            echo "✅ Pod '$pod' has Succeeded"  # For job pods
        else
            echo "❌ Pod '$pod' is in $POD_STATUS state"
            STATUS_FAILED=true

            # Show pod description for debugging
            echo "   Pod details:"
            kubectl describe pod "$pod" -n todo-app | head -20
        fi
    done
fi

# Final result
if [ "$STATUS_FAILED" = true ]; then
    echo "❌ Some components are not ready. Check the output above for details."
    echo ""
    echo "💡 Troubleshooting tips:"
    echo "   - Check pod logs: kubectl logs -l app.kubernetes.io/name=todo-app -n todo-app"
    echo "   - Describe problematic pods: kubectl describe pod <pod-name> -n todo-app"
    echo "   - Verify Helm release: helm status todo-app -n todo-app"
    exit 1
else
    echo "🎉 All components are successfully deployed and running!"
    echo ""
    echo "📋 Deployment Summary:"
    echo "   Namespace: todo-app"
    echo "   Deployments: $(kubectl get deployments -n todo-app -o jsonpath='{range .items}{.metadata.name}{' '}')"
    echo "   Services: $(kubectl get services -n todo-app -o jsonpath='{range .items}{.metadata.name}{' '}')"
    echo ""

    # Show service access information
    echo "🔗 Service Access:"
    FRONTEND_SVC=$(kubectl get svc todo-frontend -n todo-app -o jsonpath='{.spec.type}' 2>/dev/null || echo "NotFound")
    if [ "$FRONTEND_SVC" = "LoadBalancer" ]; then
        if command -v minikube &> /dev/null && minikube status &> /dev/null; then
            MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "unknown")
            FRONTEND_PORT=$(kubectl get svc todo-frontend -n todo-app -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "unknown")
            echo "   Frontend: http://$MINIKUBE_IP:$FRONTEND_PORT"
        else
            echo "   Frontend: $(kubectl get svc todo-frontend -n todo-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}' 2>/dev/null || echo 'Check service configuration')"
        fi
    else
        echo "   Frontend: Port-forward required (kubectl port-forward svc/todo-frontend -n todo-app 3000:3000)"
    fi

    echo "   Backend: todo-backend:8000 (internal) or port-forward to access externally"
    echo "   AI Agent: todo-ai-agent:8001 (internal) or port-forward to access externally"

    echo ""
    echo "📝 Useful Commands:"
    echo "   - View all resources: kubectl get all -n todo-app"
    echo "   - View logs: kubectl logs -l app.kubernetes.io/name=todo-app -n todo-app"
    echo "   - Port forward frontend: kubectl port-forward svc/todo-frontend -n todo-app 3000:3000"
    echo "   - Port forward backend: kubectl port-forward svc/todo-backend -n todo-app 8000:8000"
    echo "   - Helm status: helm status todo-app -n todo-app"

    exit 0
fi