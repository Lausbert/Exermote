from glob import glob
from os import path
from pandas import read_csv, concat
from csv import writer

#load data
folder_path = '/Users/stephanlerner/Library/Mobile Documents/iCloud~com~Lausbert~Exermote/Documents/'
all_files = glob(path.join(folder_path, '*.csv'))
dataframe = concat((read_csv(f,header=0) for f in all_files),ignore_index=True)
dataframe.fillna(0, inplace=True)
dataset = dataframe.values

X = dataset[:,[
    54,55,56,57,58,59,60,61,62,63,64,65, #Device: xGravity, yGravity, zGravity, xAcceleration, yAcceleration, zAcceleration, pitch, roll, yaw, xRotationRate, yRotationRate, zRotationRate
    2,3,4,5,                             #Right Hand: rssi, xAcceleration, yAcceleration, zAcceleration
    29, 30, 31, 32,                      #Left Hand: rssi, xAcceleration, yAcceleration, zAcceleration
    47,48,49,50,                         #Right Foot: rssi, xAcceleration, yAcceleration, zAcceleration
    11,12,13,14,                         #Left Foot: rssi, xAcceleration, yAcceleration, zAcceleration
    20,21,22,23,                         #Chest: rssi, xAcceleration, yAcceleration, zAcceleration
    38,39,40,41                          #Belly: rssi, xAcceleration, yAcceleration, zAcceleration
    ]].astype(float)

Y = dataset[:,[
    66, 67                               #Label: ExerciseType, ExerciseSubType
    ]]

X = X.tolist()
Y = Y.tolist()

def merge_data_and_labels(X,y):
    for i in range(len(y)):
        if y[i][0] == 'setBreak':
            X[i].insert(0,'Break')
            X[i].insert(0, 'Break')
        else:
            X[i].insert(0,y[i][1])
            X[i].insert(0, y[i][0])
    return(X)

data = merge_data_and_labels(X,Y)
header = [
    'ExerciseType', 'ExerciseSubType',
    'Device:xGravity', 'Device:yGravity', 'Device:zGravity', 'Device:xAcceleration', 'Device:yAcceleration', 'Device:zAcceleration', 'Device:pitch', 'Device:roll', 'Device:yaw', 'Device:xRotationRate', 'Device:yRotationRate', 'Device:zRotationRate',
    'Right Hand:rssi', 'Right Hand:xAcceleration', 'Right Hand:yAcceleration', 'Right Hand:zAcceleration',
    'Left Hand:rssi', 'Left Hand:xAcceleration', 'Left Hand:yAcceleration', 'Left Hand:zAcceleration',
    'Right Foot:rssi', 'Right Foot:xAcceleration', 'Right Foot:yAcceleration', 'Right Foot:zAcceleration',
    'Left Foot:rssi', 'Left Foot:xAcceleration', 'Left Foot:yAcceleration', 'Left Foot:zAcceleration',
    'Chest:rssi', 'Chest:xAcceleration', 'Chest:yAcceleration', 'Chest:zAcceleration',
    'Belly:rssi', 'Belly:xAcceleration', 'Belly:yAcceleration', 'Belly:zAcceleration'
]

data.insert(0,header)

#write data
with open('data.csv', 'w', newline="") as f:
    writer = writer(f)
    writer.writerows(data)