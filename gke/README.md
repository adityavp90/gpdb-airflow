# Instructions for creating GKe deployment of GPDB, Airflow and Concourse


### gcloud installation:
https://cloud.google.com/sdk/docs/quickstart-macos


Your project default Compute Engine zone has been set to [us-west2-a].
You can change it by running [gcloud config set compute/zone NAME]

### pricing
https://cloud.google.com/compute/pricing


Configuration info:
gcloud config list



## demo
https://cloud.google.com/kubernetes-engine/docs/tutorials/hello-app#clean-up


## Build docker image
docker build . -f Dockerfile_Gke -t gcr.io/pde-apadhye/gpdb54:v2


Authenticate docker for gcloud:
gcloud auth configure-docker

### export project id
export PROJECT_ID="$(gcloud config get-value project -q)"

## Create kubernetes cluster for our project
gcloud container clusters create gpdb-airflow --num-nodes=3

### Get cluster credentials for kubectl
gcloud container clusters get-credentials gpdb-airflow

### View kubectl clusters
kubectl config get-contexts

### Push local containers to gcloud registry
docker push gcr.io/pde-apadhye/airflow:v1
docker push gcr.io/pde-apadhye/gpdb54:v2
docker push gcr.io/pde-apadhye/concourse:3.14.1


## deployment using YAML
# Create configmap
kubectl create configmap gpdb-config \
--from-literal=gpdb_user=gpadmin \
--from-literal=gpdb_password=pivotal

kubectl create configmap airflow-config \
--from-literal=airflow_user=gpadmin \
--from-literal=airflow_password=pivotal


kubectl create -f gpdb54.yml

## Manual deployment of docker containers
### Run containers
kubectl run gpdb54 --image=gcr.io/${PROJECT_ID}/gpdb54:v2 --port 5432
kubectl run airflow --image=gcr.io/${PROJECT_ID}/airflow:v1 --port 8080
kubectl run concourse --image=gcr.io/${PROJECT_ID}/concourse:v1 --port 8081

### Expose port
kubectl expose deployment gpdb54 --type=LoadBalancer --port 5432 --target-port 5432
kubectl expose deployment airflow --type=LoadBalancer --port 8080 --target-port 8080
kubectl expose deployment concourse --type=LoadBalancer --port 8081 --target-port 8081

## Delete the service
kubectl delete service gpdb54
kubectl delete service airflow
kubectl delete service concourse

## Check if load balancer is deleted
gcloud compute forwarding-rules list

## Delete the container cluster
gcloud container clusters delete gpdb-airflow








## Remove Airflow Deployment
kubectl delete service airflow
kubectl delete deployment airflow
kubectl delete pvc dags-pv-claim
kubectl delete pvc tasks-pv-claim


kubectl delete service gpdb54
kubectl delete deployment gpdb54


