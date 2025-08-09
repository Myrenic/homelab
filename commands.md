flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=homelab \
  --branch=main \
  --path=./clusters/home/ \
  --personal

git clone https://github.com/$GITHUB_USER/homelab
cd homelab

flux create source git homelab \
  --url=https://github.com/$GITHUB_USER/homelab.git \
  --branch=main \
  --interval=1m

git add -A && git commit -m "Add podinfo GitRepository"
git push

flux create kustomization podinfo \
  --target-namespace=default \
  --source=podinfo \
  --path="./kustomize" \
  --prune=true \
  --wait=true \
  --interval=30m \
  --retry-interval=2m \
  --health-check-timeout=3m \
  --export > ./clusters/home/podinfo-kustomization.yaml

git add -A && git commit -m "Add podinfo Kustomization"
git push

flux get kustomizations --watch


# remove
flux uninstall --namespace flux-system
kubectl delete namespace flux-system


set -euo pipefail
wget https://github.com/getsops/sops/releases/download/v3.8.1/sops_3.8.1_amd64.deb          
echo ' 535bce529e2df7368ffba3fed2b427b9f964318fa28959d913924a70ba01c086  sops_3.8.1_amd64.deb' > sops_3.8.1_amd64.deb.sig
sha256sum -c sops_3.8.1_amd64.deb.sig
dpkg -i sops_3.8.1_amd64.deb 


kubectl -n flux-system create secret generic sops-age \
  --from-file=age.agekey=./keys.txt