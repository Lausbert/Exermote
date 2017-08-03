//
//  PredictionManagerDelegate.swift
//  ExermoteCoreML
//
//  Created by Stephan Lerner on 09.06.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import Foundation

protocol PredictionManagerDelegate: class {
    func didDetectRepetition(exercise: PREDICTION_MODEL_EXERCISES)
    func didDetectSetBreak()
    func didChangeStatus(predictionManagerState: PredictionManagerState)
}
