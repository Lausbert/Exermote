export BUCKET_NAME=exermotesgan
export JOB_NAME="exermotesgan_$(date +%Y%m%d_%H%M%S)"
export REGION=europe-west1

gcloud ml-engine jobs submit training $JOB_NAME \
  --job-dir gs://$BUCKET_NAME/$JOB_NAME \
  --runtime-version 1.4 \
  --python-version 3.5 \
  --module-name trainer.exermotesgan \
  --package-path ./trainer \
  --region $REGION \
  --config=trainer/cloudml-gpu.yaml \
  -- \
  --train-file gs://exermotesgan/data_classes_4_squats_adjusted_individual_added.csv
