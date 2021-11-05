# bfritz homelab applications

<!-- badges -->
[![continuous integration status](https://github.com/bfritz/homelab-apps/actions/workflows/ci.yaml/badge.svg)](https://github.com/bfritz/homelab-apps/actions/workflows/ci.yaml)

Gitops repository for [bfritz's] home kubernetes lab.  Companion repo
to [bfritz/homelab-bootstrap] to install applications into the cluster
after bootstrapping it with [k0sctl] and [Alpine worker nodes].

Argo CD [manages the process] of deploying apps defined in this
repository using the [apps.yaml] `ApplicationSet`.

[alpine worker nodes]: https://github.com/bfritz/homelab-bootstrap/#k0s-worker
[apps.yaml]: apps.yaml
[bfritz/homelab-bootstrap]: https://github.com/bfritz/homelab-bootstrap
[bfritz's]: https://bfritz.com/
[k0sctl]: https://github.com/k0sproject/k0sctl#readme
[manages the process]: https://github.com/bfritz/homelab-bootstrap/blob/v0.0.3/k0s/Makefile#L85-L86
