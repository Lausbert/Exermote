<a href="https://github.com/Lausbert/Exermote/blob/master/ExermoteInference/README.md">< Exermote Inference</a> | <a href="https://github.com/Lausbert/Exermote">Exermote Overview ></a>

# Exermote SGAN

While investigating how exercise recognition in my previous experiments could be further improved, a <a href="https://blog.openai.com/generative-models/#contributions"> blog post</a> caught my eye: 

> In addition to generating pretty pictures, we introduce an approach for semi-supervised learning with GANs that involves the discriminator producing an additional output indicating the label of the input. This approach allows us to obtain state of the art results on MNIST, SVHN, and CIFAR-10 in settings with very few labeled examples. On MNIST, for example, we achieve 99.14% accuracy with only 10 labeled examples per class with a fully connected neural network — a result that’s very close to the best known results with fully supervised approaches using all 60,000 labeled examples. This is very promising because labeled examples can be quite expensive to obtain in practice.

After checking a related <a href="https://arxiv.org/abs/1606.01583"> paper</a>, I was willing to give SGANs a try. The foundational idea is to force a discriminator in a GAN to output a label. So while your generator learns to generate data similar to your original data, your discriminator should be better in categorizing data than a baseline model without the whole GAN setup. Enough talk, let's dive in!

## Implementation

The baseline model exactly matches the one I used <a href="https://github.com/Lausbert/Exermote/tree/master/ExermotePreprocessingAndTraining"> before</a>.

```python
def __build_baseline(self):
    model = Sequential()
    model.add(Conv1D(self.nodes_per_layer, self.filter_length, strides=2, activation="relu", input_shape=(self.timesteps, self.features)))
    model.add(Conv1D(self.nodes_per_layer, self.filter_length, strides=1, activation="relu",))
    model.add(LSTM(self.nodes_per_layer, return_sequences=True))
    model.add(LSTM(self.nodes_per_layer, return_sequences=False))
    model.add(Dropout(self.dropout))
    accelerations = Input(shape=(self.timesteps, self.features), name="accelerations")
    scores = Dense(self.num_classes, activation="softmax", name="scores")(model(accelerations))
    return Model(accelerations, scores)
```

The discriminator is pretty similar. To enable adversariality a sigmoid output for predicting input validity is added. Additionaly a fake class is added to the softmax layer.

```python
def __build_discriminator(self):
    model = Sequential()
    model.add(Conv1D(self.nodes_per_layer, self.filter_length, strides=2, activation="relu", input_shape=(self.timesteps, self.features)))
    model.add(Conv1D(self.nodes_per_layer, self.filter_length, strides=1, activation="relu"))
    model.add(LSTM(self.nodes_per_layer, return_sequences=True))
    model.add(LSTM(self.nodes_per_layer, return_sequences=False))
    model.add(Dropout(self.dropout))
    accelerations = Input(shape=(self.timesteps, self.features), name="accelerations")
    features = model(accelerations)
    valid = Dense(1, activation="sigmoid")(features)
    scores = Dense(self.num_classes + 1, activation="softmax", name="scores")(features)
    return Model(accelerations, [valid, scores])
```

The generator contains LSTM layers to imitate time-related structures of raw acceleration data. After that convolutions are applied to model relations between different feature channels. Before outputting generated acceleration data, the feature channels are cropped. The models capability of modeling realistic acceleration data was limited before I came up with this idea.

