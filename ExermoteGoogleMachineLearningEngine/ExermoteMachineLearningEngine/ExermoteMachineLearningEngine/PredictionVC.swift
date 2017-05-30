//
//  PredictionVC.swift
//  ExermotePredictionAPI
//
//  Created by Stephan Lerner on 14.05.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit
import AVFoundation

class PredictionVC: UIViewController, PredictionManagerDelegate {
    
    @IBOutlet weak var test: UILabel!
    private let predictionManager = PredictionManager()
    private let _speechSynthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        predictionManager.delegate = self
        predictionManager.startPrediction()
    }
    
    func didDetectRepetition(exercise: PREDICTION_MODEL_EXERCISES) {
        if exercise != PREDICTION_MODEL_EXERCISES.BREAK {
            let speechUtterance = AVSpeechUtterance(string: exercise.rawValue)
            speechUtterance.rate = 0.4
            _speechSynthesizer.speak(speechUtterance)
        }
    }
    
    func didDetectSetBreak() {
        let speechUtterance = AVSpeechUtterance(string: "setBreak")
        speechUtterance.rate = 0.4
        _speechSynthesizer.speak(speechUtterance)
    }
    
    func test(exercise: PREDICTION_MODEL_EXERCISES) {
        test.text = exercise.rawValue
    }
}
