action=$1
aws_profile=$2
name=$3
region=$4
github_token=$5
#
deploy(){
AWS_PROFILE=${aws_profile} eksctl create cluster --name "${name}" --region "${region}" || exit 1

AWS_PROFILE=${aws_profile} aws eks update-kubeconfig --name "${name}"

# create secret
kubectl create secret docker-registry regcred --docker-server=docker.pkg.github.com --docker-username=lauferism --docker-password ${github_token}

helm repo add bitnami https://charts.bitnami.com/bitnami
helm install mongodb bitnami/mongodb

helm install kafka bitnami/kafka


MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace default mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)

git_top_level=$(git rev-parse --show-toplevel)


deploy_api_server(){
    cd ${git_top_level}/kafka-mongo/api_server
    sed -i -e "s/<MONGODB_ROOT_PASSWORD>/${MONGODB_ROOT_PASSWORD}/g" deployment.yaml

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
        AWS_PROFILE=${aws_profile} aws eks update-kubeconfig --name "${name}"
	helm uninstall mongodb kafka
	AWS_PROFILE=${aws_profile} eksctl delete cluster --name "${name}" --region "${region}"

}


$action
