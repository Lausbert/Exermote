//
//  PredictionManager.swift
//  ExermoteMachineLearningEngine
//
//  Created by Stephan Lerner on 25.05.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import Foundation

class PredictionManager {
    
    var delegate: PredictionManagerDelegate?
    
    private let _motionManager = MotionManager()
    private var _currentScaledMotionArrays: [[Double]] = []
    private var _currentEvaluationStep: EvaluationStep?
    private var _lastEvaluationStep: EvaluationStep?
    private var _currentExercise: PREDICTION_MODEL_EXERCISES?
    private var _evalutationStepsSinceLastRepetition: Int?
    
    private var _gatherMotionDataTimer:Timer? = nil {
        willSet {
            _gatherMotionDataTimer?.invalidate()
        }
    }
    private var _predictExerciseTimer:Timer? = nil {
        willSet {
            _predictExerciseTimer?.invalidate()
        }
    }
    
    func startPrediction() {
        _gatherMotionDataTimer = Timer.scheduledTimer(timeInterval: 1.0/PREDICTION_MANAGER_GATHER_MOTION_DATA_FREQUENCY, target: self, selector: #selector(gatherMotionData), userInfo: nil, repeats: true)
        _predictExerciseTimer = Timer.scheduledTimer(timeInterval: 1.0/PREDICTION_MANAGER_PREDICT_EXERCISE_FREQUENCY, target: self, selector: #selector(predictExercise), userInfo: nil, repeats: true)
    }
    
    func stopPrediction() {
        _gatherMotionDataTimer = nil
        _predictExerciseTimer = nil
        _currentEvaluationStep = nil
        _lastEvaluationStep = nil
    }
    
    @objc private func gatherMotionData() {
        let currentRawMotionArray = _motionManager.currentRawMotionArray
        let currentScaledMotionArray = scaleRawMotionArray(rawMotionArray: currentRawMotionArray)
        var updatedScaledMotionArrays = _currentScaledMotionArrays
        updatedScaledMotionArrays.append(currentScaledMotionArray)
        if updatedScaledMotionArrays.count > PREDICTION_MANAGER_TIMESTEPS_MODEL_INPUT {updatedScaledMotionArrays.remove(at: 0)}
        _currentScaledMotionArrays = updatedScaledMotionArrays
    }
    
    @objc private func predictExercise() {
        
        guard _currentScaledMotionArrays.count == PREDICTION_MANAGER_TIMESTEPS_MODEL_INPUT else {return}
        
        let evaluationStep = EvaluationStep()
        if _currentEvaluationStep == nil {
            _currentEvaluationStep = evaluationStep
            _lastEvaluationStep = evaluationStep
        } else {
            _lastEvaluationStep?.next = evaluationStep
            _lastEvaluationStep = evaluationStep
        }
        makePredictionRequest(evaluationStep: evaluationStep)
        tryEvaluation()
    }
    
    private func scaleRawMotionArray(rawMotionArray: [Double]) -> [Double] {
        let scaledMotionArray = rawMotionArray.enumerated().map {$0.element * PREDICTION_MANAGER_SCALING_COEFFICIENTS[0][$0.offset] + PREDICTION_MANAGER_SCALING_COEFFICIENTS[1][$0.offset]}
        return scaledMotionArray
    }
    
    func makePredictionRequest(evaluationStep: EvaluationStep) {
        
        var accessToken: String?
        
        GIDSignIn.sharedInstance().currentUser.authentication.getTokensWithHandler { (authentication, error) in
            
            if let err = error {
                print(err)
            } else {
                if let auth = authentication {
                    accessToken = auth.accessToken
                }
            }
        }
        
        if let accTok = accessToken {
            
            let parameters = [
                "instances": [
                    _currentScaledMotionArrays
                ]
            ]
            
            let url = NSURL(string: "https://ml.googleapis.com/v1/projects/\(GOOGLE_CLOUD_PROJECT)/models/\(GOOGLE_CLOUD_MODEL)/versions/\(GOOGLE_CLOUD_VERSION):predict")
            
            let session = URLSession.shared
            
            let request = NSMutableURLRequest(url: url! as URL)
            request.httpMethod = "POST" //set http method as POST
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                
            } catch let error {
                self.stopPrediction()
                print(error.localizedDescription)
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Bearer \(accTok)", forHTTPHeaderField: "Authorization")
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                
                guard error == nil else {
                    self.stopPrediction()
                    return
                }
                
                guard let data = data else {
                    self.stopPrediction()
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let exercise = self.decodePredictionRequest(json: json)
                        evaluationStep.exercise = exercise
                    }
                    
                } catch let error {
                    self.stopPrediction()
                    print(error.localizedDescription)
                }
                
            })
            
            task.resume()
        }
    }
    
    func decodePredictionRequest(json: [String: Any]) -> PREDICTION_MODEL_EXERCISES {
        if let output = json["predictions"] as? [[String:Any]], !output.isEmpty {
            if let scores = output[0]["outputs"] as? [Double] {
                if let maximumScore = scores.max() {
                    if let maximumScoreIndex = scores.index(of: maximumScore) {
                        return PREDICTION_MANAGER_HOT_ENCODING_ORDER[maximumScoreIndex]
                    }
                }
            }
        }
        return PREDICTION_MANAGER_HOT_ENCODING_ORDER[4]
    }
    
    func tryEvaluation() {
        while _currentEvaluationStep?.next != nil {
            
            guard let currentExercise = _currentEvaluationStep?.exercise else {return}
            
            if currentExercise == _currentExercise {
                _currentEvaluationStep = _currentEvaluationStep?.next
                if currentExercise == PREDICTION_MODEL_EXERCISES.BREAK {
                    if var steps = _evalutationStepsSinceLastRepetition {
                        steps += 1
                        _evalutationStepsSinceLastRepetition = steps
                        if steps == PREDICTION_MANAGER_STEPS_UNTIL_SET_BREAK {
                            delegate?.didDetectSetBreak()
                        }
                    }
                }
                return
            }
            
            guard let currentNextExercise = _currentEvaluationStep?.next?.exercise else {return}
            
            if currentExercise == currentNextExercise { // Only count repetitions if regarding exercise was predicted for two consecutive evalution stepts to reduce miscountings
                _currentEvaluationStep = _currentEvaluationStep?.next
                _currentExercise = currentExercise
                delegate?.didDetectRepetition(exercise: currentExercise)
                if currentExercise == PREDICTION_MODEL_EXERCISES.BREAK {
                    _evalutationStepsSinceLastRepetition = 0
                }
                return
            }
        }
    }
}

/// Every requested prediction is stored in an ordered linked-list like EvaluationStep, so these steps could be evaluated in the correct order and aren't whirled around through latency spikes.
class EvaluationStep {
    var exercise: PREDICTION_MODEL_EXERCISES?
    var next: EvaluationStep?
    var birth: String
    
    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd HH-mm-ss-SSS"
        birth = dateFormatter.string(from: Date())
    }
}
