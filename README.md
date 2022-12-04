# SETUP K8s on VMs
- follow: https://nicwortel.nl/blog/2022/continuous-deployment-to-kubernetes-with-github-actions

- follow: https://www.udemy.com/course/certified-kubernetes-administrator-with-practice-tests/learn/lecture/20666298#overview

## Create VMS

- create vms (azure vms username: mj1020)
- ssh into both vms:
  - Master: ssh -i ./k8s-master_key.pem mj1020@20.229.158.1
  - Master: ssh -i ./k8s-worker1_key.pem mj1020@20.234.235.51

## Bridget Traffic ?

- check if bridget traffic is loaded: lsmod | grep br_netfilter

## Install Docker

- `https://docs.docker.com/engine/install/ubuntu/`

## Install kubeadm, kubelet, kubectl

192.168.56
kubeadm init 10.0.244.0/24
### RUN

- sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=0.0.0.0 --apiserver-cert-extra-sans=10.0.0.4,20.229.158.1 --cri-socket unix:///run/cri-dockerd.sock
- sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket unix:///run/cri-dockerd.sock
- sudo ipvsadm --clear
- sudo iptables -F
- mkdir -p $HOME/.kube
- sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
- sudo chown $(id -u):$(id -g) $HOME/.kube/config
- kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
- kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml
- sudo kubeadm join 10.0.0.4:6443 --token zmi2y4.34mf29h8thkgdbra \
        --discovery-token-ca-cert-hash sha256:b79904a6acaa5d45b2d3213747939308a632e94017c720d8af8f7ee9e04a9442 \
        --cri-socket unix:///run/cri-dockerd.sock

## metallb
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system


## Git pipeline
kubectl create secret docker-registry github-container-registry --namespace=dev --docker-server=ghcr.io --docker-username=michaeljoahnnesmeier --docker-password=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

kubectl create serviceaccount github-actions
kubectl create token github-actions

create clusterrolebinding:
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: continuous-deployment
rules:
  - apiGroups:
      - ''
      - apps
      - networking.k8s.io
    resources:
      - namespaces
      - deployments
      - replicasets
      - ingresses
      - services
      - secrets
    verbs:
      - create
      - delete
      - deletecollection
      - get
      - list
      - patch
      - update
      - watch



kubectl create clusterrolebinding continuous-deployment --clusterrole=continuous-deployment --serviceaccount=default:github-actions


kubectl get serviceAccounts github-actions -n dev -o 'jsonpath={.secrets[*].name}'

kubectl config set-context --current --namespace=dev

sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
scp -r -i ./.kube/k8s-master_key.pem mj1020@20.229.158.1:/home/mj1020/.kube ~/Desktop/repos/test-pipeline/kubernetes/.kube
kubectl --kubeconfig ./.kube/config apply -f ./manifests/





kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

kubeadm join 172.10.1.4:6443 --token 8wcq0y.7zg6kgamv5vmcyu5 \
        --discovery-token-ca-cert-hash sha256:de338b9f4b1e3913da18e7bfbe68a1cb400662b9a7c5bf0ac22b1ce841f7b2


az vm create --name kube-node-0 \
    --resource-group k8s-lab-rg3 \
    --location westeurope \
    --availability-set kubeadm-nodes-as \
    --image UbuntuLTS \
    --admin-user azureuser \
    --ssh-key-values ~/.ssh/id_rsa.pub \
    --size Standard_DS2_v2 \
    --data-disk-sizes-gb 10 \
    --public-ip-sku Standard \
    --public-ip-address-dns-name kube-node-lab-0