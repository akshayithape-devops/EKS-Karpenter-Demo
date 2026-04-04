# EKS Karpenter Demo

## Overview 

This section demonstrates how to install and configure Karpenter a Kubernetes cluster autoscaler designed for AWS EKS. Karpenter automatically provisions and manages EC2 instances based on pod scheduling requirements, offering faster scaling, better bin-packing, and cost optimization compared to traditional Cluster Autoscaler.

## What is Karpenter?

Karpenter is an open-source, flexible, high-performance Kubernetes cluster autoscaler that:

- Provisions nodes in seconds, not minutes
- Automatically selects optimal instance types based on pod requirements
- Supports Spot instances with graceful interruption handling
- Consolidates nodes to reduce costs when capacity is underutilized
- Eliminates the need for managing Auto Scaling Groups (ASGs)

## Project Structure

```
01_EKS_Karpenter_Demo
├── k8s
│   ├── app
│   │   ├── load-generator.yaml
│   │   ├── webapp-hpa.yaml
│   │   ├── webapp-svc.yaml
│   │   └── webapp.yaml
│   └── karpenter
│       ├── 01_ec2nodeclass.yaml
│       ├── 02_nodepool_ondemand.yaml
│       └── 03_nodepool_spot.yaml
├── README.md
└── terraform
    ├── eks
    │   ├── datasources_and_locals.tf
    │   ├── ebscsi-eksaddon.tf
    │   ├── ebscsi-eks-pod-identity-association.tf
    │   ├── ebscsi-iam-policy-and-role.tf
    │   ├── eksaddon_metrics_server.tf
    │   ├── eks_cluster_iamrole.tf
    │   ├── eks_cluster.tf
    │   ├── eks_nodegroup_iamrole.tf
    │   ├── eks_nodegroup_private.tf
    │   ├── env
    │   │   ├── dev.tfvars
    │   │   ├── prod.tfvars
    │   │   └── staging.tfvars
    │   ├── externaldns-eksaddon.tf
    │   ├── externaldns-iam-policy-and-role.tf
    │   ├── externaldns-pod-identity-association.tf
    │   ├── helm-and-kubernetes-providers.tf
    │   ├── lbc-eks-pod-identity-association.tf
    │   ├── lbc-helm-install.tf
    │   ├── lbc-iam-policy-and-role.tf
    │   ├── lbc-iam-policy-datasources.tf
    │   ├── outputs.tf
    │   ├── podidentityagent-eksaddon.tf
    │   ├── podidentity-assumerole.tf
    │   ├── provider.tf
    │   ├── remote-state.tf
    │   ├── secretstorecsi-ascp-helm-install.tf
    │   ├── secretstorecsi-helm-install.tf
    │   ├── tags.tf
    │   ├── terraform.tfvars
    │   └── variables.tf
    ├── karpenter
    │   ├── datasources_and_locals.tf
    │   ├── eks_remote_state.tf
    │   ├── helm_and_kubernetes_providers.tf
    │   ├── karpenter_access_entry.tf
    │   ├── karpenter_controller_iam_policy.tf
    │   ├── karpenter_controller_iam_role.tf
    │   ├── karpenter_eventbridge_rules.tf
    │   ├── karpenter_helm_install.tf
    │   ├── karpenter_node_iam_role.tf
    │   ├── karpenter_pod_identity_association.tf
    │   ├── karpenter_sqs_queue.tf
    │   ├── provider.tf
    │   ├── variables.tf
    │   └── vpc_remote_state.tf
    └── vpc
        ├── main.tf
        ├── modules
        │   └── vpc
        │       ├── datasources-and-locals.tf
        │       ├── main.tf
        │       ├── outputs.tf
        │       ├── README.md
        │       └── variables.tf
        ├── outputs.tf
        ├── provider.tf
        ├── terraform.tfvars
        └── variables.tf

11 directories, 62 files
```

## Prerequisites

- ✅ AWS CLI configured with appropriate credentials
- ✅ Terraform >= 1.13.0 installed
- ✅ kubectl >= 1.34 installed
- ✅ Helm >= 3.0 installed
- ✅ S3 bucket for Terraform remote state (update bucket names in c1_versions.tf for each terraform project)

## Deployment Steps

### Step 1: Deploy VPC

```
cd terraform/vpc
terraform init
terraform apply -auto-approve
```

### Step 2: Deploy EKS Cluster + Add-ons

```
cd terraform/eks
terraform init
terraform apply -auto-approve
```
### Step 3: Deploy Karpenter 

```
cd terraform/karpenter
terraform init
terraform apply -auto-approve
```

### Step 4: Configure kubectl 

```
aws eks --region ap-south-1 --profile eks-demo-cloudops update-kubeconfig --name retail-dev-eks-karpenter-demo
```

### Step 5: Verify Karpenter is running

```
kubectl get pods -n kube-system -l app.kubernetes.io/name=karpenter
```

### Step 6: Apply Karpenter Configuration

```
cd k8s/karpenter
kubectl apply -f 01_ec2nodeclass.yaml
kubectl apply -f 02_nodepool_ondemand.yaml
kubectl apply -f 03_nodepool_spot.yaml
```

### Step 7: Verify NodePools and EC2Nodeclass

```
ectl get nodepools
kubectl get ec2nodeclass
```

### Step 8: Watch Karpenter logs 

```
kubectl logs -n kube-system -l app.kubernetes.io/name=karpenter -f

```

### Step 9: Deploy the application

```
cd k8s/app
kubectl apply -f webapp.yaml
kubectl apply -f webapp-svc.yaml
kubectl apply -f webapp-hpa.yaml
kubectl apply -f load-generator.yaml

```

### Step 10: Watch the pods & nodes

```
kubectl get pods
kubectl get nodes
```

## Thanks