//
//  RecordingManager.swift
//  Exermote
//
//  Created by Stephan Lerner on 01.02.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import Foundation

class RecordingManager {
    
    static let instance = RecordingManager()
    
    var remainingRecordingDurationInMinutes: String {
        let minutes = String(remainingRecordingDurationInSeconds!/60)
        let seconds = String(remainingRecordingDurationInSeconds!%60)
        return minutes + ":" + seconds
    }
    
    private var totalRecordingDurationInSeconds:Int?
    private var remainingRecordingDurationInSeconds: Int?
    private var recordingFrequency:Double?
    
    func attemptRecording(completion: @escaping (Bool)->()) {
        
        let totalRecordingDurationInMinutes = UserDefaults.standard.double(forKey: USER_DEFAULTS_RECORDING_DURATION)
        totalRecordingDurationInSeconds = Int(totalRecordingDurationInMinutes*60.0)
        remainingRecordingDurationInSeconds = totalRecordingDurationInSeconds
        
        recordingFrequency = UserDefaults.standard.double(forKey: USER_DEFAULTS_RECORDING_FREQUENCY)
        
    }
    
}
