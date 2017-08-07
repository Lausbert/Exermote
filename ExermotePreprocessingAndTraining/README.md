<a href="https://github.com/Lausbert/Exermote/tree/master/ExermoteGatheringData">< Exermote Gathering Data</a> | <a href="https://github.com/Lausbert/Exermote/tree/master/ExermoteInference">Exermote Inference ></a>

# Exermote Preprocessing and Training

After collecting labeled data, a model needs to be trained!

## Preprocessing

There were a few preprocessing steps I made. Some of them are rooted in insights I had, when I was already training models:

- merging raw recordings to one file
- reducing total number of classes from 5 to 4, by converting "set break" to "break". I don't know what I was thinking when introducing two different break classes...
- converting the first and last two time steps of every squat repetition to "break". Earlier models often counted squats, when I actually didn't do anything. This fixed it.

## Choosing a model

I intended to write my master thesis in human activity recognition (HAR), but I didn't find a supervisor. Anyway I could use some of the insights from my <a href="https://github.com/Lausbert/Exermote/blob/master/ExermotePreprocessingAndTraining/MasterThesisProposal/master%20thesis%20proposal.pdf">thesis proposal</a>. The following table is an excerpt from this proposal.

<p align="center">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermotePreprocessingAndTraining/MasterThesisProposal/Bildschirmfoto%202017-08-04%20um%2014.55.17.png" width="800">
</p>

As you can see in the last row DeepConvLSTM Neural Networks were already tested by Francisco Javier Ordóñez and Daniel Roggen for recognizing activities of daily living. Their <a href="https://github.com/sussexwearlab/DeepConvLSTM">approach</a> and their <a href="http://www.mdpi.com/1424-8220/16/1/115/html">results</a> impressed me and so I decided to take their model and give it a try for my purpose. The model takes time sequences of raw sensor data and outputs the according exercise label. A simpliefied model represantation looks like this:

<p align="center">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermotePreprocessingAndTraining/MasterThesisProposal/Bildschirmfoto%202017-08-04%20um%2016.29.02.png" width="400">
</p>

The actual model differs in terms of layer and channel (data feature) numbers. Furthermore a higher stride and a dropout layer were added for better generalization:

```python
model = Sequential([
        Conv1D(nodes_per_layer, filter_length, strides=2, activation='relu', input_shape=(timesteps, data_dim),
               name='accelerations'),
        Conv1D(nodes_per_layer, filter_length, strides=1, activation='relu'),
        LSTM(nodes_per_layer, return_sequences=True),
        LSTM(nodes_per_layer, return_sequences=False),
        Dropout(dropout),
        Dense(num_classes),
        Activation('softmax', name='scores'),
    ])
```

## Training

The whole training procedure took place in the google cloud, since I found <a href="http://liufuyang.github.io/2017/04/02/just-another-tensorflow-beginner-guide-4.html">this wonderful tutorial</a>. The machine learning framework in use was Keras with TensorFlow as backend. Many thanks to Google for 300$ of free credits. After training hundreds of models there are still plenty left:

<p align="center">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermotePreprocessingAndTraining/investigation/Bildschirmfoto%202017-08-05%20um%2013.06.51.png" width="400">
</p>

For training observation I used TensorBoard:

<p align="center">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermotePreprocessingAndTraining/investigation/Bildschirmfoto%202017-05-19%20um%2017.46.51.png" width="800">
</p>

The (optimum) parameters shown below where determined during training. ```timesteps``` defines the sliding window length, while ```timesteps_in_future``` specifies which time step label should be characteristic for a sliding window. More ```timesteps_in_future``` would mean a higher accuracy in recognition, while it would worsen live prediction experience.

```python
# training parameters
epochs = 50
batch_size = 100
validation_split = 0.2

# model parameters
dropout = 0.2
timesteps = 40
timesteps_in_future = 20
nodes_per_layer = 32
filter_length = 3
```

While training models with various input combinations, it became clear that the benefit of using the mentioned Nearables is a smaller one. Therefore I gave up on using them any longer. Additional sensors might get interesting again for recognizing one-armed exercises or exercises where only your feet and/or legs are moving.

```python
X = dataset[:, [
        2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, # Device: xGravity, yGravity, zGravity, xAcceleration, yAcceleration, zAcceleration, pitch, roll, yaw, xRotationRate, yRotationRate, zRotationRate
        # 14,15,16,17,                          # Right Hand: rssi, xAcceleration, yAcceleration, zAcceleration
        # 18,19,20,21,                          # Left Hand: rssi, xAcceleration, yAcceleration, zAcceleration
        # 22,23,24,25,                          # Right Foot: rssi, xAcceleration, yAcceleration, zAcceleration
        # 26,27,28,29,                          # Left Foot: rssi, xAcceleration, yAcceleration, zAcceleration
        # 30,31,32,33,                          # Chest: rssi, xAcceleration, yAcceleration, zAcceleration
        # 34,35,36,37                           # Belly: rssi, xAcceleration, yAcceleration, zAcceleration
    ]].astype(float)
    y = dataset[:, 0]  # ExerciseType (Index 1 is ExerciseSubType)
```

The highest recognition accuray achieved on test data with only 12 data features was 95.56 %. Since mainly first or last timesteps of a repetition were confused for a break or the other way around, this accuracy is sufficient for recognizing and counting the mentioned exercises. The best model of a training procedure was saved to google cloud bucket. The model was also exported to .pb and .mlmodel format for later use on google cloud and on iPhone.
