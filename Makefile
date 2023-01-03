# Local dev environment with Docker and Kubernetes KIND
MAKEFLAGS += --silent
SHELL := /bin/bash

APP := weather-forecast-api

.DEFAULT_GOAL := help

.PHONY: all
all: up deploy test
	curl -i -D- http://localhost:80 -H "Host: $(APP).local"

kind:
	kind create cluster --config kind.yaml 2> /dev/null || true

.PHONY: cluster-up
up: ## Start kinD cluster with Nginx ingress
	$(MAKE) kind
	#kubectl wait --for=condition=Ready pods --all --all-namespaces --timeout=300s
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	kubectl wait --namespace ingress-nginx \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=90s

.PHONY: deploy-helm
deploy-helm:
	pushd charts/$(APP); $(MAKE) install; popd

.PHONY: deploy
deploy: deploy-RollingUpdate ## Deploy with default (RollingUpdate) strategy

.PHONY: deploy-RollingUpdate
deploy-RollingUpdate:
	kubectl apply -f ./deploy/RollingUpdate/manifest.yaml
	kubectl wait --for=condition=Ready pods --timeout=300s -l "app=weather-forecast-api-rollingupdate"
	kubectl delete ingress $(APP) || true
	kubectl create ingress $(APP) --class=nginx --rule="$(APP).local/*=$(APP)-rollingupdate:80"

.PHONY: deploy-Recreate
deploy-Recreate: ## Deploy with Recreate strategy
	kubectl apply -f ./deploy/Recreate/manifest.yaml
	kubectl wait --for=condition=Ready pods --timeout=300s -l "app=weather-forecast-api-recreate"
	kubectl delete ingress $(APP) || true
	kubectl create ingress $(APP) --class=nginx --rule="$(APP).local/*=$(APP)-recreate:80"

.PHONY: deploy-BlueGreen
deploy-BlueGreen: ## Deploy with BlueGreen strategy
	kubectl apply -f ./deploy/BlueGreen/app-blue.yaml
	kubectl wait --for=condition=Ready pods --timeout=300s -l "color=blue"
	kubectl apply -f ./deploy/BlueGreen/app-green.yaml
	kubectl wait --for=condition=Ready pods --timeout=300s -l "color=green"
	kubectl apply -f ./deploy/BlueGreen/service.yaml
	kubectl delete ingress $(APP) || true
	kubectl create ingress $(APP) --class=nginx --rule="$(APP).local/*=$(APP)-bluegreen:80"

.PHONY: BlueGreen-switch
BlueGreen-switch: deploy-BlueGreen ## Switch Blue Green envs
	./deploy/BlueGreen/switch.sh

.PHONY: deploy-Canary
deploy-Canary: ## Deploy with Canary strategy
	kubectl delete ingress $(APP) || true
	kubectl apply -f ./deploy/Canary
	kubectl wait --for=condition=Ready pods --timeout=300s -l "app=weather-forecast-api,track=canary"
	kubectl delete ingress $(APP) || true
	kubectl create ingress $(APP) --class=nginx --rule="$(APP).local/*=$(APP)-canary:80"

api-status:
	kubectl get all -o wide
	#for pod in $$(kubectl get po --output=jsonpath={.items..metadata.name}); do echo $$pod && kubectl exec -it $$pod -- env; done

api-curl-test:
	for i in recreate rollingupdate blue-green canary; do \
		kubectl run -it --rm --image=curlimages/curl --restart=Never curl-test -- \
		curl -sSL http://$$(kubectl get service weather-forecast-api-$$i --output=jsonpath='{.spec.clusterIPs[0]}'); \
		kubectl delete pod curl-test; \
	done

.PHONY: api-clean
api-clean: ## Remove api but keep kinD running
	kubectl delete all -l "app=$(APP)" || true
	kubectl delete all -l "app=$(APP)-recreate" || true
	kubectl delete all -l "app=$(APP)-rollingupdate" || true
	kubectl delete all -l "app=$(APP)-canary" || true
	kubectl delete ingress $(APP) || true

.PHONY: test
test: ## Generate traffic and test app
	[ -f ./tests/test.sh ] && ./tests/test.sh

.PHONY: clean
clean: ## Clean up
	echo ":: $@ ::"
	echo "You are about to stop kind cluster."
	echo "Are you sure? (Press Enter to continue or Ctrl+C to abort) "
	read _
	kind delete cluster

.PHONY: help
help:
	cat $(MAKEFILE_LIST) | grep -e "^[a-zA-Z_\-]*: *.*## *" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

-include include.mk
