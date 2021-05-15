# Project Title

This code will spun up an eks cluster.
The code will install kafka and mongodb using helm.
The code then deploy web service and api service

### Prerequisites

You need to have these installed:
- aws cli ( with configured credentials)
- eksctl
- helm
- kubectl

## Deploy

To create the cluster run `./main.sh deploy <aws profile> <cluster name> <region> <github token to read packages>`

### After deploy ###

To get the external loadbalancer address run

`kubectl get svc web-server -o jsonpath='{.status.loadBalancer.ingress[-1].hostname}'`


### Destroy ###

To remove resources that were created run

`./main.sh deploy <aws profile> <cluster name> <region>`
