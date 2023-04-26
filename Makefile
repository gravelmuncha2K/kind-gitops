BLUE=\033[0;34m
NC=\033[0m

# Cert-Manager Environment
CERTMANAGER_NAMESPACE=cert-manager
CERTMANAGER_CHART_VERSION=1.10.2

# ArgoCD Environment
ARGOCD_APP_VERSION=v2.5.15
ARGOCD_CHART_VERSION=5.29.1
ARGOCD_NAMESPACE=argocd

all: cluster cert-manager argocd

cluster:
	@echo "${BLUE}Check if existing cluster exists${NC}"
	@if [ $$(kind get clusters | grep tekton | wc -l) = 0 ]; then \
		kind create cluster --config ./kind/kind.yaml --name tekton; \
	fi
	@kubectl cluster-info --context kind-tekton
	@kubectl config set-context kind-tekton

cert-manager:
	@echo "${BLUE}Deploying Cert-Manager...${NC}"
	@if [ $$(kubectl get namespaces | grep cert-manager | wc -l) = 0 ]; then \
		kubectl create namespace ${CERTMANAGER_NAMESPACE}; \
	fi
	@helm repo add cert-manager https://charts.jetstack.io
	@if [ $$(helm --namespace ${CERTMANAGER_NAMESPACE} ls | grep cert-manager | wc -l) = 0 ]; then \
		helm upgrade --install cert-manager cert-manager/cert-manager --version ${CERTMANAGER_CHART_VERSION} --namespace ${CERTMANAGER_NAMESPACE}; \
	fi
	@echo "${BLUE}Waiting for resources to be created (100s)${NC}"
	@sleep 10
	@kubectl wait --namespace ${CERTMANAGER_NAMESPACE} --for=condition=ready pod --selector=app.kubernetes.io/instance=cert-manager --timeout=90s
	@echo "${BLUE}Creating Cert-Manager resources...${NC}"
	@kubectl --namespace ${CERTMANAGER_NAMESPACE} create secret tls mkcert --key certificates/rootCA-key.pem --cert certificates/rootCA.pem
	@kubectl apply -f resources/cluster-issuer.yaml

argocd:
	@echo "${BLUE}Deploying ArgoCD...${NC}"
	@if [ $$(kubectl get namespaces | grep argocd | wc -l) = 0 ]; then \
		kubectl create namespace ${ARGOCD_NAMESPACE}; \
	fi
	@helm repo add argo https://argoproj.github.io/argo-helm
	@if [ $$(helm --namespace ${ARGOCD_NAMESPACE} ls | grep argocd | wc -l) = 0 ]; then \
		helm upgrade --install argocd argo/argo-cd --version ${ARGOCD_CHART_VERSION} --namespace ${ARGOCD_NAMESPACE} --set global.image.tag=${ARGOCD_APP_VERSION}; \
	fi
	@echo "${BLUE}Waiting for resources to be created (100s)${NC}"
	@sleep 10
	@kubectl wait --namespace ${ARGOCD_NAMESPACE} --for=condition=ready pod --selector=app.kubernetes.io/part-of=argocd --timeout=90s
	@kubectl apply -f ./argocd/projects/ --namespace ${ARGOCD_NAMESPACE}
	@kubectl apply -f ./argocd/bootstrap/ --namespace ${ARGOCD_NAMESPACE}

argocd-credentials:
	@echo "${BLUE}Print ArgoCD Admin credentials...${NC}"
	@kubectl --namespace ${ARGOCD_NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

argocd-port-forward:
	@echo "${BLUE}Make ArgoCD available via port-forward...${NC}"
	@xdg-open https://argocd.apps.127.0.0.1.nip.io

.PHONY: all cluster argocd