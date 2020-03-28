# fluxctl-action

[![e2e](https://github.com/fluxcd/fluxctl-action/workflows/e2e/badge.svg)](https://github.com/fluxcd/fluxctl-action/actions)

A GitHub Action to run fluxctl [commands](https://docs.fluxcd.io/en/latest/references/fluxctl/).

## Usage

In order to use fluxctl in GitHub Actions you have to install kubectl on the GitHub Action runner and
setup the current context to a Kubernetes cluster where Flux is running.

```yaml
name: Synchronize cluster

on: push

jobs:
  fluxctl:
    runs-on: ubuntu-latest
    steps:
      - uses: azure/setup-kubectl@v1
      - uses: azure/k8s-set-context@v1
        with:
          method: kubeconfig
          kubeconfig: <your kubeconfig>
      - name: Setup fluxctl
        uses: fluxcd/fluxctl-action@master
      - name: Synchronize cluster
        env:
          FLUX_FORWARD_NAMESPACE: flux
        run: fluxctl sync
```

## Kubernetes Kind

You can use the fluxctl GitHub Action together with Kubernetes Kind to build an end-to-end testing pipeline 
for the git repository that defines your cluster desired state.

```yaml
name: e2e

on: push

jobs:
  fluxctl:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: Setup Kubernetes
        uses: engineerd/setup-kind@v0.3.0
      - name: Setup fluxctl
        uses: fluxcd/fluxctl-action@master
      - name: Install Flux
        run: |
          kubectl create ns flux
          fluxctl install \
          --git-path=test \
          --git-branch=${GITHUB_REF#refs/heads/} \
          --git-readonly=true \
          --registry-disable-scanning=true \
          --git-email=fluxcdbot@users.noreply.github.com \
          --git-url=https://github.com/fluxcd/fluxctl-action.git \
          --namespace=flux | kubectl apply -f -
      - name: Verify install
        run: kubectl -n flux rollout status deploy/flux --timeout=1m
      - name: Sync git with cluster
        env:
          FLUX_FORWARD_NAMESPACE: flux
        run: fluxctl sync
      - name: Verify sync
        run: kubectl get ns | grep test
```

Note that we set `--git-branch=${GITHUB_REF#refs/heads/}` so that Flux will sync the current branch. 

If the git repository is not public, then you have to configure Flux with a
[personal access token](https://docs.fluxcd.io/en/latest/guides/use-git-https/)
so that it can synchronize the repo over HTTPS.