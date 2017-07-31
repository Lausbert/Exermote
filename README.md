# Exermote

Exermote is a fitness app prototype, which is capable to detect Burpees, Squats and Situps and to count related repetitions.

<p align="center">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteInference/ExermoteCoreML/ExampleGif/ExermoteGif.gif" width="500">
</p>

The exercise recognition is done with Convolutional LSTM Neural Networks, so the project is divided into the following steps.

**Gathering labeled data**

The most time-consuming step was to record labeled data of different individuals. All related files and documentation could be found in <a href="https://github.com/Lausbert/Exermote/tree/master/ExermoteGatheringData">ExermoteGatheringData</a>.

**Defining and training the model**

The following data preprocessing, model training and evaluation could be found in <a href="https://github.com/Lausbert/Exermote/tree/master/ExermotePreprocessingAndTraining">ExermotePreprocessingAndTraining</a>.

**Building the actual app**

The implementation of the best trained model could be found in <a href="https://github.com/Lausbert/Exermote/tree/master/ExermoteInference">ExermoteInference</a>.
