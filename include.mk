.PHONY: get-events
get-events:
	kubectl get events --sort-by=.metadata.creationTimestamp

.PHONY: ingress-nginx-demo
ingress-nginx-demo:
    echo $(CERT) | base64 --decode > certificate.crt
    echo $(PRIVKEY) | base64 --decode > private.key
    echo "..creating the tls secret"
    kubectl create secret tls certificate.test.ingress-nginx-controller.ga \
		--cert certificate.crt \
        --key private.key
	kubectl create deployment demo --image=kennethreitz/httpbin --port=80
	kubectl expose deployment demo
	
	kubectl create ingress demo --class=nginx --rule="www.demo.io/*=demo:80" # --tls:- hosts: - www.demo.io secretName: demo-tls
	# kubectl create ingress foo --class nginx --rule "test.ingress-nginx-controller.ga/*=demo:80,tls=certificate.test.ingress-nginx-controller.ga"
	
	kubectl wait --for=condition=Ready pods --timeout=300s -l "app=demo"
	sleep 1
	curl -i -D- http://localhost:8080 -H "Host: www.demo.io"
	kubectl delete ing demo
	kubectl delete pods,services,deployments -l app=demo

.PHONY: git-sync
git-sync:
	if [[ "$$(git config --get remote.origin.url)" == "git@github.com:atrakic/weather-forecast-api.git" ]]; then \
		git remote -v | grep -q upstream || git remote add upstream git@ssh.dev.azure.com:v3/aty0918/dev/dev; \
		git fetch upstream; \
		git checkout main; \
		git merge upstream/main --allow-unrelated-histories; \
		git push origin --tags; \
	fi
