# Project Title

This code will spun up an eks cluster.
The code will install kafka and mongodb using helm.
The code then deploy web service and api service

## Getting Started

To create the cluster run `./main deploy <aws profile> <cluster name> <region> <github token to read packages>`
### Prerequisites

You need to have these installed:
- aws cli
- eksctl
- helm
- kubectl

### After deploy ###

To get the external loadbalancer address run

`kubectl get svc web-server -o jsonpath='{.status.loadBalancer.ingress[-1].hostname}'`
