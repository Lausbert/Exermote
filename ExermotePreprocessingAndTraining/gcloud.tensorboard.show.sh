echo tensorboard log dir: ${LOG_DIR}
tensorboard --logdir=${LOG_DIR}/logs --port 8000 --reload_interval=5
