//
//  MetaData.swift
//  Exermote
//
//  Created by Stephan Lerner on 05.03.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import Foundation

class MetaData: Equatable {
    
    private var _exerciseType: String?
    private var _exerciseSubType: String?
    
    init(exerciseType: String?, exerciseSubType: String?) {
        _exerciseType = exerciseType
        _exerciseSubType = exerciseSubType
    }
    
    var exerciseType: String {
        guard let result = _exerciseType else {return "Break"}
        return result
    }
    
    var exerciseSubType: String {
        guard let result = _exerciseSubType else {return "Break"}
        return result
    }
    
    var stringDictionary: Dictionary<String,String> {
        
        var dict = [String : String]()
        
        dict[USER_DEFAULTS_RECORDED_DATA_META_DATA[0]] = exerciseType
        dict[USER_DEFAULTS_RECORDED_DATA_META_DATA[1]] = exerciseSubType
        
        return dict
    }
    
    static func ==(first: MetaData, second: MetaData) -> Bool {
        return first._exerciseType == second._exerciseType && first._exerciseSubType == second._exerciseSubType
    }
    
    class func generateMetaDataForWorkout() -> [MetaData] {
        
        var metaDataArray: [MetaData] = []
        
        var exercises: [Exercise] = []
        
        if let data = UserDefaults.standard.data(forKey: USER_DEFAULTS_EXERCISES) {
            exercises =  NSKeyedUnarchiver.unarchiveObject(with: data) as! [Exercise]
        }
        
        let recordingFrequency = UserDefaults.standard.integer(forKey: USER_DEFAULTS_RECORDING_FREQUENCY)
        let totalDurationInMinutes = UserDefaults.standard.integer(forKey: USER_DEFAULTS_RECORDING_DURATION)
        var remainingRecordingDurationInTicks = recordingFrequency*totalDurationInMinutes*60
        
        workoutLoop: while remainingRecordingDurationInTicks > 0 {
            
            if exercises.isEmpty {break workoutLoop}
            
            let exercise = exercises.randomItem()
            let exerciseType = exercise.name
            let repetitions = [Int](1...10).randomItem()
            let firstHalfDurationInTicks = Int(exercise.firstHalfDuration * Double(recordingFrequency))
            let secondHalfDurationInTicks = Int(exercise.secondHalfDuration * Double(recordingFrequency))
            let repetitionBreakDurationInTicks = Int(exercise.repetitionBreakDuration * Double(recordingFrequency))
            let setBreakDurationInTicks = Int(exercise.setBreakDuration * Double(recordingFrequency))
            let repetitionDurationInTicks = firstHalfDurationInTicks + secondHalfDurationInTicks + repetitionBreakDurationInTicks
            
            for _ in 1...repetitions {
                
                if remainingRecordingDurationInTicks < repetitionDurationInTicks {break workoutLoop}
                
                for _ in 1...repetitionBreakDurationInTicks {
                    metaDataArray.append(MetaData(exerciseType: nil, exerciseSubType: nil))
                    remainingRecordingDurationInTicks -= 1
                }
                
                for _ in 1...firstHalfDurationInTicks {
                    metaDataArray.append(MetaData(exerciseType: exerciseType, exerciseSubType: "firstHalf"))
                    remainingRecordingDurationInTicks -= 1
                }
                
                for _ in 1...secondHalfDurationInTicks {
                    metaDataArray.append(MetaData(exerciseType: exerciseType, exerciseSubType: "secondHalf"))
                    remainingRecordingDurationInTicks -= 1
                }
                
            }
            
            if remainingRecordingDurationInTicks < setBreakDurationInTicks {break workoutLoop}
            
            for _ in 1...setBreakDurationInTicks {
                metaDataArray.append(MetaData(exerciseType: nil, exerciseSubType: nil))
                remainingRecordingDurationInTicks -= 1
            }
            
        }
        
        while remainingRecordingDurationInTicks > 0 {
            metaDataArray.append(MetaData(exerciseType: nil, exerciseSubType: nil))
            remainingRecordingDurationInTicks -= 1
        }
        
        return metaDataArray.reversed()
    }
}
