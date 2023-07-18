kubernetes-action
=============
Interacts with kubernetes clusters calling `kubectl` commands.

Fork of https://github.com/Consensys/kubernetes-action. Removes the deprecated Python 2.7. awscli v1 and thus removes EKS support.
## Usage

### Basic Example

```yml
name: CI

on:
  - push

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Trigger deploy
        uses: fno/kubernetes-action-no-aws@master
        env:
          KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA }}
        with:
          args: apply deployment.yaml
```


## Config

### Secrets

One or more **secrets** needs to be created to store cluster credentials. (see [here](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets) for help on creating secrets). 

#### Basic
- **KUBE_CONFIG_DATA**: A `base64` representation of `~/.kube/config` file.

##### Example
```bash
cat ~/.kube/config | base64 | pbcopy # pbcopy will copy the secret to the clipboard (Mac OSX only)
```

## Outputs

- **result**: Output of the `kubectl` command.

### Example
```yaml
      - name: Save container image
        id: image-save
        uses: fno/kubernetes-action-no-aws@master
        env:
          KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA }}
        with:
          args: get deploy foo -o jsonpath="{..image}"

      - name: Print image
        run: 
          echo ${{ steps.image-save.outputs.result }}
```

More info on how to use outputs [here](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/metadata-syntax-for-github-actions#outputs).
