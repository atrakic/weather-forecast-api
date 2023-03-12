## weather-forecast-api

[![ci](https://github.com/atrakic/weather-forecast-api/actions/workflows/ci.yaml/badge.svg)](https://github.com/atrakic/weather-forecast-api/actions/workflows/ci.yaml)
[![minikube](https://github.com/atrakic/weather-forecast-api/actions/workflows/minikube.yaml/badge.svg)](https://github.com/atrakic/weather-forecast-api/actions/workflows/minikube.yaml)
[![k6-load-test](https://github.com/atrakic/weather-forecast-api/actions/workflows/k6-load-test.yml/badge.svg)](https://github.com/atrakic/weather-forecast-api/actions/workflows/k6-load-test.yml)
[![license](https://img.shields.io/github/license/atrakic/weather-forecast-api.svg)](https://github.com/atrakic/weather-forecast-api/blob/main/LICENSE)
[![release](https://img.shields.io/github/release/atrakic/weather-forecast-api/all.svg)](https://github.com/atrakic/weather-forecast-api/releases)

[.NET SDK 5.0](https://dotnet.microsoft.com/download/dotnet/5..0) .NET API demo with [Prometheus metrics](https://github.com/prometheus-net/prometheus-net).

## K8s deployment strategies covered
- [Recreate](deploy/Recreate)
- [RollingUpdate](deploy/RollingUpdate)
- [BlueGreen](deploy/BlueGreen)
- [Canary](deploy/Canary)

## Local dev environment with Docker and Kubernetes KIND:

```
make up
make deploy
make test
```

## Clean

```
make clean
```

## Github Actions

| GH Action | description |
|-----------------------|---------------------------------------------|
| [ci](.github/workflows/ci.yaml) | build, deploy and test local image with [docker-compose](https://docs.docker.com/compose/)|
| [minikube](.github/workflows/minikube.yaml) | build and test local image with [minikube](https://minikube.sigs.k8s.io/docs/)|
| [release](.github/workflows/release.yaml) | build and promote public image and optionaly deploy with [Azure App Services](https://learn.microsoft.com/en-us/azure/app-service/)|
