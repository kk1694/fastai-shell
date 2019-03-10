# Setting up google cloud bucket

For a long time I was frustrated with google cloud. They are super generous to give $300 free credits, but to use their system is a pain. Then, I found a great guide on how set up GCP and even save $$$:
1. Create a disk that will be accessed by multiple VM's.
1. Depending on what task you want to do, create a VM. For example, for downloading stuff, a CPU only machine is enough.

The guide is [here](https://arunoda.me/blog/ideal-way-to-creare-a-fastai-node). I'm modifying it somewhat, mainly to work with pytorch version 0.4 as well (i.e. 2 kernels).

## Setup

```
export DEVSHELL_PROJECT_ID="XXX"
export VM_NAME="myvm2"
export DISK_NAME="mydisk2"
export ZONE="us-west1-b"
export NET="mynet"
```

Create network: 

```
gcloud compute --project=$DEVSHELL_PROJECT_ID networks create $NET --subnet-mode=auto

```

Firewall rules:

```
gcloud compute --project=$DEVSHELL_PROJECT_ID firewall-rules create allow-all --direction=INGRESS --priority=1000 --network=$NET --action=ALLOW --rules=all --source-ranges=0.0.0.0/0
```

## Create Boot disk

```
gcloud beta compute --project=$DEVSHELL_PROJECT_ID \
 instances create $DISK_NAME \
 --zone=$ZONE \
 --subnet=$NET \
 --machine-type=n1-standard-1 \
 --network-tier=PREMIUM \
 --maintenance-policy=TERMINATE \
 --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
 --accelerator=type=nvidia-tesla-k80,count=1 \
 --image=ubuntu-1804-bionic-v20181003 \
 --image-project=ubuntu-os-cloud \
 --boot-disk-size=50GB \
 --no-boot-disk-auto-delete \
 --boot-disk-type=pd-ssd \
 --boot-disk-device-name=$DISK_NAME
```

SSH into bood disk

```
gcloud compute --project $DEVSHELL_PROJECT_ID ssh --zone $ZONE $DISK_NAME
```

Now configure disk.

```
curl https://raw.githubusercontent.com/kk1694/fastai-shell/master/setup-gce.sh | bash
```

SSH into it again (the bash script had a reboot command).

```
gcloud compute --project $DEVSHELL_PROJECT_ID ssh --zone $ZONE $DISK_NAME
```

## Activate jupyter

```
source activate pytorch_env
jupyter notebook --generate-config
jupyter notebook password
exit
```

## Delete temporary VM.

```
gcloud compute instances delete $DISK_NAME --zone=$ZONE --project=$DEVSHELL_PROJECT_ID
```
## Create desired machine

Based on the workload, you can specify whatever machine makes most sense.

Note, make sure that you have the correct project selected.

### Cheapest: CPU-only (around $0.01/hour)

```
gcloud beta compute  \
 instances create $VM_NAME \
 --zone=$ZONE \
 --subnet=$NET \
 --network-tier=PREMIUM \
 --no-restart-on-failure \
 --maintenance-policy=TERMINATE \
 --preemptible \
 --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
 --disk=name=$DISK_NAME,device-name=$DISK_NAME,mode=rw,boot=yes \
 --machine-type=n1-standard-1 
 
```

### Cheap: K80 GPU (around $0.2/hour)

```
gcloud beta compute \
 instances create $VM_NAME \
 --zone=$ZONE \
 --subnet=$NET \
 --network-tier=PREMIUM \
 --no-restart-on-failure \
 --maintenance-policy=TERMINATE \
 --preemptible \
 --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
 --disk=name=$DISK_NAME,device-name=$DISK_NAME,mode=rw,boot=yes \
 --machine-type=n1-standard-4 \
 --accelerator=type=nvidia-tesla-k80,count=1
```

### P100 (around $0.5/hour)

```
gcloud beta compute \
 instances create $VM_NAME \
 --zone=$ZONE \
 --subnet=$NET \
 --network-tier=PREMIUM \
 --no-restart-on-failure \
 --maintenance-policy=TERMINATE \
 --preemptible \
 --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
 --disk=name=$DISK_NAME,device-name=$DISK_NAME,mode=rw,boot=yes \
 --machine-type=n1-standard-8 \
 --accelerator=type=nvidia-tesla-p100,count=1
```

## Delete Node

```
gcloud compute instances delete myvm2
```
