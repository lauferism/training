# action=$1
# region=$2
# name=$3
# docker_token=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


# # create cluster
# eksctl create cluster --name ${name} --region ${region}
# # connect to cluster 
# aws eks update-kubeconfig --name ${name}

# # create secret
# kubectl create secret docker-registry regcred --docker-server=docker.pkg.github.com --docker-username=lauferism --docker-password ${docker_token}


# helm repo add bitnami https://charts.bitnami.com/bitnami
# # installing kafka
# helm install kafka bitnami/kafka

# # installing mongodb
# helm install mongodb bitnami/mongodb

MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace default mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)

git_top_level=$(git rev-parse --show-toplevel)

declare -A locations
locations=(
    [kafka_consumer]='api_server/kafka_consumer_container'
    [api_server_continaer]='api_server/server_container'
    [web_server]='web_server'
    )

deploy_api_server(){
    cd ${git_top_level}/kafka-mongo/api_server/kafka_consumer_container
    docker build --tag kafka_consumer .
    docker tag kafka_consumer docker.pkg.github.com/lauferism/training/kafka_consumer:latest
    docker push docker.pkg.github.com/lauferism/training/kafka_consumer:latest


    cd ${git_top_level}/kafka-mongo/api_server/server_container
    docker build --tag api_server_continaer .
    docker tag api_server_continaer docker.pkg.github.com/lauferism/training/api_server_continaer:latest
    docker push docker.pkg.github.com/lauferism/training/api_server_continaer:latest

    cd ${git_top_level}/kafka-mongo/api_server

    sed "s/<MONGODB_ROOT_PASSWORD>/${MONGODB_ROOT_PASSWORD}/g" deployment.yaml

    kubectl apply -f .

}

deploy_web_Server(){
    cd ${git_top_level}/kafka-mongo/web_server
    docker build --tag web_server .
    docker tag web_server docker.pkg.github.com/lauferism/training/web_server:latest
    docker push docker.pkg.github.com/lauferism/training/web_server:latest

    kubectl apply -f .


}

