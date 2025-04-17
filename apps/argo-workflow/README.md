## Generate secret for IAM/Dex

Do this for the `argowf` namespace as well as for the `argocd` namespace.

```
echo -n xxx | kubectl -n argowf create secret generic argo-workflow-sso --dry-run=client --from-file=client-id=/dev/stdin -o json \
  | kubeseal > mysealedsecret.json
echo -n xxx | kubectl -n argowf create secret generic argo-workflow-sso --dry-run=client --from-file=client-secret=/dev/stdin -o json \
  | kubeseal --merge-into mysealedsecret.json
```