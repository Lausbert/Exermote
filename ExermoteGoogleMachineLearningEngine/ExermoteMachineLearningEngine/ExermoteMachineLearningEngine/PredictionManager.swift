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
    private var _isEvaluating: Bool?
    private var _currentEvaluationStep: EvaluationStep?
    private var _lastEvaluationStep: EvaluationStep?
    private var _currentExercise: PREDICTION_MODEL_EXERCISES?
    private var _evalutationStepsSinceLastRepetition: Int?
    private var _predictionManagerState: PredictionManagerState
    
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
    
    var predictionManageState: PredictionManagerState {
        return _predictionManagerState
    }
    
    init() {
        _predictionManagerState = PredictionManagerState.NotEvaluating
    }
    
    func startPrediction() {
        _gatherMotionDataTimer = Timer.scheduledTimer(timeInterval: 1.0/PREDICTION_MANAGER_GATHER_MOTION_DATA_FREQUENCY, target: self, selector: #selector(gatherMotionData), userInfo: nil, repeats: true)
        _predictExerciseTimer = Timer.scheduledTimer(timeInterval: 1.0/PREDICTION_MANAGER_PREDICT_EXERCISE_FREQUENCY, target: self, selector: #selector(predictExercise), userInfo: nil, repeats: true)
        _isEvaluating = false
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func stopPrediction() {
        _gatherMotionDataTimer = nil
        _predictExerciseTimer = nil
        _currentEvaluationStep = nil
        _lastEvaluationStep = nil
        _isEvaluating = nil
        changePredictionManagerState(predictionManagerState: PredictionManagerState.NotEvaluating)
        UIApplication.shared.isIdleTimerDisabled = false
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
        
        if _predictionManagerState == PredictionManagerState.Initializing {
            return
        } else if _predictionManagerState == PredictionManagerState.NotEvaluating {
            changePredictionManagerState(predictionManagerState: PredictionManagerState.Initializing)
        }
        
        let evaluationStep = EvaluationStep()
        if _currentEvaluationStep == nil {
            _currentEvaluationStep = evaluationStep
            _lastEvaluationStep = evaluationStep
        } else {
            _lastEvaluationStep?.next = evaluationStep
            _lastEvaluationStep = evaluationStep
        }
        makePredictionRequest(evaluationStep: evaluationStep)
        
        if let isEvaluating = _isEvaluating  {
            if !isEvaluating {
                tryEvaluation()
            }
        }
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
                evaluationStep.exercise = PREDICTION_MODEL_EXERCISES.BREAK
                print(error.localizedDescription)
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Bearer \(accTok)", forHTTPHeaderField: "Authorization")
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                
                if self._predictionManagerState == PredictionManagerState.Initializing {
                    self.changePredictionManagerState(predictionManagerState: PredictionManagerState.Evaluating)
                }
                
                guard error == nil else {
                    evaluationStep.exercise = PREDICTION_MODEL_EXERCISES.BREAK
                    return
                }
                
                guard let data = data else {
                    evaluationStep.exercise = PREDICTION_MODEL_EXERCISES.BREAK
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let exercise = self.decodePredictionRequest(json: json)
                        evaluationStep.exercise = exercise
                    }
                    
                } catch let error {
                    evaluationStep.exercise = PREDICTION_MODEL_EXERCISES.BREAK
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
        return PREDICTION_MODEL_EXERCISES.BREAK
    }
    
    func tryEvaluation() {
        
        _isEvaluating = true
        
        defer {
            _isEvaluating = false
        }
        
        while _currentEvaluationStep?.next != nil {
            
            guard let currentExercise = _currentEvaluationStep?.exercise else {return}
            
            if currentExercise == _currentExercise {
                if currentExercise == PREDICTION_MODEL_EXERCISES.BREAK {
                    if var steps = _evalutationStepsSinceLastRepetition {
                        steps += 1
                        _evalutationStepsSinceLastRepetition = steps
                        if steps == PREDICTION_MANAGER_STEPS_UNTIL_SET_BREAK {
                            DispatchQueue.main.async {
                                self.delegate?.didDetectSetBreak()
                            }
                        }
                    }
                }
            } else {
                switch currentExercise {
                    case PREDICTION_MODEL_EXERCISES.BREAK:
                        guard let consecutiveBreakPrediction = exercisePredictedForConsecutiveSteps(evaluationStep: _currentEvaluationStep, steps: PREDICTION_MANAGER_CONSECUTIVE_BREAK_PREDICTIONS_UNTIL_COUNT) else {return}
                        if consecutiveBreakPrediction {
                            _evalutationStepsSinceLastRepetition = 0
                        }
                    case PREDICTION_MODEL_EXERCISES.BURPEE:
                        guard let consecutiveExercisePrediction = exercisePredictedForConsecutiveSteps(evaluationStep: _currentEvaluationStep, steps: PREDICTION_MANAGER_CONSECUTIVE_BURPEE_PREDICTIONS_UNTIL_COUNT) else {return}
                        if consecutiveExercisePrediction {
                            DispatchQueue.main.async {
                                self.delegate?.didDetectRepetition(exercise: currentExercise)
                            }
                        }
                    case PREDICTION_MODEL_EXERCISES.SQUAT:
                        guard let consecutiveExercisePrediction = exercisePredictedForConsecutiveSteps(evaluationStep: _currentEvaluationStep, steps: PREDICTION_MANAGER_CONSECUTIVE_SQUAT_PREDICTIONS_UNTIL_COUNT) else {return}
                        if consecutiveExercisePrediction {
                            DispatchQueue.main.async {
                                self.delegate?.didDetectRepetition(exercise: currentExercise)
                            }
                        }
                    case PREDICTION_MODEL_EXERCISES.SITUP:
                        guard let consecutiveExercisePrediction = exercisePredictedForConsecutiveSteps(evaluationStep: _currentEvaluationStep, steps: PREDICTION_MANAGER_CONSECUTIVE_SITUP_PREDICTIONS_UNTIL_COUNT) else {return}
                        if consecutiveExercisePrediction {
                            DispatchQueue.main.async {
                                self.delegate?.didDetectRepetition(exercise: currentExercise)
                            }
                        }
                }
            }
            
            _currentExercise = currentExercise
            _currentEvaluationStep = _currentEvaluationStep?.next
        }
    }
    
    func exercisePredictedForConsecutiveSteps(evaluationStep: EvaluationStep?, steps: Int) -> Bool? {
        if steps <= 0 {return true}
        guard let exercise = evaluationStep?.exercise, let nextExercise = evaluationStep?.next?.exercise else {return nil}
        if exercise != nextExercise {return false}
        return exercisePredictedForConsecutiveSteps(evaluationStep: evaluationStep?.next ,steps: steps-1)
    }
    
    func changePredictionManagerState(predictionManagerState: PredictionManagerState?) {
        guard let predictionManagerState = predictionManagerState else {return}
        _predictionManagerState = predictionManagerState
        delegate?.didChangeStatus(predictionManagerState: predictionManagerState)
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


/// The first prediction request to Google Cloud ML Engine takes up tens of seconds, until the nodes are allocated. After that the model is in a ready state as long as you have a steady stream of requests. 
enum PredictionManagerState: String {
    case NotEvaluating = "NotEvaluating"
    case Evaluating = "Evaluating"
    case Initializing = "Initializing"
}
