#!/bin/bash

for crd in $(kubectl get crd | grep generators.external-secrets.io | awk '{print $1}'); do
  echo "Patching and deleting $crd"
  kubectl patch crd "$crd" -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl delete crd "$crd" --ignore-not-found
done
