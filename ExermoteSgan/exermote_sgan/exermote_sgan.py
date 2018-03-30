from keras.layers import Input, Dense, Dropout, LSTM, Conv1D, Reshape, Conv2D, concatenate, MaxPooling2D, Activation
from keras.models import Sequential, Model
from keras.optimizers import Adam
from keras.backend import sum
from tensorflow.python.lib.io import file_io
from pandas import read_csv
from sklearn.preprocessing import LabelEncoder, MinMaxScaler
from keras.utils.np_utils import to_categorical
from keras.utils.generic_utils import get_custom_objects
import numpy as np
import matplotlib.pyplot as plt
import os
import datetime


def normalized_linear(x):
    return x/sum(x, axis=-1, keepdims=True)


get_custom_objects().update({"normalized_linear": Activation(normalized_linear)})


class SGAN:
    def __init__(self):
        self.num_classes = 4
        self.features = 12
        self.timesteps = 40
        self.timesteps_in_future = 20
        self.nodes_per_layer = 32
        self.filter_length = 3
        self.generator_input_length = 100
        self.dropout = 0.2
        self.encoder = LabelEncoder()
        self.results_folder_name = "results/" + datetime.datetime.now().strftime('%Y%m%d_%H-%M-%S')
        self.exercise_description = ""

        optimizer = Adam(0.0002, 0.5)

        # Build and compile the generator
        self.generator = self.__build_generator()
        self.generator.summary()
        self.generator.compile(loss=["binary_crossentropy"], optimizer=optimizer)

        # Build and compile the discriminator
        self.discriminator = self.__build_discriminator()
        self.discriminator.summary()
        self.discriminator.compile(loss=["categorical_crossentropy"], optimizer=optimizer, metrics=["accuracy"])

        # For the combined model we will only train the generator
        self.discriminator.trainable = False

        # The generator takes noise as input and generates accelerations
        random_labels = Input(shape=(self.num_classes + 1,))
        noise = Input(shape=(self.generator_input_length - (self.num_classes + 1),))
        generated_accelerations = self.generator([random_labels, noise])

        # The valid takes generated images as input and determines validity
        generated_scores = self.discriminator(generated_accelerations)

        # The combined model  (stacked generator and discriminator) takes
        # noise as input => generates images => determines validity
        self.combined = Model([random_labels, noise], generated_scores)
        self.combined.summary()
        self.combined.compile(loss=["categorical_crossentropy"], optimizer=optimizer)

        # Build and compile the discriminator for inference (fake class removed)
        accelerations = Input(shape=(self.timesteps, self.features))
        kernel = np.concatenate((np.identity(self.num_classes), np.zeros((1, self.num_classes))), axis=0)
        bias = np.zeros(self.num_classes)
        inference_scores = Dense(self.num_classes, activation="normalized_linear", name="inference_scores", weights=[kernel, bias])(self.discriminator(accelerations))
        self.inference_discriminator = Model(accelerations, inference_scores)
        self.inference_discriminator.trainable = False
        self.inference_discriminator.summary()
        self.inference_discriminator.compile(loss=["categorical_crossentropy"], optimizer=optimizer, metrics=["accuracy"])

        # Build and compile the baseline
        self.baseline = self.__build_baseline()
        self.baseline.summary()
        self.baseline.compile(loss=["categorical_crossentropy"], optimizer=optimizer, metrics=["accuracy"])

    def __build_discriminator(self):

        model = Sequential()

        model.add(Conv1D(self.nodes_per_layer, self.filter_length, strides=2, activation="relu", input_shape=(self.timesteps, self.features)))
        model.add(Conv1D(self.nodes_per_layer, self.filter_length, strides=1, activation="relu"))
        model.add(LSTM(self.nodes_per_layer, return_sequences=True))
        model.add(LSTM(self.nodes_per_layer, return_sequences=False))
        model.add(Dropout(self.dropout))

        accelerations = Input(shape=(self.timesteps, self.features), name="accelerations")
        scores = Dense(self.num_classes + 1, activation="softmax", name="scores")(model(accelerations))

        return Model(accelerations, scores)

    def __build_generator(self):

        model = Sequential()

        model.add(Dense(self.timesteps * self.features * 4, activation="relu", input_dim=self.generator_input_length))
        model.add(Reshape((self.timesteps * 2, self.features * 2)))
        model.add(LSTM(self.features, return_sequences=True))
        model.add(LSTM(self.features, return_sequences=True))
        model.add(Reshape((self.timesteps * 2, self.features, 1)))
        model.add(Conv2D(self.nodes_per_layer * 2, kernel_size=(6, 3), padding="same", activation="relu"))
        model.add(Conv2D(self.nodes_per_layer, kernel_size=(6, 3), padding="same", activation="relu"))
        model.add(Conv2D(1, kernel_size=3, padding="same", activation="tanh"))
        model.add(MaxPooling2D(pool_size=(2, 1)))

        random_labels = Input(shape=(self.num_classes + 1,), name="random_labels")
        noise = Input(shape=(self.generator_input_length - (self.num_classes + 1),), name="noise")
        accelerations = Reshape((self.timesteps, self.features), name="accelerations")(model(concatenate([random_labels, noise])))

        return Model([random_labels, noise], accelerations)

    def __build_baseline(self):

        model = Sequential()

        model.add(Conv1D(self.nodes_per_layer, self.filter_length, strides=2, activation="relu",
                         input_shape=(self.timesteps, self.features)))
        model.add(Conv1D(self.nodes_per_layer, self.filter_length, strides=1, activation="relu"))
        model.add(LSTM(self.nodes_per_layer, return_sequences=True))
        model.add(LSTM(self.nodes_per_layer, return_sequences=False))
        model.add(Dropout(self.dropout))

        accelerations = Input(shape=(self.timesteps, self.features), name="accelerations")
        scores = Dense(self.num_classes, activation="softmax", name="scores")(model(accelerations))

        return Model(accelerations, scores)


    def __create_LSTM_dataset(self, X, y):

        X_temp, y_temp = [], []
        for i in range(len(X) - self.timesteps + 1):
            X_temp.append(X[i:i + self.timesteps, :])
            y_temp.append(y[i + self.timesteps - self.timesteps_in_future - 1, :])
        return np.array(X_temp), np.array(y_temp)

    def __scale_dataset(self, X_train, X_test):

        scaler = MinMaxScaler(feature_range=(0, 1))
        X_train = scaler.fit_transform(X_train)  # X*scaler.scale_+scaler.min_ (columnwise)
        X_test = scaler.transform(X_test)
        print('Multiplying each row in X elementwise: {}'.format(scaler.scale_))
        print('Increasing each row in X elementtwise: {}'.format(scaler.min_))
        return X_train, X_test

    def __hot_encode_dataset(self, y, num_classes):

        self.encoder.fit(y)
        encoded_y = self.encoder.transform(y)
        hot_encoded_y = to_categorical(encoded_y, num_classes=num_classes)
        return hot_encoded_y

    def __get_class_weights(self, y, sgan=True):

        # Class weights:
        # To balance the difference in occurences of digit class labels.
        # 50% of labels that the discriminator trains on are 'fake'.
        # Weight = 1 / frequency
        self.encoder.fit(y)
        encoded_y = self.encoder.transform(y)
        cw = {}
        for i in range(self.num_classes):
            if sgan:
                cw[i] = 2/(np.count_nonzero(encoded_y == i)/len(encoded_y))
            else:
                cw[i] = 1/(np.count_nonzero(encoded_y == i)/len(encoded_y))
        if sgan:
            cw[self.num_classes] = 1/0.5
        return cw

    def __train_discrimantor(self, X, y, batch_size, class_weights):

        half_batch_size = int(batch_size / 2)

        # Select a random half batch of images
        idx = np.random.randint(0, X.shape[0], half_batch_size)
        accelerations = X[idx]

        # Sample noise and generate a half batch of new accelerations
        random_labels = to_categorical(np.random.randint(0, self.num_classes, (half_batch_size, 1)), num_classes=self.num_classes + 1)
        noise = np.random.normal(0, 1, (half_batch_size, self.generator_input_length - (self.num_classes + 1)))
        gen_accelerations = self.generator.predict([random_labels, noise])

        labels = y[idx]
        fake_labels = to_categorical(np.full((half_batch_size, 1), self.num_classes), num_classes=self.num_classes + 1)

        # Train the discriminator
        d_loss_real = self.discriminator.train_on_batch(accelerations, labels, class_weight=class_weights)
        d_loss_fake = self.discriminator.train_on_batch(gen_accelerations, fake_labels, class_weight=class_weights)

        return 0.5 * np.add(d_loss_real, d_loss_fake)

    def __train_generator(self, batch_size, class_weights):

        # Sample noise and generate a batch of new accelerations
        noise = np.random.normal(0, 1, (batch_size, self.generator_input_length - (self.num_classes + 1)))
        random_labels = to_categorical(np.random.randint(0, self.num_classes, (batch_size, 1)), num_classes=self.num_classes + 1)

        # Train the generator
        g_loss = self.combined.train_on_batch([random_labels, noise], random_labels, class_weight=class_weights)
        return g_loss

    def __train_baseline(self, X, y, batch_size, class_weights):

        # Select a random half batch of images
        idx = np.random.randint(0, X.shape[0], batch_size)
        accelerations = X[idx]

        labels = y[idx]

        # Train the baseline
        b_loss = self.baseline.train_on_batch(accelerations, labels, class_weight=class_weights)

        return b_loss

    def __print_progress_on_training(self, epoch, d_loss, g_loss, b_loss):
        print("Training epoch %d [D loss: %f, acc: %.2f%%] [G loss: %f] [B loss: %f, acc: %.2f%%]" % (epoch, d_loss[0], 100 * d_loss[1], g_loss, b_loss[0], 100 * b_loss[1]))

    def __print_progress_on_testing(self, d_loss, b_loss):
        print("Testing [D loss: %f, acc: %.2f%%] [B loss: %f, acc: %.2f%%]" % (d_loss[0], 100 * d_loss[1], b_loss[0], 100 * b_loss[1]))

    def __save_acceleration_images(self, X, y, epoch, fake_images_per_exercise=2, real_images_per_exercise=2):

        labels = np.repeat(range(self.num_classes), fake_images_per_exercise).reshape(fake_images_per_exercise * self.num_classes, -1)
        random_labels = to_categorical(labels, num_classes=self.num_classes + 1)
        noise = np.random.normal(0, 1, (fake_images_per_exercise * self.num_classes, self.generator_input_length - (self.num_classes + 1)))
        gen_accelerations = self.generator.predict([random_labels, noise])

        fig, axs = plt.subplots(fake_images_per_exercise + real_images_per_exercise, self.num_classes)
        fig.suptitle("accelerations - epoch %d" % (epoch))
        plt.figtext(0.5, 0.915, self.exercise_description, horizontalalignment='center', size=5)

        for j in range(self.num_classes):
            for i in range(fake_images_per_exercise + real_images_per_exercise):
                if i < fake_images_per_exercise:
                    axs[i, j].set_title("fake " + self.encoder.classes_[j], size=8, y=0.94)
                    axs[i, j].imshow(gen_accelerations[fake_images_per_exercise * j + i, :, :], aspect="auto",
                                     cmap="jet")
                else:
                    axs[i, j].set_title("real " + self.encoder.classes_[j], size=8, y=0.94)
                    hot_encoded_label = to_categorical(j, num_classes=self.num_classes + 1)
                    idx = np.random.choice(
                        [row for row, value in enumerate(y.tolist()) if (value == hot_encoded_label).all()])
                    axs[i, j].imshow(X[idx, :, :], aspect="auto", cmap="jet")
                axs[i, j].axis('off')
                axs[i, j].axvline(2.5, color='w')
                axs[i, j].axvline(5.5, color='w')
                axs[i, j].axvline(8.5, color='w')

        accelerations_folder = self.results_folder_name + "/accelerations/"
        if not os.path.exists(accelerations_folder):
            os.makedirs(accelerations_folder)
        fig.savefig(accelerations_folder + "accelerations_%d.png" % epoch, dpi=200)
        plt.close()

    def __save_accuracy_plot(self, accuracies, epoch, epochs):
        plt.plot(accuracies[:,0], accuracies[:,1], label="discriminator")
        plt.plot(accuracies[:,0], accuracies[:,2], label="baseline")
        plt.suptitle("accuracies")
        plt.ylabel("accuracies on test data")
        plt.xlabel("epochs")
        plt.figtext(0.5, 0.915, self.exercise_description, horizontalalignment='center', size=5)
        axs = plt.gca()
        axs.set_xlim([0,epochs])
        axs.set_ylim([0,1])
        axs.xaxis.set_ticks(np.arange(0, epochs + 1, epochs/10))
        axs.yaxis.set_ticks(np.arange(0,1.001,0.1))
        handles, labels = axs.get_legend_handles_labels()
        axs.legend(handles, labels, loc=4)
        accuracies_folder = self.results_folder_name + "/accuracies/"
        if not os.path.exists(accuracies_folder):
            os.makedirs(accuracies_folder)
        plt.savefig(accuracies_folder + "accuracies_%d.png" % epoch, dpi=200)
        plt.close()

    def __exercise_description(self, y):
        unique_exercises = np.unique(y)
        counts = np.zeros(unique_exercises.shape)
        unique_exercises_with_counts = dict(zip(unique_exercises, counts))
        for i in range(len(y)):
            if i == 0 or y[i] != y[i - 1]:
                unique_exercises_with_counts[y[i]] = unique_exercises_with_counts[y[i]] + 1
        unique_exercises_with_counts_strings = []
        for key, value in unique_exercises_with_counts.items():
            unique_exercises_with_counts_strings.append(key + "s: " + str(int(value)))
        return ", ".join(unique_exercises_with_counts_strings)

    def train(self, X_train, y_train, X_test, y_test, train_individuals, test_individual, epochs=20000, batch_size=100, save_interval=50):
        test_description = "testing data (individual %d): " %(test_individual)
        if len(train_individuals) == 1:
            train_description = "training data (individual %d): " %(train_individuals[0])
        else:
            train_description = "training data (individuals " + ', '.join(str(train_individual) for train_individual in train_individuals) + "): "
        self.exercise_description = train_description + self.__exercise_description(y_train) + "\n" + test_description + self.__exercise_description(y_test)

        X_train, X_test = self.__scale_dataset(X_train, X_test)

        hot_encoded_y_train_sgan = self.__hot_encode_dataset(y_train, num_classes=self.num_classes + 1)
        X_sgan, hot_encoded_y_train_sgan = self.__create_LSTM_dataset(X=X_train, y=hot_encoded_y_train_sgan)

        hot_encoded_y_train_baseline = self.__hot_encode_dataset(y_train, num_classes=self.num_classes)
        X_baseline, hot_encoded_y_train_baseline = self.__create_LSTM_dataset(X=X_train, y=hot_encoded_y_train_baseline)

        hot_encoded_y_test = self.__hot_encode_dataset(y_test, num_classes=self.num_classes)
        X_test, hot_encoded_y_test = self.__create_LSTM_dataset(X=X_test, y=hot_encoded_y_test)

        class_weights_sgan = self.__get_class_weights(y_train)
        class_weights_baseline = self.__get_class_weights(y_train, sgan=False)

        accuracies = np.empty((0,3), float)


        for epoch in range(epochs):

            d_loss = self.__train_discrimantor(X=X_sgan, y=hot_encoded_y_train_sgan, batch_size=batch_size, class_weights=class_weights_sgan)
            g_loss = self.__train_generator(batch_size=batch_size, class_weights=class_weights_baseline)
            b_loss = self.__train_baseline(X=X_baseline, y=hot_encoded_y_train_baseline, batch_size=batch_size, class_weights=class_weights_baseline)

            self.__print_progress_on_training(epoch=epoch, d_loss=d_loss, g_loss=g_loss, b_loss=b_loss)

            if epoch % save_interval == 0:

                d_loss = self.inference_discriminator.evaluate(X_test, hot_encoded_y_test, verbose=False)
                b_loss = self.baseline.evaluate(X_test, hot_encoded_y_test, verbose=False)
                self.__print_progress_on_testing(d_loss, b_loss)
                accuracies = np.append(accuracies, [[epoch, d_loss[1], b_loss[1]]], axis=0)

                self.__save_accuracy_plot(accuracies=accuracies, epoch=epoch, epochs=epochs)
                self.__save_acceleration_images(X=X_sgan, y=hot_encoded_y_train_sgan, epoch=epoch)


