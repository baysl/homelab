# Secret management

This directory contains Kubernetes secrets encrypted using [SOPS](https://getsops.io/docs/) and [age](https://age-encryption.org/) automatically decrypted in-cluster by Flux.
Secrets here must always be committed encrypted. Flux decrypts them during reconciliation using the age private key stored in the sops-age Secret inside the cluster.

## Requirements
- `sops` installed
- `age` installed
- A valid `agekey` private key stored in the cluster (see below)
- A valid `creation_rules` section in a `.sops.yaml` file at repo root (so SOPS knows how to encrypt)

## How to use
1. Generate an `agekey` file if not already done:
    ```sh
    age-keygen -o agekey
    ```
    This file contains both the private and public keys. The public key is needed to encrypt new secrets, while the private key is needed by Flux to decrypt them.

2. Create a new secret in the cluster using the output of the `age-keygen -o agekey` command. This should only be done once and manually:
    ```sh
    cat age.agekey |
    kubectl create secret generic sops-age \
    --namespace=flux-system \
    --from-file=age.agekey=/dev/stdin
    ```
    This secret must not be committed to the repository.

3. To encrypt a new secret file, use the following command:
    ```sh
    sops --age=<AGE_PUB_KEY> \
    --encrypt --encrypted-regex '^(data|stringData)$' --in-place <SECRET_FILE>.yaml
    ```
    If a `.sops.age` file is used with creation rules, the encryption command can be simplified to:
    ```sh
    sops --encrypt --in-place <SECRET_FILE>.yaml
    ```
    This will replace the specified `<SECRET_FILE>.yaml` with its encrypted version. **Warning**: secret values must use `stringData` fields to be encrypted correctly.

4. To allow Flux to decrypt the secrets during reconciliation, ensure a Kustomization resource is created in the `flux-system` namespace that references the SOPS decryption secret:
    ```yaml
    decryption:
      provider: sops
      secretRef:
         name: sops-age
    ```
    Check [`clusters/homelab/flux-system/sets-kustomization.yaml`](https://github.com/baysl/homelab/blob/main/clusters/homelab/flux-system/secrets-kustomization.yaml) to see how this is implemented in this repository.


Now, when Flux reconciles the Kustomization that includes the secrets, it will use the provided SOPS decryption secret to decrypt them automatically.
