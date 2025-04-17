## Create a new sealed secret
```
echo -n bar | kubectl -n namespace create secret generic mysecret --dry-run=client --from-file=foo=/dev/stdin -o json \
  | kubeseal > mysealedsecret.json
echo -n baz | kubectl -n namespace create secret generic mysecret --dry-run=client --from-file=bar=/dev/stdin -o json \
  | kubeseal --merge-into mysealedsecret.json
```

Source: https://github.com/bitnami-labs/sealed-secrets