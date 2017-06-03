//
//  PredictionVC.swift
//  ExermotePredictionAPI
//
//  Created by Stephan Lerner on 14.05.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit
import AVFoundation
import NVActivityIndicatorView

class PredictionVC: UIViewController, PredictionManagerDelegate, NVActivityIndicatorViewable {
    
    private let predictionManager = PredictionManager()
    private let _speechSynthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        predictionManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        didChangeStatus(predictionManagerState: PredictionManagerState.NotEvaluating)
    }
    
    func didDetectRepetition(exercise: PREDICTION_MODEL_EXERCISES) {
        let speechUtterance = AVSpeechUtterance(string: exercise.rawValue)
        speechUtterance.rate = 0.4
        _speechSynthesizer.speak(speechUtterance)
    }
    
    func didDetectSetBreak() {
        let speechUtterance = AVSpeechUtterance(string: "setBreak")
        speechUtterance.rate = 0.4
        _speechSynthesizer.speak(speechUtterance)
    }
    
    func didChangeStatus(predictionManagerState: PredictionManagerState) {
        let speechUtterance = AVSpeechUtterance(string: predictionManagerState.rawValue)
        speechUtterance.rate = 0.4
        _speechSynthesizer.speak(speechUtterance)
        
        let width = self.view.bounds.width / 5
        let x = self.view.bounds.midX - width / 2
        let y = self.view.bounds.midY - width / 2
        let frame = CGRect(x: x, y: y, width: width, height: width)
        let activityIndicatorView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballScaleRippleMultiple, color: UIColor.white)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
    }
}
