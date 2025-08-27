## Principles

* The project directory has a `.sealed-secrets` directory that stores the kubeseal public certificate named `public-cert.pem`
* The public certificate needs to be fetched periodically because validity expires within 30 days

## Download kubeseal public certificate

```
kubeseal --fetch-cert > .sealed-secrets/public-cert.pem
```

## Create a new sealed secret manually

```
echo -n bar | kubectl -n namespace create secret generic mysecret --dry-run=client --from-file=foo=/dev/stdin -o json \
  | kubeseal > mysealedsecret.json
echo -n baz | kubectl -n namespace create secret generic mysecret --dry-run=client --from-file=bar=/dev/stdin -o json \
  | kubeseal --merge-into mysealedsecret.json
```

Source: https://github.com/bitnami-labs/sealed-secrets