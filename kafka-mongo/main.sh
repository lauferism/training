##########

# setting up variables from the user

action=$1
aws_profile=$2
name=$3
region=$4
github_token=$5

##########


deploy(){
	# creating simple eks cluster, behind the scence it creates vpc, subnets. internet gw and nat gw
	echo -e "\n########## creating eks cluster named ${name} in ${region} region in ${aws_profile} account ##########\n"
	AWS_PROFILE=${aws_profile} eksctl create cluster --name "${name}" --region "${region}" --zones "${region}a,${region}b" || exit 1

	echo -e "\n########## connecting to ${name} eks cluster ##########\n"
	AWS_PROFILE=${aws_profile} aws eks update-kubeconfig --name "${name}"

	# create secret so the pods can pull images from github repo
	echo -e "\n########## creating docker-registry credentials ##########\n"
	kubectl create secret docker-registry regcred --docker-server=docker.pkg.github.com --docker-username=lauferism --docker-password ${github_token}


	# adding bitnami repo to helm to use their charts
	helm repo add bitnami https://charts.bitnami.com/bitnami

	echo -e "\n########## installing mongodb from bitnami helm chart ##########\n"
	helm install mongodb bitnami/mongodb

	echo -e "\n########## installing kafka cluster from bitnami helm chart ##########\n"
	# this also creates zookeeper to manage the kafka replication
	helm install kafka bitnami/kafka


	# getting mongo db root password, it will be injected to the pods to use
	MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace default mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)

	git_top_level=$(git rev-parse --show-toplevel)


	deploy_api_server(){
	    cd ${git_top_level}/kafka-mongo/api_server
	    # changing the deployment.yaml template and replacing the <MONGODB_ROOT_PASSWORD> placeholder with the real value
	    sed -i -e "s/<MONGODB_ROOT_PASSWORD>/${MONGODB_ROOT_PASSWORD}/g" deployment.yaml

	    echo -e "\n########## deploying api_server to cluster ##########\n"
	    kubectl apply -f .

	}


	deploy_web_Server(){
	    cd ${git_top_level}/kafka-mongo/web_server

	    echo -e "\n########## deploying web_server to cluster ##########\n"
	    kubectl apply -f .


	}

	deploy_api_server
	deploy_web_Server

}


destroy(){
	echo -e "\n########## connecting to ${name} eks cluster ##########\n"
        AWS_PROFILE=${aws_profile} aws eks update-kubeconfig --name "${name}"
	echo -e "\n########## uninstalling mongodb and kafka\n"
	helm uninstall mongodb kafka
	echo -e "\n########## destroying eks cluster named ${name} in ${region} region in ${aws_profile} account ##########\n"
	AWS_PROFILE=${aws_profile} eksctl delete cluster --name "${name}" --region "${region}"

}


$action
