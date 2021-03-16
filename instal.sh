#!/bin/sh

kubectl apply -f https://raw.githubusercontent.com/dock8sopf/k8syaml/master/storageplatform/storageplatform.yaml
kubectl apply -f https://raw.githubusercontent.com/dock8sopf/k8syaml/master/storageplatform/storageplatform-service.yaml
kubectl apply -f https://raw.githubusercontent.com/dock8sopf/k8syaml/master/storageplatform/pods/etcd.yaml
kubectl apply -f https://raw.githubusercontent.com/dock8sopf/k8syaml/master/openplatform/openplatform.yaml
kubectl apply -f https://raw.githubusercontent.com/dock8sopf/k8syaml/master/openplatform/openplatform-service.yaml
kubectl apply -f https://raw.githubusercontent.com/dock8sopf/k8syaml/master/openplatform/openplatform-ingress.yaml
kubectl apply -f https://raw.githubusercontent.com/dock8sopf/k8syaml/master/openplatform/externelservice.yaml
kubectl apply -f https://raw.githubusercontent.com/dock8sopf/k8syaml/master/openplatform/configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/dock8sopf/k8syaml/master/openplatform/pods/grpcalculator.yaml
kubectl apply -f https://raw.githubusercontent.com/dock8sopf/k8syaml/master/openplatform/pods/opengateway.yaml
kubectl apply -f https://raw.githubusercontent.com/dock8sopf/k8syaml/master/openplatform/pods/openuserinfo.yaml
kubectl apply -f https://raw.githubusercontent.com/dock8sopf/k8syaml/master/dbplatform/dbplatform.yaml
kubectl apply -f https://raw.githubusercontent.com/dock8sopf/k8syaml/master/dbplatform/dbplatform-redis.yaml
kubectl apply -f https://raw.githubusercontent.com/dock8sopf/k8syaml/master/dbplatform/dbplatform-mysql.yaml
kubectl apply -f https://raw.githubusercontent.com/dock8sopf/k8syaml/master/dbplatform/pods/mysql.yaml
kubectl apply -f https://raw.githubusercontent.com/dock8sopf/k8syaml/master/dbplatform/pods/redis.yaml
