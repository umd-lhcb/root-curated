#!/usr/bin/env python

import numpy as np
import tensorflow as tf


# Dummy data: y = 2x - 1
x_train = np.array([[0.0], [1.0], [2.0], [3.0]], dtype=float)
y_train = np.array([[-1.0], [1.0], [3.0], [5.0]], dtype=float)

model = tf.keras.Sequential([
    tf.keras.layers.Dense(units=1, input_shape=[1])
])

model.compile(optimizer='sgd', loss='mean_squared_error')
model.fit(x_train, y_train, epochs=5)

print("\nPrediction for x = 4.0:", model.predict(np.array([[4.0]], dtype=float)))
