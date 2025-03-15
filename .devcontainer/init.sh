# Pull resources needed to start a test cluster with flux.
mkdir test-cluster
git clone https://github.com/stefanprodan/flux-local-dev.git test-cluster
cd test-cluster

# Install brew for dep
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> /home/codespace/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/codespace/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

make tools

nohup kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80 > grafana.log 2>&1 &
nohup kubectl port-forward -n flux-system svc/weave-gitops 3001:9001 > flux.log 2>&1 &
nohup kubectl port-forward -n apps svc/podinfo 3002:9898 > podinfo.log 2>&1 &

# To see port-forwarded services: 
# ps aux | grep kubectl
