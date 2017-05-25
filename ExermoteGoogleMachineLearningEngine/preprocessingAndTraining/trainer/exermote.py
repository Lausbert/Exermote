from tensorflow.python.lib.io import file_io
import argparse
from pandas import read_csv
from sklearn.preprocessing import LabelEncoder, MinMaxScaler
from keras.utils import np_utils
from keras.models import Sequential
from keras.layers import Dense, Activation, Dropout, LSTM, Conv1D
from keras.callbacks import TensorBoard, ModelCheckpoint
from numpy import array

import keras.backend as K
import tensorflow as tf
from keras.models import load_model, Sequential
from tensorflow.python.saved_model import builder as saved_model_builder
from tensorflow.python.saved_model import tag_constants, signature_constants
from tensorflow.python.saved_model.signature_def_utils_impl import predict_signature_def

#parameters
epochs= 1
batch_size= 100
validation_split = 0.2

#model parameters
dropout = 0.2
timesteps = 30
timesteps_in_future = 0
nodes_per_layer = 16
filter_length = 3

def train_model(train_file='data.csv', job_dir='leeeeeroooooyyyyyjeeeeeenkins', **args):
    parameterString = 'dropout_' + str(dropout) + '_timesteps_' + str(timesteps) + '_timesteps_in_future_' + str(timesteps_in_future) + '_nodes_per_layer_' + str(nodes_per_layer) + '_filter_length_' + str(filter_length)
    if 'gs://' in job_dir:
        logs_path = 'gs://exermotemachinelearningengine' + '/logs/' + parameterString
    else:
        logs_path = '.' + '/logs/' + parameterString
    print('-----------------------')
    print('Using train_file located at {}'.format(train_file))
    print('Using logs_path located at {}'.format(logs_path))
    print('-----------------------')

    # load data
    file_stream = file_io.FileIO(train_file, mode='r')
    dataframe = read_csv(file_stream, header=0)
    dataframe.fillna(0, inplace=True)
    dataset = dataframe.values

    X = dataset[:, [
        2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
        # Device: xGravity, yGravity, zGravity, xAcceleration, yAcceleration, zAcceleration, pitch, roll, yaw, xRotationRate, yRotationRate, zRotationRate
        # 14,15,16,17,                        # Right Hand: rssi, xAcceleration, yAcceleration, zAcceleration
        # 18,19,20,21,                        # Left Hand: rssi, xAcceleration, yAcceleration, zAcceleration
        # 22,23,24,25,                        # Right Foot: rssi, xAcceleration, yAcceleration, zAcceleration
        # 26,27,28,29,                        # Left Foot: rssi, xAcceleration, yAcceleration, zAcceleration
        # 30,31,32,33,                        # Chest: rssi, xAcceleration, yAcceleration, zAcceleration
        # 34,35,36,37                         # Belly: rssi, xAcceleration, yAcceleration, zAcceleration
    ]].astype(float)
    y = dataset[:, 0]  # ExerciseType (Index 1 is ExerciseSubType)

    # data parameters
    data_dim = X.shape[1]
    num_classes = len(set(y))


    # scale X
    scaler = MinMaxScaler(feature_range=(0, 1))
    X = scaler.fit_transform(X)  # X*scaler.scale_+scaler.min_ (columnwise)
    print('Multiplying each row in X elementwise: {}'.format(scaler.scale_))
    print('Increasing each row in X elemtwise: {}'.format(scaler.min_))

    # encode Y
    encoder = LabelEncoder()
    encoder.fit(y)
    encoded_y = encoder.transform(y)  # encoder.classes_
    print('Hotencoding Y: {}'.format(encoder.classes_))
    hot_encoded_y = np_utils.to_categorical(encoded_y)

    # prepare data for LSTM
    def create_LSTM_dataset(x, y, timesteps):
        dataX, dataY = [], []
        for i in range(len(x) - timesteps + 1):
            dataX.append(x[i:i + timesteps, :])
            dataY.append(y[i + timesteps - timesteps_in_future - 1, :])
        return array(dataX), array(dataY)

    X, hot_encoded_y = create_LSTM_dataset(X, hot_encoded_y, timesteps)

    # define model
    model = Sequential([
        Conv1D(nodes_per_layer, filter_length, strides=2, activation='relu', input_shape=(timesteps, data_dim), name='input_x'), # strides = 2 for faster training and better generalization
        Conv1D(nodes_per_layer, filter_length, strides=1, activation='relu'),
        LSTM(nodes_per_layer, return_sequences=True),
        LSTM(nodes_per_layer, return_sequences=False),
        Dropout(dropout),
        Dense(num_classes),
        Activation('softmax', name='output_y'),
    ])

    model.summary()

    # compile model
    model.compile(optimizer='rmsprop',
                  loss='categorical_crossentropy',
                  metrics=['accuracy'])

    # define callbacks
    callbacks = []

    tensor_board = TensorBoard(log_dir=logs_path, histogram_freq=1, write_graph=False, write_images=False)
    callbacks.append(tensor_board)

    #throws an error on Google Cloud Machine Learning Engine
    #checkpoint_dir_placeholder = logs_path + '/weights_epoch_{epoch:02d}_val_acc_{val_acc:.4f}.hdf5'
    #checkpoint = ModelCheckpoint(checkpoint_dir_placeholder, monitor='val_acc', verbose=1, save_best_only=True, mode='max')
    #callbacks.append(checkpoint)

    # train model
    model.fit(X, hot_encoded_y,
                        batch_size=batch_size,
                        epochs=epochs,
                        verbose=1,
                        validation_split=validation_split,
                        callbacks=callbacks
                        )

    # save model
    model.save('model.h5')
    
    # save model.h5 on to google storage
    with file_io.FileIO('model.h5', mode='r') as input_f:
        with file_io.FileIO(logs_path + '/' + 'model.h5', mode='w+') as output_f:
            output_f.write(input_f.read())

    # reset session
    K.clear_session()
    sess = tf.Session()
    K.set_session(sess)

    # disable loading of learning nodes
    K.set_learning_phase(0)

    # load model
    model = load_model('model.h5')
    config = model.get_config()
    weights = model.get_weights()
    new_Model = Sequential.from_config(config)
    new_Model.set_weights(weights)

    # export current best model
    export_path = logs_path + "/export"
    builder = saved_model_builder.SavedModelBuilder(export_path)

    signature = predict_signature_def(inputs={'accelerations': new_Model.input},
                                      outputs={'scores': new_Model.output})

    with K.get_session() as sess:
        builder.add_meta_graph_and_variables(sess=sess,
                                             tags=[tag_constants.SERVING],
                                             signature_def_map={
                                                 signature_constants.DEFAULT_SERVING_SIGNATURE_DEF_KEY: signature})
        builder.save()



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    # Input Arguments
    parser.add_argument(
      '--train-file',
      help='GCS or local paths to training data',
      required=True
    )
    parser.add_argument(
      '--job-dir',
      help='GCS location to write checkpoints and export models',
      required=True
    )
    args = parser.parse_args()
    arguments = args.__dict__
    
    train_model(**arguments)
