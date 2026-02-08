@echo off
REM build-and-run.bat - Script to build and run the Next.js frontend container on Windows

echo Building Next.js frontend container...

REM Build the Docker image
docker build -t nextjs-frontend:latest .

if %ERRORLEVEL% EQU 0 (
    echo ✅ Image built successfully!

    echo Starting container...

    REM Remove existing container if it exists
    docker inspect nextjs-app >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo Stopping existing container...
        docker stop nextjs-app >nul 2>&1
        docker rm nextjs-app >nul 2>&1
    )

    REM Run the container
    docker run -d ^
        --name nextjs-app ^
        -p 3000:3000 ^
        --restart unless-stopped ^
        nextjs-frontend:latest

    if %ERRORLEVEL% EQU 0 (
        echo ✅ Container started successfully!
        echo Application is available at: http://localhost:3000
        echo Container name: nextjs-app
        echo.
        echo To view logs: docker logs -f nextjs-app
        echo To stop container: docker stop nextjs-app
    ) else (
        echo ❌ Failed to start container
        exit /b 1
    )
) else (
    echo ❌ Failed to build image
    exit /b 1
)