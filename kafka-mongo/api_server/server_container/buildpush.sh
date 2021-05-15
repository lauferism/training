docker build --tag api_server_container .
docker tag api_server_container docker.pkg.github.com/lauferism/training/api_server_container:latest
docker push docker.pkg.github.com/lauferism/training/api_server_container:latest
kubectl delete pod $(kubectl get pod | grep api-server | awk '{print $1}')
kubectl get pod
