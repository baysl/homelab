#!/usr/bin/env bash
set -euo pipefail

# Safe interactive script to wipe k3s on multiple nodes, reinstall k3s
# and bootstrap Flux to the repository (GitHub).
# Usage: run this from a machine that can SSH to all cluster nodes.

echo "WARNING: THIS WILL DESTROY k3s AND ALL WORKLOADS ON THE TARGET NODES"
echo "Back up anything you care about (PV data, Longhorn volumes, etc.)."
read -rp "Do you want to continue? Type 'yes' to proceed: " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Aborting. No changes made."
  exit 1
fi

read -rp "SSH user for nodes (eg. ubuntu): " SSH_USER
read -rp "Path to SSH private key (leave empty to use ssh-agent): " SSH_KEY
read -rp "Control node (IP or hostname): " CONTROL
read -rp "Worker nodes (comma-separated, leave empty if none): " WORKERS_CSV
read -rp "Do you want a HA k3s server cluster? (no=single server) [y/N]: " HA_ANSWER

IFS=',' read -r -a WORKERS <<< "${WORKERS_CSV:-}"

ssh_opts=( -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null )
if [[ -n "$SSH_KEY" ]]; then
  ssh_opts+=( -i "$SSH_KEY" )
fi

ssh_exec() {
  local node=$1; shift
  ssh "${ssh_opts[@]}" "$SSH_USER@$node" "$*"
}

scp_copy_from() {
  local src=$1; local dest=$2
  if [[ -n "$SSH_KEY" ]]; then
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$SSH_KEY" "$SSH_USER@$CONTROL:$src" "$dest"
  else
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$SSH_USER@$CONTROL:$src" "$dest"
  fi
}

echo "\nSTEP 1: Uninstalling k3s on all nodes"
ALL_NODES=("$CONTROL" "${WORKERS[@]}")
for n in "${ALL_NODES[@]}"; do
  if [[ -z "$n" ]]; then continue; fi
  echo "--> Uninstalling k3s on $n"
  # try server uninstall then agent uninstall
  ssh_exec "$n" 'sudo /usr/local/bin/k3s-uninstall.sh 2>/dev/null || sudo /usr/local/bin/k3s-agent-uninstall.sh 2>/dev/null || true'
  # remove common dirs
  ssh_exec "$n" 'sudo rm -rf /var/lib/rancher/k3s /etc/rancher /var/lib/kubelet /var/lib/containerd || true'
done

echo "\nSTEP 2: Installing k3s server on control node ($CONTROL)"
HA_ANSWER_LOWER=$(echo "${HA_ANSWER:-}" | tr '[:upper:]' '[:lower:]')
if [[ "$HA_ANSWER_LOWER" == "y" ]]; then
  echo "Installing k3s server (cluster-init) on control node"
  ssh_exec "$CONTROL" 'curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --cluster-init --write-kubeconfig-mode 644" sh -'
else
  ssh_exec "$CONTROL" 'curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --write-kubeconfig-mode 644" sh -'
fi

echo "Waiting 10s for server to initialize..."
sleep 10

echo "STEP 3: Retrieving node token from control node"
NODE_TOKEN=$(ssh_exec "$CONTROL" 'sudo cat /var/lib/rancher/k3s/server/node-token' 2>/dev/null || true)
if [[ -z "$NODE_TOKEN" ]]; then
  echo "Failed to read node token from $CONTROL; aborting"
  exit 1
fi

echo "STEP 4: Installing worker agents"
for w in "${WORKERS[@]}"; do
  if [[ -z "$w" ]]; then continue; fi
  echo "--> Installing agent on $w"
  ssh_exec "$w" "curl -sfL https://get.k3s.io | K3S_URL=\"https://192.168.80.10:6443\" K3S_TOKEN=\"K109f4e2b2c700f51048884a69033141f2f517a41ecab86ce37774f497c03611984::server:b9d0d2b373c7eb08bca0498767e32463\" sh -"
done

echo "\nSTEP 5: Copy kubeconfig from control node to local machine"
LOCAL_KUBECONFIG_PATH="./k3s-kubeconfig.yaml"
scp_copy_from "/etc/rancher/k3s/k3s.yaml" "$LOCAL_KUBECONFIG_PATH"
if [[ ! -f "$LOCAL_KUBECONFIG_PATH" ]]; then
  echo "Failed to copy kubeconfig. Exiting."
  exit 1
fi

echo "You have the kubeconfig at: $LOCAL_KUBECONFIG_PATH"
export KUBECONFIG="$PWD/$LOCAL_KUBECONFIG_PATH"

echo "Waiting for nodes to register (this may take 30-60s)"
for i in {1..30}; do
  kubectl get nodes --no-headers &>/dev/null && break || true
  sleep 2
done
kubectl get nodes || true

read -rp "Do you want me to run 'flux bootstrap' now (requires flux CLI and GITHUB_TOKEN)? [y/N]: " RUN_BOOT
if [[ "${RUN_BOOT,,}" == "y" ]]; then
  read -rp "Enter GitHub owner (default: baysl): " GH_OWNER
  GH_OWNER=${GH_OWNER:-baysl}
  read -rp "Enter repository (default: homelab): " GH_REPO
  GH_REPO=${GH_REPO:-homelab}
  read -rp "Enter branch (default: main): " GH_BRANCH
  GH_BRANCH=${GH_BRANCH:-main}
  read -rp "Enter path (default: clusters/homelab): " GH_PATH
  GH_PATH=${GH_PATH:-clusters/homelab}
  read -rsp "Enter GitHub Personal Access Token (PAT) (scopes: repo, admin:public_key if needed). Press Enter: " GITHUB_TOKEN
  echo
  export GITHUB_TOKEN
  echo "Running flux bootstrap github --owner=$GH_OWNER --repository=$GH_REPO --branch=$GH_BRANCH --path=$GH_PATH --personal"
  flux bootstrap github --owner="$GH_OWNER" --repository="$GH_REPO" --branch="$GH_BRANCH" --path="$GH_PATH" --personal
  echo "Bootstrap done. Check 'kubectl get pods -n flux-system'"
else
  echo "Skipping bootstrap. You can run it manually later. Remember to set KUBECONFIG to $PWD/$LOCAL_KUBECONFIG_PATH"
fi

echo "DONE"
