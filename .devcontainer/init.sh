# Pull resources needed to start a test cluster with flux.
mkdir test-cluster
git clone https://github.com/stefanprodan/flux-local-dev.git test-cluster
cd test-cluster

# Install brew since it's needed by the 'make tools' setup command within the test-cluster repo.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"  </dev/null
echo >> /home/codespace/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/codespace/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# setup the test cluster
make tools
make up

# Add hosts so that make check is able to pass it's checks within the codespace.
sudo bash -c 'echo "127.0.0.1 podinfo.flux.local" >> /etc/hosts'
sudo bash -c 'echo "127.0.0.1 grafana.flux.local" >> /etc/hosts'
sudo bash -c 'echo "127.0.0.1 ui.flux.local" >> /etc/hosts'
make check 

# Forward ports to the test cluster for external app/svc access
nohup kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80 > grafana.log 2>&1 &
nohup kubectl port-forward -n flux-system svc/weave-gitops 3001:9001 > flux.log 2>&1 &
nohup kubectl port-forward -n apps svc/podinfo 3002:9898 > podinfo.log 2>&1 &
# Enable external access so anyone can access the apps
gh codespace ports visibility 3000:public -c $CODESPACE_NAME
gh codespace ports visibility 3001:public -c $CODESPACE_NAME
gh codespace ports visibility 3002:public -c $CODESPACE_NAME

# Access the Flux UI and Grafana using the username 'admin' and password 'flux'

# To see port-forwarded services: 
# ps aux | grep kubectl
