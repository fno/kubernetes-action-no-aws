kubernetes-action-no-aws
========================
GitHub Action that runs a `kubectl` command against a Kubernetes cluster.

Fork of [Consensys/kubernetes-action](https://github.com/Consensys/kubernetes-action), with the AWS CLI (and therefore EKS-specific authentication) removed. Works with any cluster reachable through a plain kubeconfig.

- Ships the official `kubectl` release from `dl.k8s.io` (currently **v1.32.13**), checksum-verified at build time, on a digest-pinned Alpine base image.
- kubectl supports clusters within one minor version of itself, so v1.32 is supported against Kubernetes **1.31 – 1.33**.
- The action exits with `kubectl`'s exit code.

## Usage

```yml
name: Deploy

on:
  push:
    branches: [master]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Apply manifests
        uses: fno/kubernetes-action-no-aws@master
        env:
          KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA }}
        with:
          args: apply -f ./k8s -n my-namespace
```

More `args` examples:

```yml
args: rollout restart deploy/my-app -n my-namespace
args: rollout status deploy/my-app -n my-namespace --timeout=5m
args: set image deploy/my-app my-app=registry.example.com/my-app:${{ github.sha }} -n my-namespace
```

### How `args` is parsed

`args` is a single string that is split on whitespace into kubectl arguments. It is **not** parsed like a shell command line:

- Quotes are not interpreted. They are passed to kubectl literally, so `-o jsonpath="{..image}"` prints the image *including* the surrounding `"`. Write `-o jsonpath={..image}` instead.
- An argument cannot contain spaces.
- Glob patterns such as `-f k8s/*.yaml` are expanded against the workspace.

## Inputs

| Name   | Required | Description |
|--------|----------|-------------|
| `args` | yes      | kubectl arguments as one string (see above). |

## Environment

| Name               | Required | Description |
|--------------------|----------|-------------|
| `KUBE_CONFIG_DATA` | yes      | Base64-encoded kubeconfig. |

Store the kubeconfig as an [encrypted secret](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions):

```bash
base64 < ~/.kube/config | tr -d '\n'
```

Inside the container the kubeconfig is decoded to a private temporary file (mode `0600`) that is removed when the step ends, and it is never printed. The action fails early with an error if `KUBE_CONFIG_DATA` is missing or not valid base64.

Use a dedicated service account with the minimum RBAC permissions the workflow needs.

## Outputs

| Name     | Description |
|----------|-------------|
| `result` | Standard output of the kubectl command (may be multiline). Stderr only appears in the log. |

Pass the output to later steps through `env` rather than inlining `${{ }}` into a script, which could allow shell injection:

```yaml
      - name: Get current image
        id: image
        uses: fno/kubernetes-action-no-aws@master
        env:
          KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA }}
        with:
          args: get deploy/my-app -n my-namespace -o jsonpath={..image}

      - name: Print image
        env:
          IMAGE: ${{ steps.image.outputs.result }}
        run: echo "$IMAGE"
```

## Building locally

```bash
docker build -t kubernetes-action .
```

A different kubectl version can be selected with `--build-arg KUBECTL_VERSION=v1.32.x`.

## Credits

Based on [Consensys/kubernetes-action](https://github.com/Consensys/kubernetes-action).
