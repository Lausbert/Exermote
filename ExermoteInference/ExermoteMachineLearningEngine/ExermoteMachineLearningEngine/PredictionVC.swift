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

@objcMembers
class PredictionVC: UIViewController, PredictionManagerDelegate, NVActivityIndicatorViewable {
    
    @IBOutlet weak var controlBtn: CustomButton!
    
    private let _predictionManager = PredictionManager()
    private let _speechSynthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _predictionManager.delegate = self
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
        animateControlBtn(predictionManagerState: predictionManagerState)
    }
    
    @IBAction func didTapControlBtn(_ sender: UIButton) {
        switch _predictionManager.predictionManageState {
        case PredictionManagerState.NotEvaluating:
            _predictionManager.startPrediction()
        case PredictionManagerState.Initializing:
            _predictionManager.stopPrediction()
        case PredictionManagerState.Evaluating:
            _predictionManager.stopPrediction()
        }
    }
    
    func animateControlBtn(predictionManagerState: PredictionManagerState) {
        
        var newColor = UIColor.clear.cgColor
        
        switch predictionManagerState {
        case PredictionManagerState.NotEvaluating:
            newColor = COLOR_NOT_EVALUATING
        case PredictionManagerState.Initializing:
            newColor = COLOR_INITIALIZING
        case PredictionManagerState.Evaluating:
            newColor = COLOR_EVALUATING
        }
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = 0.5
        
        let colourAnim = CABasicAnimation(keyPath: "backgroundColor")
        colourAnim.fromValue = controlBtn.backgroundColor?.cgColor
        colourAnim.toValue = newColor
        
        groupAnimation.animations = [colourAnim]
        controlBtn.layer.add(groupAnimation, forKey: nil)
        
        controlBtn.layer.backgroundColor = newColor
    }
}
