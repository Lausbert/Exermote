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
        let remainingRecordingDurationInSeconds = Int(Double(remainingRecordingDurationInTicks)/Double(recordingFrequency))
        let minutes = String(format:"%02i", remainingRecordingDurationInSeconds/60)
        let seconds = String(format:"%02i", remainingRecordingDurationInSeconds%60)
        let result = minutes + ":" + seconds
        return result
    }
    
    private var timer:Timer? = nil {
        willSet {
            timer?.invalidate()
        }
    }

    private var remainingRecordingDurationInTicks:Int = 600
    private var recordedMeasurementPoints: [MeasurementPoint] = []
    private var recordingFrequency: Int = 10
    private var ticksSinceUIUpdate: Int = 10
    
    func attemptRecording(completion: @escaping (Bool)->()) {
        
        recordingFrequency = UserDefaults.standard.integer(forKey: USER_DEFAULTS_RECORDING_FREQUENCY)
        ticksSinceUIUpdate = recordingFrequency
        let totalRemainingDurationInMinutes = UserDefaults.standard.integer(forKey: USER_DEFAULTS_RECORDING_DURATION)
        remainingRecordingDurationInTicks = recordingFrequency*totalRemainingDurationInMinutes*60
        let recordingInterval = 1.0/Double(recordingFrequency)
        
        timer = Timer.scheduledTimer(timeInterval: recordingInterval, target: self, selector: #selector(recordData), userInfo: nil, repeats: true)
        completion(true)
    }
    
    @objc func recordData(){
        
        remainingRecordingDurationInTicks -= 1
        
        if ticksSinceUIUpdate == recordingFrequency {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_SWIFT_SPINNER_UPDATE_NEEDED), object: nil)
            ticksSinceUIUpdate = 0
        }
        
        let measurementPointsToBeRecorded = BLEManager.instance.measurementPoints.filter{$0.isSelected}
        recordedMeasurementPoints.append(contentsOf: measurementPointsToBeRecorded)
        
        ticksSinceUIUpdate += 1
        if remainingRecordingDurationInTicks == 0 {stopRecording(success: true)}
    }
    
    func stopRecording(success: Bool) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_RECORDING_STOPPED), object: nil)
        timer = nil
        
        if success {
            writeDataToFile()
        } else {
            recordedMeasurementPoints = []
        }
    }
    
    func writeDataToFile() {
        
    }
}
