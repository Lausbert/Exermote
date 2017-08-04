# Exermote Gathering Data

Since the later learning procedure is supervised, labeled data is needed.

**Setting**

To record training data of different individuals I used 2 different types of devices:

- Iphone on right upper arm: 12 data features (3x gravity, 3x acceleration, 3x euler angle, 3x rotation rate)
- 6x <a href="https://estimote.com">Estimote Nearables</a> on chest, belly, hands and feet: each 3 data features (3x acceleration)

So there are 30 data features in total. The Nearables were reshaped by using Stewalin, a muffin form and some Velcro cable ties :)

<p align="center">
<sub><sup>needed untensils (left), reshaped Nearables (mid), controlling Iphone remotely via firebase during recording (right)</sup></sub>
<br>
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteGatheringData/Pictures/IMG_2587.JPG" width="250">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteGatheringData/Pictures/IMG_2751.JPG" width="250">
  <img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteGatheringData/Pictures/IMG_2755.JPG" width="250">
</p>

**Recording**

Recording frequency was 10 Hz for the reason that Nearable send frequency is limited to this value on hardware side. Since the official SDK only allows to get Nearable acceleration data once per second, I had to access and decode advertisment data direcly via ```CBCentralManager```. Many thanks to <a href="https://github.com/reelyactive/advlib">reelyactive</a> for inspiration.

Before recording was started remotely via firebase a 5 minute training consisting of burpees, squats, situps, set breaks and breaks was generated randomly.

| time  | exercise type | exercise sub type | 30 data feature columns ... |
|-------|---------------|-------------------|-------------------------|
| 0.1 s | set break     | set break         |                         |
| 0.2 s | set break     | set break         |                         |
| 0.3 s | set break     | set break         |                         |
| 0.4 s | set break     | set break         |                         |
| 0.5 s | set break     | set break         |                         |
| 0.6 s | burpee        | first half        |                         |
| 0.7 s | burpee        | first half        |                         |
| 0.8 s | ...           | ...               |                         |

To ensure that exercising individuals trained accordingly to the pre-generated training, the app gave spoken hints which exercise will follow. Additionally there was a generated whistle, whose pitch decreased during first half and increased during second half of an exerecise repetition. This process guaranteed that pre-generated lables matched perfectly to recorded movement data.

The recorded raw data was saved to my iCloud drive, when recording was finished. It could be found <a href="https://github.com/Lausbert/Exermote/tree/master/ExermotePreprocessingAndTraining/RawData">here</a>.
