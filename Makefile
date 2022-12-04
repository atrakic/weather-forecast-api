MAKEFLAGS += --silent

SHELL := /bin/bash

APP := weather-forecast-api

.DEFAULT_GOAL := help

-include Makefile.minikube

build: ## Build app on minikube env
	./build.sh $(APP)

deploy: weather-forecast-api-deploy-RollingUpdate ## Deploy with default strategy
	#curl -i -D- http://localhost:8080 -H "Host: $(APP).local"

deploy-RollingUpdate: ## Deploy with RollingUpdate strategy
	kubectl apply -f ./deploy/RollingUpdate/manifest.yaml
	kubectl wait --for=condition=Ready pods --timeout=300s -l "app=weather-forecast-api"

deploy-Recreate: ## Deploy with Recreate strategy
	kubectl apply -f ./deploy/Recreate/manifest.yaml
	kubectl wait --for=condition=Ready pods --timeout=300s -l "app=weather-forecast-api"

deploy-BlueGreen: ## Deploy with BlueGreen strategy
	kubectl apply -f ./deploy/BlueGreen/app-blue.yaml
	kubectl apply -f ./deploy/BlueGreen/app-green.yaml
	kubectl apply -f ./deploy/BlueGreen/service.yaml

deploy-BlueGreen-switch: deploy-BlueGreen ## Switch Blue Green envs
	./deploy/BlueGreen/switch.sh

weather-forecast-api-deploy-ingress:
	kubectl create ingress weather-forecast-api --class=nginx --rule="$(APP).local/*=$(APP):80" || true

deploy-Canary: ## Deploy with Canary strategy
	kubectl apply -f ./deploy/Canary
	kubectl wait --for=condition=Ready pods --timeout=300s -l "app=weather-forecast-api,track=canary"

weather-forecast-api-open:
	xdg-open $$(minikube service weather-forecast-api --url)/WeatherForecast

weather-forecast-api-status:
	kubectl get all -o wide
	#for pod in $$(kubectl get po --output=jsonpath={.items..metadata.name}); do echo $$pod && kubectl exec -it $$pod -- env; done

weather-forecast-api-curl-test:
	for i in recreate; do kubectl run -it --rm --image=curlimages/curl --restart=Never curl-test -- \
		curl -sSL http://$$(kubectl get service weather-forecast-api-$$i --output=jsonpath='{.spec.clusterIPs[0]}'); kubectl delete pod curl-test; done

weather-forecast-api-clean:
	kubectl delete all -l app=$(APP)

.PHONY: test
test: ## Generate traffic and test app
	[ -f ./tests/test.sh ] && ./tests/test.sh

help:
	cat $(MAKEFILE_LIST) | grep -e "^[a-zA-Z_\-]*: *.*## *" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
