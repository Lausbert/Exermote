<a href="https://github.com/Lausbert/Exermote/blob/master/ExermoteInference/README.md">< Exermote Inference</a> | <a href="https://github.com/Lausbert/Exermote">Exermote Overview ></a>

# Exermote SGAN

While investigating how the exercise recognition in my previous experiments could be further improved, a <a href="https://blog.openai.com/generative-models/#contributions"> blog post</a> caught my eye: 

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

The results could be described as mixed at best. Below you can see results for within-subject testing. The SGAN and our baseline model was trained on 80% of acceleration data and tested on 20% of acceleration data of individual 3.

<p align="center">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteSgan/results/training_on_individual_3_testing_on_individual_3_split_1.0_accelerations.png" width="350">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteSgan/results/training_on_individual_3_testing_on_individual_3_split_1.0_accuracies.png" width="350">
</p>

<p align="center">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteSgan/results/training_on_individual_3_testing_on_individual_3_split_0.6_accelerations.png" width="350">
<img src="https://github.com/Lausbert/Exermote/blob/master/ExermoteSgan/results/training_on_individual_3_testing_on_individual_3_split_0.6_accuracies.png" width="350">
</p>
