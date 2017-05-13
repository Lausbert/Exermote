gcloud ml-engine local train \
  --module-name trainer.exermote \
  --package-path ./trainer \
  -- \
  --train-file data.csv \
  --job-dir ./tmp/exermote_train
