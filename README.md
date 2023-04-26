# Kind GitOps

A cluster bootstrap using a GitOps approach

## Requirements

- `kind`
- `kubectl`
- `helm`
- `mkcert`
- `docker`

## Setting up the CA

You'll need to install `mkcert` to install the CA on System Trust Store that your browsers will be using to access your applications on Kubernetes via HTTPS.
### Setting up the CA in Windows Internet Browsers

Via `scoop` or `winget` on Windows and not Linux, the reason for this is that mkcert takes care of adding the CA to Windows.

As privileged admin, run the following command:

```POWERSHELL
$ winget install mkcert
```

Restart your shell (with user permissions, no admin need) to be able to use `mkcert` as winget has updated the applications path for this.

```POWERSHELL
$ mkcert --install
```

Using `mkcert --CAROOT` will print the path where you can find the certificates for the CA generated, these will be saved by default on `C:\Users\<user>\AppData\Local\mkcert`

Last but not least, copy these files into certificates directory, as we will use them later to configure cert-manager cluster issuer:

```BASH
cp /mnt/c/Users/<user>/AppData/Local/mkcert/rootCA* certificates/
```
### Setting up the CA in Linux Internet Browsers

Via `brew` or your preference system package manager `dnf` if based on RedHat / Fedora /Rocky or `apt` if based on Debian / Ubuntu.

**brew**

```BASH
$ brew install mkcert
```

**dnf**

```BASH
$ sudo dnf install mkcert -y
```

**apt**

```BASH
$ sudo apt install mkcert -y
```

Using `mkcert --CAROOT` will print the path where you can find the certificates for the CA generated, these will be saved by default on `/home/<user>/.local/share/mkcert`

Last but not least, copy these files into certificates directory, as we will use them later to configure cert-manager cluster issuer:

```BASH
cp /home/<user>/.local/share/mkcert/rootCA* certificates/
```

## Bootstrap the cluster

Once we've met the previous requirements and the CA (both key and certificate) have been copied to `certificates` directory, we can proceed to start the cluster and let ArgoCD take control of our applications, to do so, simply run and wait for the Magic to happen.

```BASH
$ make
```

## Applications currently deployed and available:

- [Argo CD](https://argocd.apps.127.0.0.1.nip.io)
- [Tekton Dashboard](https://tekton.apps.127.0.0.1.nip.io)

## TODO

- [ ] Documentation for macOS
- [ ] Automate mkcert setup for any OS used
- [ ] Migrate to minikube to remove dependency on Docker