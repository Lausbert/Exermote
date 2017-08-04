# Exermote Preprocessing and Training

After collecting labeled data, a model needs to be trained!

**Preprocessing**

There were a few preprocessing steps I made. Some of them are rooted in insights I had, when I was already training models:

- merging raw recordings to one file
- reducing total number of classes from 5 to 4, by converting "set break" to "break". I don't know what I was thinking when introducing two different break classes...
- converting the first and last two time steps of every squat repetition to "break". Earlier models often counted squats, when I actually didn't do anything. This fixed it.
