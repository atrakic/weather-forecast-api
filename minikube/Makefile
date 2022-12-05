APP := weather-forecast-api

.PHONY: all
all: minikube install-ingress-nginx build # install-prometheus
	echo ""
	echo "URL: 'http://localhost:8080'"

build: ## Build app on minikube env
  ./build.sh $(APP)

.PHONY: ready
ready: setup
	if [[ "$$(minikube status -f'{{.Kubelet}}'|xargs)" != "Running" ]];then echo "Minikube not running !"; exit 1; fi

.PHONY: setup
setup:
	if ! [ -x "$$(command -v kubectl)" ]; then \
		curl -LO "https://dl.k8s.io/release/$$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; \
		sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl; \
	fi
	if ! [ -x "$$(command -v helm)" ]; then \
		curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash; \
	fi
	if ! [ -x "$$(command -v minikube)" ]; then \
		curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64; \
	        sudo install minikube-linux-amd64 /usr/local/bin/minikube; \
		rm -rf minikube-linux-amd64; \
	fi
	#source <(kubectl completion zsh)
	alias k="kubectl"

.PHONY: minikube
minikube: setup
	echo ":: $@ ::"
	echo "You are about to create minikube cluster."
	echo "Are you sure? (Press Enter to continue or Ctrl+C to abort) "
	read _
	eval $$(minikube docker-env --unset) || true
	minikube config set WantUpdateNotification false
	MINIKUBE_IN_STYLE=0 minikube start \
		--driver=docker \
		--kubernetes-version=$$(curl -sL https://storage.googleapis.com/kubernetes-release/release/stable.txt) \
		--memory=8g \
		--cpus=2 \
		--bootstrapper=kubeadm \
		--extra-config=kubeadm.node-name=minikube \
		--extra-config=kubelet.hostname-override=minikube
	minikube addons disable metrics-server
	#minikube addons list
	kubectl config set-context minikube --namespace default
	kubectl cluster-info
	kubectl get nodes
	kubectl wait --for=condition=Ready pods --all --all-namespaces --timeout=300s
	kubectl get all -A

.PHONY: status
status: ready
	kubectl get all -A

.PHONY: minikube-status
minikube-status: ready
	minikube ssh docker images
	minikube service list

.PHONY: install-prometheus
install-prometheus:
	echo ":: $@ ::"
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
	helm repo update
	helm upgrade --install prometheus prometheus-community/prometheus \
		--set=service.type=NodePort \
		--create-namespace --namespace=monitoring
	kubectl wait --for=condition=Ready pods --all -n monitoring --timeout=300s
	kubectl wait deployment prometheus-server -n monitoring --for condition=Available=True --timeout=90s
	helm list -n monitoring
	#minikube service -n monitoring prometheus-server &
	#killall kubectl || kubectl -n monitoring port-forward svc/prometheus-server 9090:80 &

.PHONY: install-ingress-nginx
install-ingress-nginx:
	echo ":: $@ ::"
	# helm show values ingress-nginx --repo https://kubernetes.github.io/ingress-nginx
	helm upgrade --install ingress-nginx ingress-nginx \
		--repo https://kubernetes.github.io/ingress-nginx \
		--set controller.updateStrategy.rollingUpdate.maxUnavailable=25% \
		--set controller.updateStrategy.type=RollingUpdate \
		--set controller.metrics.enabled=true \
		--set=controller.service.type=NodePort \
		--namespace ingress-nginx \
		--create-namespace
	kubectl get pods --namespace=ingress-nginx
	kubectl wait --namespace ingress-nginx \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=120s

.PHONY: ingress-nginx-port-forward
ingress-nginx-port-forward: ready
	echo ":: $@ ::"
	killall kubectl || kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80 &
	curl -D- http://localhost:8080

api-open:
	xdg-open $$(minikube service weather-forecast-api --url)/WeatherForecast

.PHONY: get-events
get-events: ready
	kubectl get events --sort-by=.metadata.creationTimestamp

.PHONY: clean
clean: ## Clean up
	echo ":: $@ ::"
	echo "You are about to stop minikube cluster."
	echo "Are you sure? (Press Enter to continue or Ctrl+C to abort) "
	read _
	eval $$(minikube docker-env --unset)
	#MINIKUBE_IN_STYLE=0 minikube stop || true
	docker stop minikube || true
	docker system prune -f

-include include.mk
