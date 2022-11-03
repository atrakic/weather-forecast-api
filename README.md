## Introduction 
[![ci](https://github.com/atrakic/weather-forecast-api/actions/workflows/ci.yaml/badge.svg)](https://github.com/atrakic/weather-forecast-api/actions/workflows/ci.yaml)
[![minikube](https://github.com/atrakic/weather-forecast-api/actions/workflows/minikube.yaml/badge.svg)](https://github.com/atrakic/weather-forecast-api/actions/workflows/minikube.yaml)
[![release](https://github.com/atrakic/weather-forecast-api/actions/workflows/release.yaml/badge.svg)](https://github.com/atrakic/weather-forecast-api/actions/workflows/release.yaml)

- [.NET SDK 5.0](https://dotnet.microsoft.com/download/dotnet/5..0) - API backend .NET API demo with [Prometheus metrics](https://github.com/prometheus-net/prometheus-net).
Includes github actions pipelines to build, deploy on Azure.

## Requirements
Linux with sudo and [docker](https://docs.docker.com/engine/install/).

## Quickstart
1. Fork this repo
2. Install developer environment with additional tools:

```
## Bootstrap
make 

## Build image with demo .NET app
make build

## Deploy
make deploy

## Test
make test

# Clean up
make clean
```

## Deployment strategies examples covered in demo
- Recreate
- RollingUpdate
- BlueGreen

## Github Actions
- .github/workflows/ci.yaml - build, deploy and test local image with [docker-compose](https://docs.docker.com/compose/)
- .github/workflows/minikube.yaml - build and and test local image with [minikube](https://minikube.sigs.k8s.io/docs/)
- .github/workflows/release.yaml - build and promote public image and optionaly deploy with [Azure App Services](https://learn.microsoft.com/en-us/azure/app-service/)

## Contributing

1. Fork the repository
2. Implement and test your workflow
3. Describe it shortly in the README
4. Open a pull request
