<a href="https://github.com/Lausbert/Exermote">< Exermote Overview</a> | <a href="https://github.com/Lausbert/Exermote/tree/master/ExermotePreprocessingAndTraining">Exermote Preprocessing and Training ></a>

# Exermote Gathering Data

Since the later learning procedure is supervised, labeled data is needed.

## Setting

To record training data of different individuals I used 2 different types of devices:

- Iphone on right upper arm: 12 data features (3x gravity, 3x acceleration, 3x euler angle, 3x rotation rate)
- 6x <a href="https://estimote.com">Estimote Nearables</a> on chest, belly, hands and feet: each 4 data features (3x acceleration, 1x rssi)

So there are 36 data features in total. The Nearables were reshaped by using Stewalin, a muffin form and some Velcro cable ties :)

<p align="center">
<sub><sup>needed untensils (left), reshaped Nearables (mid), remotely starting recording procedure via firebase (right)</sup></sub>
<br>
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteGatheringData/Pictures/IMG_2587.jpg" width="250">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteGatheringData/Pictures/IMG_2751.jpg" width="250">
  <img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteGatheringData/Pictures/IMG_2755.JPG" width="250">
</p>

## Recording

Recording frequency was 10 Hz for the reason that Nearable send frequency is limited to this value on hardware side. Since the official SDK only allows to get Nearable acceleration data once per second, I had to access and decode advertisment data direcly via ```CBCentralManager```. Many thanks to <a href="https://github.com/reelyactive/advlib">reelyactive</a> for inspiration.

Before recording was started a 5 minute training consisting of "burpees", "squats", "situps", "set breaks" and "breaks" had been generated randomly.

| time  | exercise type | exercise sub type | 36 data feature columns ... |
|-------|---------------|-------------------|-------------------------|
| 0.1 s | set break     | set break         |                         |
| 0.2 s | set break     | set break         |                         |
| 0.3 s | set break     | set break         |                         |
| 0.4 s | set break     | set break         |                         |
| 0.5 s | set break     | set break         |                         |
| 0.6 s | burpee        | first half        |                         |
| 0.7 s | burpee        | first half        |                         |
| 0.8 s | ...           | ...               |                         |

To ensure that exercising individuals trained accordingly to the pre-generated training and therefore labels matched perfectly to recorded movement data, the app gave spoken hints which exercise will follow. Additionally there was a generated whistle, whose pitch decreased during first half and increased during second half of an exerecise repetition.

The <a href="https://github.com/Lausbert/Exermote/tree/master/ExermotePreprocessingAndTraining/RawData">raw data</a> contained 3 hours (=108000 data points) of 6 individuals and was saved to my iCloud drive, when recording was finished.
