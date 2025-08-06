#!/bin/bash


# Check if script is sourced
(return 0 2>/dev/null) || {
  echo "Please run this script with 'source $0' or '. $0' to keep environment variables."
  exit 1
}

# Print ASCII banner
print_banner() {
  cat <<'EOF'
                                                          *%###%###%
                                                     ,%.    ./&&&  ,#,
                                                  ,             &&&.
                 ,###%#            *####%    ##%###############*#&&@
                ########         .%######,,#################### &&&,
               %#########       #########(        #####(       &&&(
              ##### /#####    ##### .####%       /#####      %&&&.
            .#####   (##### #####,   #####       #####(    /&&&&
           /#####     %########/     #####*     ,#####   %&&&&
          ######       ######%       #####%     ####( /&&&&&
                         ..                       .&&&&&&.
                                     *&&&&#(#&&&&&&&&&
                                      #&&&&&&&&&&%
EOF
  echo -e "Myrenic's Terraform manager Script\n"
}

if [ -z "$PROXMOX_VE_USERNAME" ]; then
  username=${username:-root@pam}
  read -p "Enter Proxmox username (default: root@pam): " username
  echo
  export PROXMOX_VE_USERNAME="$username"
else
  echo "Using existing PROXMOX_VE_USERNAME environment variable."
fi

if [ -z "$PROXMOX_VE_PASSWORD" ]; then
  read -s -p "Enter Proxmox password: " password
  echo
  export PROXMOX_VE_PASSWORD="$password"
else
  echo "Using existing PROXMOX_VE_PASSWORD environment variable."
fi

echo "Select action:"
select action in apply destroy; do
  case "$action" in
    apply)
      terraform -chdir=../terraform/talos-k3s-cluster/ init
      terraform -chdir=../terraform/talos-k3s-cluster/ apply
      terraform output -raw kubeconfig > ~/.kube/config
      terraform output -raw talosconfig > ~/.talos/config
      export KUBECONFIG=~/.kube/config
      export TALOSCONFIG=~/.talos/config
      break
      ;;
    destroy)
      terraform -chdir=../terraform/talos-k3s-cluster/ destroy
      # Remove kubeconfig and talosconfig files
      rm -f ~/.kube/config
      rm -f ~/.talos/config

      # Unset environment variables
      unset KUBECONFIG
      unset TALOSCONFIG

      echo "Kubeconfig and Talosconfig cleared, environment variables unset."
      break
      ;;
    *)
      echo "Invalid option. Please select 1 or 2."
      ;;
  esac
done

#!/bin/bash

