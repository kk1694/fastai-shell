New fastai version

Using [this](https://course.fast.ai/start_gcp.html#step-4-access-fastai-materials) tutorial as a reference. On the first use, just follow the turoial.

But whenever deleteting a VM instance, use keep the disk:

```
export INSTANCE_NAME="my-fastai-instance"

gcloud compute instances delete $INSTANCE_NAME --keep-disks=all
```

After that, just use this simpler version. This would keep the disk.

```
export IMAGE_FAMILY="pytorch-latest-gpu" # or "pytorch-latest-cpu" for non-GPU instances
export ZONE="us-west2-b" 
export INSTANCE_NAME="my-fastai-instance"
export INSTANCE_TYPE="n1-highmem-8" # budget: "n1-highmem-4"

# budget: 'type=nvidia-tesla-k80,count=1'
gcloud compute instances create $INSTANCE_NAME \
        --zone=$ZONE \
        --image-family=$IMAGE_FAMILY \
        --maintenance-policy=TERMINATE \
        --accelerator="type=nvidia-tesla-p4,count=1" \
        --machine-type=$INSTANCE_TYPE \
        --disk=name=$DISK_NAME,device-name=$DISK_NAME,mode=rw,boot=yes \
        --preemptible
```

Then ssh into it by:

```
gcloud compute ssh --zone=$ZONE jupyter@$INSTANCE_NAME -- -L 8080:localhost:8080
```

Jupyter notebooks at [localhost:8080/tree](localhost:8080/tree)
