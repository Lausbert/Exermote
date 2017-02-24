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
    private var _maximumDuration: Double
    private var _minimumDuration: Double
    private var _firstHalfSecondHalfRatio: Double
    private var _repetitionBreakDuration: Double
    private var _setBreakDuration: Double
    private var _exerciseBreakDuration: Double
    
    init(exerciseDict: Dictionary<String, Any>) {
        _name = exerciseDict[EXERCISE_ATTRIBUTES[0]] as! String
        _maximumDuration = exerciseDict[EXERCISE_ATTRIBUTES[1]] as! Double
        _minimumDuration = exerciseDict[EXERCISE_ATTRIBUTES[2]] as! Double
        _firstHalfSecondHalfRatio = Double(exerciseDict[EXERCISE_ATTRIBUTES[3]] as! Float)
        _repetitionBreakDuration = exerciseDict[EXERCISE_ATTRIBUTES[4]] as! Double
        _setBreakDuration = exerciseDict[EXERCISE_ATTRIBUTES[5]] as! Double
        _exerciseBreakDuration = exerciseDict[EXERCISE_ATTRIBUTES[6]] as! Double
    }
    
    required init(coder decoder: NSCoder) {
        _name = decoder.decodeObject(forKey: EXERCISE_ATTRIBUTES[0]) as! String
        _maximumDuration = decoder.decodeDouble(forKey: EXERCISE_ATTRIBUTES[1])
        _minimumDuration = decoder.decodeDouble(forKey: EXERCISE_ATTRIBUTES[2])
        _firstHalfSecondHalfRatio = decoder.decodeDouble(forKey: EXERCISE_ATTRIBUTES[3])
        _repetitionBreakDuration = decoder.decodeDouble(forKey: EXERCISE_ATTRIBUTES[4])
        _setBreakDuration = decoder.decodeDouble(forKey: EXERCISE_ATTRIBUTES[5])
        _exerciseBreakDuration = decoder.decodeDouble(forKey: EXERCISE_ATTRIBUTES[6])
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(_name, forKey: EXERCISE_ATTRIBUTES[0])
        coder.encode(_name, forKey: EXERCISE_ATTRIBUTES[1])
        coder.encode(_name, forKey: EXERCISE_ATTRIBUTES[2])
        coder.encode(_name, forKey: EXERCISE_ATTRIBUTES[3])
        coder.encode(_name, forKey: EXERCISE_ATTRIBUTES[4])
        coder.encode(_name, forKey: EXERCISE_ATTRIBUTES[5])
        coder.encode(_name, forKey: EXERCISE_ATTRIBUTES[6])
    }
}
