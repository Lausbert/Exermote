//
//  PredictionVC.swift
//  ExermotePredictionAPI
//
//  Created by Stephan Lerner on 14.05.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit

class PredictionVC: UIViewController, PredictionManagerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let predictionManager = PredictionManager()
        predictionManager.delegate = self
        predictionManager.startPrediction()
    }
    
    func didDetectRepetition(exercise: PREDICTION_MODEL_EXERCISES) {
        print(exercise.rawValue)
    }
    
    func didDetectSetBreak() {
        print("DING DING DING!!! SET BREAK!!!")
    }
}
