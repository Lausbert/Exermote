//
//  Constants.swift
//  Exermote
//
//  Created by Stephan Lerner on 24.05.17.
//  Copyright © 2016 Stephan. All rights reserved.
//

import Foundation

// MARK: PredictionManager Constants

let PREDICTION_MANAGER_SCALING_COEFFICIENTS: [[Double]] = [[0.5, 0.5, 0.5, 0.07007708, 0.07621951, 0.06131208, 0.31948882,  0.15923567, 0.15923567, 0.04504505, 0.03229974, 0.05347594],
                                                           [0.5, 0.5, 0.5, 0.49544499, 0.5007622, 0.527897, 0.49840256, 0.5, 0.5, 0.54414414, 0.55620155, 0.53475936]
]
let PREDICTION_MANAGER_HOT_ENCODING_ORDER = [PREDICTION_MODEL_EXERCISES.BREAK,
                                             PREDICTION_MODEL_EXERCISES.BURPEE,
                                             PREDICTION_MODEL_EXERCISES.SITUP,
                                             PREDICTION_MODEL_EXERCISES.SQUAT
]
let PREDICTION_MANAGER_TIMESTEPS_MODEL_INPUT: Int = 40
let PREDICTION_MANAGER_GATHER_MOTION_DATA_FREQUENCY: Double = 10.0
let PREDICTION_MANAGER_PREDICT_EXERCISE_FREQUENCY: Double = 5.0

// MARK: Google Cloud Constants

let GOOGLE_CLOUD_PROJECT: String = "exermotemachinelearningengine"
let GOOGLE_CLOUD_MODEL: String = "predictExercise"
let GOOGLE_CLOUD_VERSION: String = "final_1"

// MARK: Prediction Model Constants

enum PREDICTION_MODEL_EXERCISES: String {
    case BREAK = "Break"
    case BURPEE = "Burpee"
    case SITUP = "Situp"
    case SQUAT = "Squat"
}
