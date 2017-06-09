//
//  PredictionVC.swift
//  ExermoteCoreML
//
//  Created by Stephan Lerner on 09.06.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit
import AVFoundation
import NVActivityIndicatorView

@objcMembers
class PredictionVC: UIViewController, PredictionManagerDelegate, NVActivityIndicatorViewable {
    
    private var _activityIndicatorView: NVActivityIndicatorView?
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
        
        if let activityIndicatorView = _activityIndicatorView {
            switch predictionManagerState {
            case PredictionManagerState.NotEvaluating:
                activityIndicatorView.stopAnimating()
                activityIndicatorView.isHidden = false
                activityIndicatorView.backgroundColor = UIColor.white
            case PredictionManagerState.Initializing:
                activityIndicatorView.isHidden = true
                activityIndicatorView.backgroundColor = UIColor.clear
                activityIndicatorView.type = NVActivityIndicatorType.ballScaleRippleMultiple
                activityIndicatorView.startAnimating()
            case PredictionManagerState.Evaluating: break
                //UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: { _ in
                //    view.isHidden = true
                //}, completion: nil)
            }
        } else {
            let width = self.view.bounds.width / 5
            let x = self.view.bounds.midX - width / 2
            let y = self.view.bounds.midY - width / 2
            let frame = CGRect(x: x, y: y, width: width, height: width)
            let activityIndicatorView = NVActivityIndicatorView(frame: frame)
            activityIndicatorView.isHidden = false
            activityIndicatorView.backgroundColor = UIColor.white
            activityIndicatorView.layer.cornerRadius = activityIndicatorView.frame.width / 2
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapActivityIndicatorView))
            activityIndicatorView.addGestureRecognizer(tapGesture)
            self.view.addSubview(activityIndicatorView)
            _activityIndicatorView = activityIndicatorView
        }
    }
    
    func didTapActivityIndicatorView() {
        switch _predictionManager.predictionManageState {
        case PredictionManagerState.NotEvaluating:
            _predictionManager.startPrediction()
        case PredictionManagerState.Initializing:
            _predictionManager.stopPrediction()
        case PredictionManagerState.Evaluating:
            _predictionManager.stopPrediction()
        }
    }
}