```python
def __build_generator(self):
    model = Sequential()
    model.add(Dense((((self.timesteps * 2) + 20) * self.features * 5), activation="relu", input_dim=self.generator_input_length))
    model.add(Reshape(((self.timesteps * 2) + 20, self.features * 5)))
    model.add(LSTM(self.features * 5, return_sequences=True))
    model.add(LSTM(self.features * 5, return_sequences=True))
    model.add(Reshape(((self.timesteps * 2) + 20, self.features * 5, 1)))
    model.add(AveragePooling2D(pool_size=(1, 5)))
    model.add(Conv2D(128, kernel_size=(1, 3), padding="same", activation="relu"))
    model.add(Conv2D(64, kernel_size=(1, 3), padding="same", activation="relu"))
    model.add(Conv2D(1, kernel_size=3, padding="same", activation="tanh"))
    model.add(AveragePooling2D(pool_size=(2, 1)))
    model.add(Cropping2D(cropping=((5, 5), (0, 0))))
    noise = Input(shape=(self.generator_input_length,), name="noise")
    accelerations = Reshape((self.timesteps, self.features), name="accelerations")(model(noise))
    return Model(noise, accelerations)
```

So let's put our model to work!

## Results

The results could be described as mixed at best. Below you can see some results for within-subject testing. The SGAN and our baseline model was trained on 80% of acceleration data and tested on 20% of acceleration data of individual 3. Looking at validation accuracy for categorizing exercises, it takes some training epochs until discriminator catches up with the baseline. I guess this is due to the generator, which needs some training before it produces useful data. Anyway the SGAN setup does not deliver any benefits, especially if you consider increased training time and its more complex model. This is disappointing regarding the fact that the generator seems actually able to imitate training data, what could be observed in the right image below. Each of the 16 colored boxes represent 12 normalized features (x-Axis; 3\*acceleration, 3\*gravitation, 3\*orientation, 3\*rotation rate) over 2.5 seconds (y-Axis; 0.1 seconds step size). While the upper 8 boxes show generated exercise data, the lower 8 show recorded data. By comparing generated with recorded data, you can interpret some of the generated exercise data as break, burpee or squat.

<p align="center">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteSgan/results/training_on_individual_3_testing_on_individual_3_split_1.0_accuracies.png" width="350">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteSgan/results/training_on_individual_3_testing_on_individual_3_split_1.0_accelerations.png" width="350">
</p>

If we reduce the amount of training data while validating one same testing data, the discriminator achieves slightly better results compared to baseline. Anyway it is not said, that this difference is significant or even more important justifies increased training time and more complexity.

<p align="center">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteSgan/results/training_on_individual_3_testing_on_individual_3_split_0.6_accuracies.png" width="350">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteSgan/results/training_on_individual_3_testing_on_individual_3_split_0.6_accelerations.png" width="350">
</p>

When testing on data of individual 4 while training on data of individuals 0, 1, 2, 3 and 5 results are also somewhat disillusioning.

<p align="center">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteSgan/results/training_on_individuals_0_1_2_3_5_testing_on_individual_4_split_1.0_accelerations.png" width="350">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteSgan/results/training_on_individuals_0_1_2_3_5_testing_on_individual_4_split_1.0_accuracies.png" width="350">
</p>

However when drastically reducing training data, the discriminator performs a lot better. Anyway their are many counter examples in results folder above. So it's still an open question if the SGAN setup delivers any fundamental advantages.

<p align="center">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteSgan/results/training_on_individuals_0_1_2_3_5_testing_on_individual_4_split_0.05_accelerations.png" width="350">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteSgan/results/training_on_individuals_0_1_2_3_5_testing_on_individual_4_split_0.05_accuracies.png" width="350">
</p>

## Conclusion

When comparing my results with experiments touching SGANs and MNIST, there are some obvious differences, which could explain these disappointing results:

- There is no null class in MNIST dataset
- The variance (especially in null class) of different samples might be higher
- There are temporal dependencies and I'm not sure, if my model is able to replicate them in a sufficient manner
- many more...

To be honest the theoretical background of my decicions regarding generator structure is pretty thin. I assume that an in-depth invistigation is needed to make informed improvements. Anyway ain't nobody got time for that :) I hope you enjoyed my thoughts. Feel free to reach out to me or leave me a comment on my <a href="http://lausbert.com/2018/08/13/exermote-improving-a-fitness-tracker-with-sgan/">blog</a>.
