action=$1
name=$2
region=$3
github_token=$4

deploy(){
eksctl create cluster --name "${name}" --region "${region}"

aws eks update-kubeconfig --name "${name}"

# create secret
kubectl create secret docker-registry regcred --docker-server=docker.pkg.github.com --docker-username=lauferism --docker-password ${github_token}

helm repo add bitnami https://charts.bitnami.com/bitnami
helm install kafka bitnami/kafka

helm install mongodb bitnami/mongodb

MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace default mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)

git_top_level=$(git rev-parse --show-toplevel)


deploy_api_server(){
    sed "s/<MONGODB_ROOT_PASSWORD>/${MONGODB_ROOT_PASSWORD}/g" deployment.yaml

    kubectl apply -f .

}


deploy_web_Server(){
    cd ${git_top_level}/kafka-mongo/web_server

    kubectl apply -f .


}

deploy_api_server
deploy_web_Server

}


destroy(){
	helm uninstall mongodb kafka
	eksctl delete cluster --name "${name}" --region "${region}"

}


$action
