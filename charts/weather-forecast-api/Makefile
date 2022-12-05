all:
	helm template -f values-prod.yaml .

install:
	helm install --generate-name -f values-prod.yaml .

list:
	helm list -A
