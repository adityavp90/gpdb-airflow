**WIP**
<br>The YAML files in this directory can be used to deploy gpdb singlenode to a kubernetes cluster (or minikube)
<br> Why? Cause why not!



Setup environment variables in env.sh


Download packages from PivNet in the pivotal folder:
```
./download.sh
```
Set ENV variable in env.sh
```
source env.sh
```

## Launching Greenplum Docker image on Minikube
```bash
minikube delete
minikube start --memory 4096 --cpus 4
kubectl get node

eval $(minikube docker-env)

docker build --build-arg GPDB_INSTALLER=${GPDB_INSTALLER} \
--build-arg MADLIB_INSTALLER=${MADLIB_INSTALLER} \
--build-arg DATA_SCIENCE_PYTHON_INSTALLER=${DATA_SCIENCE_PYTHON_INSTALLER} \
--build-arg POSTGIS_INSTALLER=${POSTGIS_INSTALLER} \
.

```

kubectl delete deployment gpdb54
kubectl delete service gpdb54


## Configmap
```bash
kubectl create configmap gpdb-config \
--from-literal=gpdb_user=gpadmin \
--from-literal=gpdb_password=pivotal \
--from-literal=gpdb_host=$(minikube ip)
```

kubectl create -f gpdb54.yml
kubectl expose deployment gpdb54 --type=LoadBalancer




kubectl run gpdb54 --image=gpdb54:latest --port=22 --image-pull-policy=Never
kubectl get deployments
kubectl get pods

minikube service gpdb54
kubectl get services

kubectl get events
kubectl config view 
kubectl logs gpdb54-577c768464-26cqs


volumeMounts:
            - name: gpdb-storage
              mountPath: /gpdata
      volumes:
        - name: gpdb-storage
          persistentVolumeClaim:
            claimName: gpdb-pv-claim
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gpdb-pv-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi



## Docker Help:
Build docker image with arguments (Convert into compose script)
```bash
docker build --build-arg GPDB_INSTALLER=${GPDB_INSTALLER} \
--build-arg MADLIB_INSTALLER=${MADLIB_INSTALLER} \
--build-arg DATA_SCIENCE_PYTHON_INSTALLER=${DATA_SCIENCE_PYTHON_INSTALLER} \
--build-arg POSTGIS_INSTALLER=${POSTGIS_INSTALLER} \
.
```

Run intermediate image
docker run -it 604f09f4d69b

Make executable all files in the script folder
chmod +x ./scripts/*


docker tag d6e6db64e041 gpdb54:latest


## Minikube Help:
eval $(minikube docker-env)
eval $(docker-machine env -u)



Woohoo! So a solution adequately simple for this task WAS/IS possible! Thanks a lot!

As described in that fine piece of documentation 156 (the thing is - while it describes things well, it is more elaborate than what I thought would be appropriate for my use case, so it could be that I already skimmed it and didn’t realize that it actually is what I need), I simply created a my own bridge network, assigned a name to both my containers, joined the network with them and done.
For anybody else stumbling across this - this simply means:

docker network create -d bridge mybridge
docker run --rm --network=mybridge -p=6379:6379 --name=redis redis:3-alpine
docker run --rm --network=mybridge -it -p=443:443 --name=version-frontend version-frontend