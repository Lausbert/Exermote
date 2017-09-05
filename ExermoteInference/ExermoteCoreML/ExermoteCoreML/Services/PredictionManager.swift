//
//  PredictionManager.swift
//  ExermoteCoreML
//
//  Created by Stephan Lerner on 09.06.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import Foundation
import CoreML
import UIKit

class PredictionManager {
    
    private let _predictionModel = Exermote()
    private let _motionManager = MotionManager()
    private var _currentScaledMotionArrays: [[Double]] = []
    private var _isEvaluating: Bool?
    private var _currentEvaluationStep: EvaluationStep?
    private var _lastEvaluationStep: EvaluationStep?
    private var _currentExercise: PREDICTION_MODEL_EXERCISES?
    private var _evalutationStepsSinceLastRepetition: Int?
    private var _predictionManagerState: PredictionManagerState
    private weak var _delegate: PredictionManagerDelegate?
    
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
    
    init(delegate: PredictionManagerDelegate) {
        self._delegate = delegate
        self._predictionManagerState = PredictionManagerState.NotEvaluating
        changePredictionManagerState(predictionManagerState: _predictionManagerState)
    }
    
    func startPrediction() {
        changePredictionManagerState(predictionManagerState: PredictionManagerState.Initializing)
        _gatherMotionDataTimer = Timer.scheduledTimer(timeInterval: 1.0/PREDICTION_MANAGER_GATHER_MOTION_DATA_FREQUENCY, target: self, selector: #selector(gatherMotionData), userInfo: nil, repeats: true)
        _predictExerciseTimer = Timer.scheduledTimer(timeInterval: 1.0/PREDICTION_MANAGER_PREDICT_EXERCISE_FREQUENCY, target: self, selector: #selector(predictExercise), userInfo: nil, repeats: true)
        _isEvaluating = false
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func stopPrediction() {
        _gatherMotionDataTimer = nil
        _predictExerciseTimer = nil
        _currentScaledMotionArrays = []
        _currentEvaluationStep = nil
        _lastEvaluationStep = nil
        _currentExercise = nil
        _isEvaluating = nil
        _evalutationStepsSinceLastRepetition = nil
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
        
        if _predictionManagerState == PredictionManagerState.Initializing {changePredictionManagerState(predictionManagerState: PredictionManagerState.Evaluating)}
        
        let evaluationStep = EvaluationStep()
        if _currentEvaluationStep == nil {
            _currentEvaluationStep = evaluationStep
            _lastEvaluationStep = evaluationStep
        } else {
            _lastEvaluationStep?.next = evaluationStep
            _lastEvaluationStep = evaluationStep
        }
        
        DispatchQueue.global(qos: .utility).async {
            self.makePredictionRequest(evaluationStep: evaluationStep)
        }
        
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
    
    // Note: If this piece of code did help you to achieve your goal, please upvote my solution under:
    // https://stackoverflow.com/questions/44460532/how-to-initialize-a-mlmultiarray-in-coreml/44462908#44462908
    // Thank you so much :)
    func makePredictionRequest(evaluationStep: EvaluationStep) {
        let data = _currentScaledMotionArrays.reduce([], +) //result is of type [Double] with 480 elements
        do {
            let accelerationsMultiArray = try MLMultiArray(shape:[40,1,12], dataType:MLMultiArrayDataType.double)
            for (index, element) in data.enumerated() {
                accelerationsMultiArray[index] = NSNumber(value: element)
            }
            let hiddenStatesMultiArray = try MLMultiArray(shape: [32], dataType: MLMultiArrayDataType.double)
            for index in 0..<32 {
                hiddenStatesMultiArray[index] = NSNumber(integerLiteral: 0)
            }
            let input = ExermoteInput(accelerations: accelerationsMultiArray, lstm_1_h_in: hiddenStatesMultiArray, lstm_1_c_in: hiddenStatesMultiArray, lstm_2_h_in: hiddenStatesMultiArray, lstm_2_c_in: hiddenStatesMultiArray)
            let predictionOutput = try _predictionModel.prediction(input: input)
            if let scores = [predictionOutput.scores[0], predictionOutput.scores[1], predictionOutput.scores[2], predictionOutput.scores[3]] as? [Double] {
                evaluationStep.exercise = decodePredictionRequest(scores: scores)
            } else {
                print("Could not cast predictionOutput.scores to [Double].")
            }
        }
        catch {
            print(error.localizedDescription)
            self.stopPrediction()
        }
    }
    
    func decodePredictionRequest(scores: [Double]) -> PREDICTION_MODEL_EXERCISES {
        if let maximumScore = scores.max() {
            if let maximumScoreIndex = scores.index(of: maximumScore) {
                return PREDICTION_MANAGER_HOT_ENCODING_ORDER[maximumScoreIndex]
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
            print(currentExercise)
            if currentExercise == _currentExercise {
                if currentExercise == PREDICTION_MODEL_EXERCISES.BREAK {
                    if var steps = _evalutationStepsSinceLastRepetition {
                        steps += 1
                        print(steps)
                        _evalutationStepsSinceLastRepetition = steps
                        if steps == PREDICTION_MANAGER_STEPS_UNTIL_SET_BREAK {
                            DispatchQueue.main.async {
                                self._delegate?.didDetectSetBreak()
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
                            self._delegate?.didDetectRepetition(exercise: currentExercise)
                        }
                    }
                case PREDICTION_MODEL_EXERCISES.SQUAT:
                    guard let consecutiveExercisePrediction = exercisePredictedForConsecutiveSteps(evaluationStep: _currentEvaluationStep, steps: PREDICTION_MANAGER_CONSECUTIVE_SQUAT_PREDICTIONS_UNTIL_COUNT) else {return}
                    if consecutiveExercisePrediction {
                        DispatchQueue.main.async {
                            self._delegate?.didDetectRepetition(exercise: currentExercise)
                        }
                    }
                case PREDICTION_MODEL_EXERCISES.SITUP:
                    guard let consecutiveExercisePrediction = exercisePredictedForConsecutiveSteps(evaluationStep: _currentEvaluationStep, steps: PREDICTION_MANAGER_CONSECUTIVE_SITUP_PREDICTIONS_UNTIL_COUNT) else {return}
                    if consecutiveExercisePrediction {
                        DispatchQueue.main.async {
                            self._delegate?.didDetectRepetition(exercise: currentExercise)
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
        _delegate?.didChangeStatus(predictionManagerState: predictionManagerState)
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


/// It takes soe time until enough acceleration data points for prediction are collected.
enum PredictionManagerState: String {
    case NotEvaluating = "NotEvaluating"
    case Evaluating = "Evaluating"
    case Initializing = "Initializing"
}
