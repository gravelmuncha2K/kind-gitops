# Kind GitOps

A cluster bootstrap using a GitOps approach

## Setting up the CA in Windows Internet Browsers

You'll need to install `mkcert` via `scoop` or `winget` on Windows and not Linux, the reason for this is that mkcert takes care of adding the CA to Windows System Trust Store that will be the browsers you'll be using to access your applications on Kubernetes via HTTPS.

As privileged admin, run the following command:

```POWERSHELL
$ winget install mkcert
```

Restart your shell (with user permissions, no admin need) to be able to use `mkcert` as winget has updated the applications path for this.

```POWERSHELL
$ mkcert --install
```

Last argument `-CAROOT` will print the path where you can find the certificates for the CA generated, these will be saved by default on `C:\Users\<user>\AppData\Local\mkcert`

Last but not least, copy these files into certificates directory, as we will use them later to configure cert-manager cluster issuer:

```BASH
cp /mnt/c/Users/<user>/AppData/Local/mkcert/rootCA* certificates/
```

## Cluster Initial Bootstrap

To start issuing certificates, you'll need to create a `ClusterIssuer` resource that will be used by the ingress through annotations.

We will use now the root CA generated with mkcert to do that:

```BASH
$ kubectl -n cert-manager create secret tls mkcert --key certificates/rootCA-key.pem --cert certificates/rootCA.pem
```

And right after we will create the `ClusterIssuer` resource that will be used by nginx ingress controller to issue the certificates.

```BASH
$ kubectl apply -f resources/cluster-issuer.yaml
```