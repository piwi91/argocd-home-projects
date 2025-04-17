# SSO

Read the docs: https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/#2-configure-argo-cd-for-sso

## Generate secret for IAM/Dex (github-app)

Do this for the `argocd` namespace.

```
echo -n xxx | kubectl -n argocd create secret generic github-app --dry-run=client --from-file=applicationSecret=/dev/stdin -o json \
  | kubeseal > mysealedsecret.json
```
