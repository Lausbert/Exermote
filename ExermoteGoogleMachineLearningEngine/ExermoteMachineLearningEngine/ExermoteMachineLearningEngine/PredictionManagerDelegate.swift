//
//  PredictionManagerDelegate.swift
//  ExermoteMachineLearningEngine
//
//  Created by Stephan Lerner on 30.05.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import Foundation

protocol PredictionManagerDelegate {
    func didDetectRepetition(exercise: PREDICTION_MODEL_EXERCISES)
    func didDetectSetBreak()
}
