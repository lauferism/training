docker build --tag web_server .
docker tag web_server docker.pkg.github.com/lauferism/training/web_server:latest
docker push docker.pkg.github.com/lauferism/training/web_server:latest
kubectl delete pod $(kubectl get pod | grep web-server | awk '{print $1}') &
