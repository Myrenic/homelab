# Save the kubeconfig
terraform output -raw kubeconfig > ~/.kube/config

# Save the talosconfig (optional, if you also use Talos)
terraform output -raw talosconfig > ~/.talos/config

# Set environment variables (optional but useful)
export KUBECONFIG=~/.kube/config
export TALOSCONFIG=~/.talos/config
