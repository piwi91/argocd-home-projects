# Backstage

Backstage is deployed through Kustomize and has two environment: development and production.

## Keep secrets a secret

Secrets are kept secret using Bitnami Kubeseal. Never commit base64 encoded secrets to a GIT repository, always seal those!

```
# Fetch the kubeseal public certificate from the kubeseal controller.
# Note that the public certificate is only valid for 30 days and automatically rotated.
kubeseal --fetch-cert > public-cert.pem
# Seal a secret
kubeseal --format yaml --cert public-cert.pem < your-secret.yaml > sealed-secret.yaml
```

## Automation

To re-use the Kustomize automation a script is available in `client-tools/sealed-secrets` that runs Kustomize, seals all generated secrets, and copies the sealed secrets into a `sealed-secrets` directory within the kustomization.yaml location.

Note: Comment out files in the secrets generator (or comment out any non-sealed secrets) before running. Then don't forget to reverse this when the secrets are sealed.

Example:

```
'.\client-tools\sealed-secrets\kustomize-seal.ps1' -BaseDir "apps/backstage/overlays/development"
```
