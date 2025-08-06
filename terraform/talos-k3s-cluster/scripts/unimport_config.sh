#!/bin/bash

# Remove kubeconfig and talosconfig files
rm -f ~/.kube/config
rm -f ~/.talos/config

# Unset environment variables
unset KUBECONFIG
unset TALOSCONFIG

echo "Kubeconfig and Talosconfig cleared, environment variables unset."
