//
//  Ecercise.swift
//  Exermote
//
//  Created by Stephan Lerner on 24.02.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import Foundation

class Exercise {
    
    private var _name: String
    private var _maximumDuration: Double
    private var _minimumDuration: Double
    private var _firstHalfSecondHalfRatio: Double
    private var _repetitionBreakDuration: Double
    private var _setBreakDuration: Double
    private var _exerciseBreakDuration: Double
    
    init(name: String, maximumDuration: Double, minimumDuration: Double, firstHalfSecondHalfRatio: Double, repetitionBreakDuration: Double, setBreakDuration: Double, exerciseBreakDuration: Double) {
        _name = name
        _maximumDuration = maximumDuration
        _minimumDuration = minimumDuration
        _firstHalfSecondHalfRatio = firstHalfSecondHalfRatio
        _repetitionBreakDuration = repetitionBreakDuration
        _setBreakDuration = setBreakDuration
        _exerciseBreakDuration = exerciseBreakDuration
    }
}
