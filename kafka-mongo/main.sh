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

git_top_level=$(git rev-parse --show-toplevel)

declare -A locations
locations=(
    [kafka_consumer]='api_server/kafka_consumer_container'
    [api_server_continaer]='api_server/server_container'
    [web_server]='web_server'
    )

for location in "${!locations[@]}"
do
    echo "deploying $location"
    cd "${git_top_level}/kafka-mongo/${locations[$location]}"
    docker build --tag ${location} .
    docker tag ${location} docker.pkg.github.com/lauferism/training/${location}:latest
    docker push docker.pkg.github.com/lauferism/training/${location}:latest

    kubectl apply -f .
done


