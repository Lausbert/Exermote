//
//  Ecercise.swift
//  Exermote
//
//  Created by Stephan Lerner on 24.02.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import Foundation

class Exercise: NSObject, NSCoding {
    
    private var _name: String
    private var _includedInWorkout: Bool
    private var _maximumDuration: Double
    private var _minimumDuration: Double
    private var _firstHalfSecondHalfRatio: Double
    private var _repetitionBreakDuration: Double
    private var _setBreakDuration: Double
    
    var name: String {
        return _name
    }
    
    var includedInWorkout: Bool {
        return _includedInWorkout
    }
    
    var maximumDuration: Double {
        return _maximumDuration
    }
    
    var minimumDuration: Double {
        return _minimumDuration
    }
    
    var firstHalfSecondHalratio: Double {
        return _firstHalfSecondHalfRatio
    }
    
    var repetitionBreakDuration: Double {
        return _repetitionBreakDuration
    }
    
    var setBreakDuration: Double {
        return _setBreakDuration
    }
    
    var dictionary: Dictionary<String, Any> {
        
        var dict = [String : Any]()
        
        dict[EXERCISE_ATTRIBUTES[0]] = _name
        dict[EXERCISE_ATTRIBUTES[1]] = _includedInWorkout
        dict[EXERCISE_ATTRIBUTES[2]] = _maximumDuration
        dict[EXERCISE_ATTRIBUTES[3]] = _minimumDuration
        dict[EXERCISE_ATTRIBUTES[4]] = _firstHalfSecondHalfRatio
        dict[EXERCISE_ATTRIBUTES[5]] = _repetitionBreakDuration
        dict[EXERCISE_ATTRIBUTES[6]] = _setBreakDuration
        
        return dict
    }
    
    var maximumFirstHalfDuration: Double {
        return _firstHalfSecondHalfRatio * _maximumDuration
    }
    
    var maximumSecondHalfDuration: Double {
        return (1 - _firstHalfSecondHalfRatio) * _maximumDuration
    }
    
    var minimumFirstHalfDuration: Double {
        return _firstHalfSecondHalfRatio * _minimumDuration
    }
    
    var minimumSecondHalfDuration: Double {
        return (1 - _firstHalfSecondHalfRatio) * _minimumDuration
    }
    
    var firstHalfDuration: Double {
        let x = Double.random0to1()
        return minimumFirstHalfDuration + (maximumFirstHalfDuration - minimumFirstHalfDuration) * x
    }
    
    var secondHalfDuration: Double {
        let x = Double.random0to1()
        return minimumSecondHalfDuration + (maximumSecondHalfDuration - minimumSecondHalfDuration) * x
    }
    
    init(exerciseDict: Dictionary<String, Any>) {
        _name = exerciseDict[EXERCISE_ATTRIBUTES[0]] as! String
        _includedInWorkout = exerciseDict[EXERCISE_ATTRIBUTES[1]] as! Bool
        _maximumDuration = exerciseDict[EXERCISE_ATTRIBUTES[2]] as! Double
        _minimumDuration = exerciseDict[EXERCISE_ATTRIBUTES[3]] as! Double
        _firstHalfSecondHalfRatio = Double(exerciseDict[EXERCISE_ATTRIBUTES[4]] as! Double)
        _repetitionBreakDuration = exerciseDict[EXERCISE_ATTRIBUTES[5]] as! Double
        _setBreakDuration = exerciseDict[EXERCISE_ATTRIBUTES[6]] as! Double
    }
    
    required init(coder decoder: NSCoder) {
        _name = decoder.decodeObject(forKey: EXERCISE_ATTRIBUTES[0]) as! String
        _includedInWorkout = decoder.decodeBool(forKey: EXERCISE_ATTRIBUTES[1])
        _maximumDuration = decoder.decodeDouble(forKey: EXERCISE_ATTRIBUTES[2])
        _minimumDuration = decoder.decodeDouble(forKey: EXERCISE_ATTRIBUTES[3])
        _firstHalfSecondHalfRatio = decoder.decodeDouble(forKey: EXERCISE_ATTRIBUTES[4])
        _repetitionBreakDuration = decoder.decodeDouble(forKey: EXERCISE_ATTRIBUTES[5])
        _setBreakDuration = decoder.decodeDouble(forKey: EXERCISE_ATTRIBUTES[6])
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(_name, forKey: EXERCISE_ATTRIBUTES[0])
        coder.encode(_includedInWorkout, forKey: EXERCISE_ATTRIBUTES[1])
        coder.encode(_maximumDuration, forKey: EXERCISE_ATTRIBUTES[2])
        coder.encode(_minimumDuration, forKey: EXERCISE_ATTRIBUTES[3])
        coder.encode(_firstHalfSecondHalfRatio, forKey: EXERCISE_ATTRIBUTES[4])
        coder.encode(_repetitionBreakDuration, forKey: EXERCISE_ATTRIBUTES[5])
        coder.encode(_setBreakDuration, forKey: EXERCISE_ATTRIBUTES[6])
    }
}
