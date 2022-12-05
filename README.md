## weather-forecast-api

[![ci](https://github.com/atrakic/weather-forecast-api/actions/workflows/ci.yaml/badge.svg)](https://github.com/atrakic/weather-forecast-api/actions/workflows/ci.yaml)
[![minikube](https://github.com/atrakic/weather-forecast-api/actions/workflows/minikube.yaml/badge.svg)](https://github.com/atrakic/weather-forecast-api/actions/workflows/minikube.yaml)
[![release](https://github.com/atrakic/weather-forecast-api/actions/workflows/release.yaml/badge.svg)](https://github.com/atrakic/weather-forecast-api/actions/workflows/release.yaml)

[.NET SDK 5.0](https://dotnet.microsoft.com/download/dotnet/5..0) .NET API demo with [Prometheus metrics](https://github.com/prometheus-net/prometheus-net).

## K8s deployment strategies covered
- Recreate
- RollingUpdate
- BlueGreen
- Canary

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
- .github/workflows/ci.yaml - build, deploy and test local image with [docker-compose](https://docs.docker.com/compose/)
- .github/workflows/minikube.yaml - build and and test local image with [minikube](https://minikube.sigs.k8s.io/docs/)
- .github/workflows/release.yaml - build and promote public image and optionaly deploy with [Azure App Services](https://learn.microsoft.com/en-us/azure/app-service/)

## License
The scripts and documentation in this project are released under the [Apache License](LICENSE)
