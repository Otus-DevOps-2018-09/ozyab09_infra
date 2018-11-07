gcloud compute instances create puma-service \
  --project=infra-* \
  --zone=us-east1-b \
  --machine-type=f1-micro \
  --subnet=default \
  --tags=puma-server \
  --image=reddit-base \
  --image-project=infra-* \
  --boot-disk-size=10GB \
  --boot-disk-type=pd-standard
