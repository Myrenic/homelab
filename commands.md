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