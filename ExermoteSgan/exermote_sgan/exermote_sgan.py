from keras.layers import Input, Dense, Dropout, LSTM, Conv1D, Reshape, BatchNormalization, Conv2D, concatenate
from keras.models import Sequential, Model
from keras.optimizers import Adam
from tensorflow.python.lib.io import file_io
from pandas import read_csv
from sklearn.preprocessing import LabelEncoder, MinMaxScaler
from keras.utils.np_utils import to_categorical
from numpy import array, random, full, add, repeat, inf, mean, std
from matplotlib.pyplot import subplots, close


class SGAN:
    def __init__(self):
        self.num_classes = 4
        self.features = 12
        self.timesteps = 40
        self.timesteps_in_future = 20
        self.nodes_per_layer = 32
        self.filter_length = 3
        self.dropout = 0.2
        self.encoder = LabelEncoder()

        optimizer = Adam(0.0002, 0.5)

        # Build and compile the generator
        self.generator = self.__build_generator()
        self.generator.summary()
        self.generator.compile(loss=["binary_crossentropy"],
                               optimizer=optimizer)

        # Build and compile the discriminator
        self.discriminator = self.__build_discriminator()
        self.discriminator.summary()
        self.discriminator.compile(loss=["categorical_crossentropy"],
                                   optimizer=optimizer,
                                   metrics=["accuracy"])

        # The generator takes noise as input and generates accelerations
        random_labels = Input(shape=(self.num_classes + 1,))
        noise = Input(shape=(100 - (self.num_classes + 1),))
        accelerations = self.generator([random_labels, noise])

        # For the combined model we will only train the generator
        self.discriminator.trainable = False

        # The valid takes generated images as input and determines validity
        scores = self.discriminator(accelerations)

        # The combined model  (stacked generator and discriminator) takes
        # noise as input => generates images => determines validity
        self.combined = Model([random_labels, noise], scores)
        self.combined.compile(loss=["categorical_crossentropy"],
                              optimizer=optimizer)

    def __build_discriminator(self):

        model = Sequential()

        model.add(Conv1D(self.nodes_per_layer, self.filter_length, strides=2, activation="relu",
                         input_shape=(self.timesteps, self.features)))
        model.add(BatchNormalization(momentum=0.8))
        model.add(Conv1D(self.nodes_per_layer, self.filter_length, strides=1, activation="relu"))
        model.add(BatchNormalization(momentum=0.8))
        model.add(LSTM(self.nodes_per_layer, return_sequences=True))
        model.add(BatchNormalization(momentum=0.8))
        model.add(LSTM(self.nodes_per_layer, return_sequences=False))
        model.add(Dropout(self.dropout))

        accelerations = Input(shape=(self.timesteps, self.features), name="accelerations")
        scores = Dense(self.num_classes + 1, activation="softmax", name="scores")(model(accelerations))

        return Model(accelerations, scores)

    def __build_generator(self):

        model = Sequential()

        model.add(Dense(self.timesteps * self.features * self.nodes_per_layer, activation="relu", input_dim=100))
        model.add(Reshape((self.timesteps, self.features, self.nodes_per_layer)))
        model.add(BatchNormalization(momentum=0.8))
        model.add(Conv2D(self.nodes_per_layer, kernel_size=3, padding="same", activation="relu"))
        model.add(BatchNormalization(momentum=0.8))
        model.add(Conv2D(self.nodes_per_layer, kernel_size=3, padding="same", activation="relu"))
        model.add(BatchNormalization(momentum=0.8))
        model.add(Conv2D(1, kernel_size=3, padding="same", activation="tanh"))

        random_labels = Input(shape=(self.num_classes + 1,), name="random_labels")
        noise = Input(shape=(100 - (self.num_classes + 1),), name="noise")
        accelerations = Reshape((self.timesteps, self.features), name="accelerations")(
            model(concatenate([random_labels, noise])))

        return Model([random_labels, noise], accelerations)

    def __create_LSTM_dataset(self, X, y, timesteps, timesteps_in_future):

        X_temp, y_temp = [], []
        for i in range(len(X) - timesteps + 1):
            X_temp.append(X[i:i + timesteps, :])
            y_temp.append(y[i + timesteps - timesteps_in_future - 1, :])
        return array(X_temp), array(y_temp)

    def __scale_dataset(self, X):

        scaler = MinMaxScaler(feature_range=(0, 1))
        X = scaler.fit_transform(X)  # X*scaler.scale_+scaler.min_ (columnwise)
        print('Multiplying each row in X elementwise: {}'.format(scaler.scale_))
        print('Increasing each row in X elementtwise: {}'.format(scaler.min_))
        return X

    def __hot_encode_dataset(self, y):

        self.encoder.fit(y)
        encoded_y = self.encoder.transform(y)
        hot_encoded_y = to_categorical(encoded_y, num_classes=self.num_classes + 1)
        return hot_encoded_y

    def __get_class_weights(self, batch_size):

        # Class weights:
        # To balance the difference in occurences of digit class labels.
        # 50% of labels that the discriminator trains on are 'fake'.
        # Weight = 1 / frequency
        half_batch_size = int(batch_size / 2)
        cw = {i: self.num_classes / half_batch_size for i in range(self.num_classes)}
        cw[self.num_classes] = 1 / half_batch_size

    def __train_discrimantor(self, X, y, batch_size, class_weights):

        half_batch_size = int(batch_size / 2)

        # Select a random half batch of images
        idx = random.randint(0, X.shape[0], half_batch_size)
        accelerations = X[idx]

        # Sample noise and generate a half batch of new accelerations
        random_labels = to_categorical(random.randint(0, self.num_classes, (half_batch_size, 1)),
                                       num_classes=self.num_classes + 1)
        noise = random.normal(0, 1, (half_batch_size, 100 - (self.num_classes + 1)))
        gen_accelerations = self.generator.predict([random_labels, noise])

        print("Generator - Mean:" + str(mean(gen_accelerations)))

        labels = y[idx]
        fake_labels = to_categorical(full((half_batch_size, 1), self.num_classes), num_classes=self.num_classes + 1)

        # Train the discriminator
        d_loss_real = self.discriminator.train_on_batch(accelerations, labels, class_weight=class_weights)
        d_loss_fake = self.discriminator.train_on_batch(gen_accelerations, fake_labels, class_weight=class_weights)
        return 0.5 * add(d_loss_real, d_loss_fake)

    def __train_generator(self, batch_size, class_weights):

        # Sample noise and generate a batch of new accelerations
        noise = random.normal(0, 1, (batch_size, 100 - (self.num_classes + 1)))
        random_labels = to_categorical(random.randint(0, self.num_classes, (batch_size, 1)),
                                       num_classes=self.num_classes + 1)

        # Train the generator
        g_loss = self.combined.train_on_batch([random_labels, noise], random_labels, class_weight=class_weights)
        return g_loss

    def __print_progress(self, epoch, d_loss, g_loss):
        print("%d [D loss: %f, acc: %.2f%%] [G loss: %f]" % (epoch, d_loss[0], 100 * d_loss[1], g_loss))

    def __save_imgs(self, X, y, epoch, fake_images_per_exercise, real_images_per_exercise):

        labels = repeat(range(self.num_classes), fake_images_per_exercise).reshape(fake_images_per_exercise * self.num_classes, -1)
        random_labels = to_categorical(labels, num_classes=self.num_classes + 1)
        noise = random.normal(0, 1, (fake_images_per_exercise * self.num_classes, 100 - (self.num_classes + 1)))

        gen_accelerations = self.generator.predict([random_labels, noise])

        fig, axs = subplots(fake_images_per_exercise + real_images_per_exercise, self.num_classes)

        for j in range(self.num_classes):
            for i in range(fake_images_per_exercise + real_images_per_exercise):
                if i < fake_images_per_exercise:
                    axs[i, j].set_title("fake " + self.encoder.classes_[j], size=8, y=0.94)
                    axs[i, j].imshow(gen_accelerations[fake_images_per_exercise * j + i, :, :], aspect="auto", cmap="jet")
                else:
                    axs[i, j].set_title("real " + self.encoder.classes_[j], size=8, y=0.94)
                    hot_encoded_label = to_categorical(j, num_classes=self.num_classes + 1)
                    idx = random.choice([row for row, value in enumerate(y.tolist()) if (value == hot_encoded_label).all()])
                    axs[i, j].imshow(X[idx, :, :], aspect="auto", cmap="jet")
                axs[i, j].axis('off')
                axs[i, j].axvline(2.5, color='w')
                axs[i, j].axvline(5.5, color='w')
                axs[i, j].axvline(8.5, color='w')

        fig.savefig("accelerations/accelerations_%d.png" % epoch)
        close()

    def train(self, X_train, y_train, epochs, batch_size=100, save_interval=50):

        X = self.__scale_dataset(X_train)
        hot_encoded_y = self.__hot_encode_dataset(y_train)
        X, hot_encoded_y = self.__create_LSTM_dataset(X=X, y=hot_encoded_y, timesteps=self.timesteps, timesteps_in_future=self.timesteps_in_future)

        class_weights = self.__get_class_weights(batch_size=batch_size)

        d_loss, g_loss = [inf], inf

        for epoch in range(epochs):

            if d_loss[0] >= g_loss:
                d_loss = self.__train_discrimantor(X=X, y=hot_encoded_y, batch_size=batch_size, class_weights=class_weights)
            else:
                g_loss = self.__train_generator(batch_size=batch_size, class_weights=class_weights)

            self.__print_progress(epoch=epoch, d_loss=d_loss, g_loss=g_loss)

            if epoch % save_interval == 0:
                self.__save_imgs(X=X, y=hot_encoded_y, epoch=epoch, fake_images_per_exercise=2, real_images_per_exercise=2)

def load_data(train_file="data_classes_4_squats_adjusted.csv"):

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

    return X, y


if __name__ == "__main__":

    sgan = SGAN()
    X, y = load_data("data_classes_4_squats_adjusted.csv")
    sgan.train(X_train=X, y_train=y, epochs=10001, batch_size=100, save_interval=50)
