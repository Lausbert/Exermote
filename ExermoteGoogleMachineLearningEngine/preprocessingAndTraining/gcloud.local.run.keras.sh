gcloud ml-engine local train \
  --module-name trainer.exermote \
  --package-path ./trainer \
  -- \
  --train-file data_classes_4.csv \
  --job-dir ./tmp/placeholder