def load_data(train_file="data_classes_4_squats_adjusted_individual_added.csv"):
    file_stream = file_io.FileIO(train_file, mode="r")
    dataframe = read_csv(file_stream, header=0)
    dataframe.fillna(0, inplace=True)
    dataset = dataframe.values

    X = dataset[:, [
                       2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
                       # Device: xGravity, yGravity, zGravity, xAcceleration, yAcceleration, zAcceleration, pitch, roll, yaw, xRotationRate, yRotationRate, zRotationRate
                       # 14,15,16,17,                          # Right Hand: rssi, xAcceleration, yAcceleration, zAcceleration
                       # 18,19,20,21,                          # Left Hand: rssi, xAcceleration, yAcceleration, zAcceleration
                       # 22,23,24,25,                          # Right Foot: rssi, xAcceleration, yAcceleration, zAcceleration
                       # 26,27,28,29,                          # Left Foot: rssi, xAcceleration, yAcceleration, zAcceleration
                       # 30,31,32,33,                          # Chest: rssi, xAcceleration, yAcceleration, zAcceleration
                       # 34,35,36,37                           # Belly: rssi, xAcceleration, yAcceleration, zAcceleration
                   ]].astype(float)
    y = dataset[:, 0]  # ExerciseType (Index 1 is ExerciseSubType)

    individuals = dataset[:, 38]
    unique_individuals = np.unique(individuals)

    X = [X[individuals == individual] for individual in unique_individuals]
    y = [y[individuals == individual] for individual in unique_individuals]

    return X, y


