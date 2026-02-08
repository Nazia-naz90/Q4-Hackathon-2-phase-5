@echo off
REM Verification script for Todo Application deployment on Windows

echo 🔍 Verifying Todo Application deployment...

REM Check if kubectl is available
kubectl version >nul 2>&1
if errorlevel 1 (
    echo ❌ kubectl is not installed or not in PATH
    exit /b 1
)

REM Check if the todo-app namespace exists
kubectl get namespace todo-app >nul 2>&1
if errorlevel 1 (
    echo ❌ Namespace 'todo-app' does not exist
    echo 💡 Run the deployment script first: deploy-with-helm.bat
    exit /b 1
)

echo ✅ Namespace 'todo-app' exists

REM Check deployments
echo 📊 Checking deployments...

set DEPLOYMENTS=todo-backend todo-frontend todo-ai-agent

for %%d in (%DEPLOYMENTS%) do (
    kubectl get deployment "%%d" -n todo-app >nul 2>&1
    if not errorlevel 1 (
        for /f %%i in ('kubectl get deployment "%%d" -n todo-app -o jsonpath=^"{.status.readyReplicas}^"') do set READY_REPLICAS=%%i
        for /f %%i in ('kubectl get deployment "%%d" -n todo-app -o jsonpath=^"{.spec.replicas}^"') do set DESIRED_REPLICAS=%%i

        if %READY_REPLICAS% equ %DESIRED_REPLICAS% (
            if %READY_REPLICAS% gtr 0 (
                echo ✅ Deployment '%%d' is ready (%READY_REPLICAS%/%DESIRED_REPLICAS% replicas)
            ) else (
                echo ❌ Deployment '%%d' has 0 ready replicas (%READY_REPLICAS%/%DESIRED_REPLICAS% replicas)
                set STATUS_FAILED=true
            )
        ) else (
            echo ❌ Deployment '%%d' is not ready (%READY_REPLICAS%/%DESIRED_REPLICAS% replicas)
            set STATUS_FAILED=true
        )
    ) else (
        echo ❌ Deployment '%%d' does not exist
        set STATUS_FAILED=true
    )
)

REM Check services
echo 🌐 Checking services...

set SERVICES=todo-backend todo-frontend todo-ai-agent

for %%s in (%SERVICES%) do (
    kubectl get service "%%s" -n todo-app >nul 2>&1
    if not errorlevel 1 (
        echo ✅ Service '%%s' exists
    ) else (
        echo ❌ Service '%%s' does not exist
        set STATUS_FAILED=true
    )
)

REM Check secrets
kubectl get secret todo-secrets -n todo-app >nul 2>&1
if not errorlevel 1 (
    echo ✅ Secret 'todo-secrets' exists
) else (
    echo ⚠️  Secret 'todo-secrets' does not exist ^(this may be intentional for security^)
)

REM Check pods
echo 📦 Checking pods...

for /f %%i in ('kubectl get pods -n todo-app -o jsonpath=^{.items..metadata.name^} 2^>nul ^|^| echo ""') do set PODS=%%i
if "%PODS%"=="" (
    echo ❌ No pods found in 'todo-app' namespace
    set STATUS_FAILED=true
) else (
    for %%p in (%PODS%) do (
        for /f %%s in ('kubectl get pod %%p -n todo-app -o jsonpath=^{.status.phase^} 2^>nul') do set POD_STATUS=%%s
        if "%POD_STATUS%"=="Running" (
            echo ✅ Pod '%%p' is Running
        ) else if "%POD_STATUS%"=="Succeeded" (
            echo ✅ Pod '%%p' has Succeeded
        ) else (
            echo ❌ Pod '%%p' is in %POD_STATUS% state
            set STATUS_FAILED=true

            REM Show pod description for debugging
            echo    Pod details:
            kubectl describe pod %%p -n todo-app | head -20
        )
    )
)

REM Final result
if "%STATUS_FAILED%"=="true" (
    echo ❌ Some components are not ready. Check the output above for details.
    echo.
    echo 💡 Troubleshooting tips:
    echo    - Check pod logs: kubectl logs -l app.kubernetes.io/name=todo-app -n todo-app
    echo    - Describe problematic pods: kubectl describe pod ^<pod-name^> -n todo-app
    echo    - Verify Helm release: helm status todo-app -n todo-app
    exit /b 1
) else (
    echo 🎉 All components are successfully deployed and running!
    echo.
    echo 📋 Deployment Summary:
    echo    Namespace: todo-app
    REM Note: Getting deployment and service names in Windows batch is complex, so we'll skip this for brevity

    echo.
    echo 📝 Useful Commands:
    echo    - View all resources: kubectl get all -n todo-app
    echo    - View logs: kubectl logs -l app.kubernetes.io/name=todo-app -n todo-app
    echo    - Port forward frontend: kubectl port-forward svc/todo-frontend -n todo-app 3000:3000
    echo    - Port forward backend: kubectl port-forward svc/todo-backend -n todo-app 8000:8000
    echo    - Helm status: helm status todo-app -n todo-app

    exit /b 0
)