def non_shuffling_split(X, y, validation_split):
   i = int((1 - validation_split) * X.shape[0]) + 1
   X_train, X_test = np.split(X, [i])
   y_train, y_test = np.split(y, [i])
   return X_train, X_test, y_train, y_test

def concatenate_individual_data(X_per_individual, y_per_individual):
    X = np.concatenate(X_per_individual, axis=0)
    y = np.concatenate(y_per_individual, axis=0)
    return X, y

def split_on_break(X, y, split):
    i = int(split * X.shape[0]) + 1
    X, _ = np.split(X, [i])
    y, _ = np.split(y, [i])
    while y[-1] != "Break":
        y = y[:-1]
        X = X[:-1]
    return X, y

if __name__ == "__main__":
    X_per_individual, y_per_individual = load_data("data_classes_4_squats_adjusted_individual_added.csv")
    # X_train, X_test, y_train, y_test = non_shuffling_split(X, y, validation_split=0.3)

    #leave one out and gradually reducing training data from other individuals
    for test_individual, (X, y) in enumerate(zip(X_per_individual, y_per_individual)):
        train_individuals = list(range(0, len(X_per_individual)))
        train_individuals.remove(test_individual)
        X_train_per_individual = np.take(X_per_individual, train_individuals)
        y_train_per_individual = np.take(y_per_individual, train_individuals)
        X_train, y_train = concatenate_individual_data(X_train_per_individual, y_train_per_individual)
        X_test = X_per_individual[test_individual]
        y_test = y_per_individual[test_individual]
        for split in [1.0,0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1]:
            X_train_reduced, y_train_reduced = split_on_break(X_train, y_train, split)
            sgan = SGAN()
            sgan.train(X_train=X_train_reduced, y_train=y_train_reduced, X_test=X_test, y_test=y_test, train_individuals=train_individuals, test_individual=test_individual)

    #training and testing on same individual while gradually reducing training data
    for test_individual, (X, y) in enumerate(zip(X_per_individual, y_per_individual)):
        X_train, X_test, y_train, y_test = non_shuffling_split(X, y, validation_split=0.2)
        for split in [1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1]:
            X_train_reduced, y_train_reduced = split_on_break(X_train, y_train, split)
            sgan = SGAN()
            sgan.train(X_train=X_train_reduced, y_train=y_train_reduced, X_test=X_test, y_test=y_test, train_individuals=[test_individual], test_individual=test_individual)