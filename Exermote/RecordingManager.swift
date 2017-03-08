//
//  RecordingWorkoutManager.swift
//  Exermote
//
//  Created by Stephan Lerner on 01.02.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import Foundation
import AVFoundation

class RecordingWorkoutManager {

    private var _remainingRecordingDurationInTicks: Int = 600
    private var _recordedMeasurementPoints: [MeasurementPoint] = []
    private let _workOut: [MetaData] = MetaData.generateMetaDataForWorkout()
    private var _recordingFrequency: Int = 10
    private var _ticksSinceUIUpdate: Int = 10
    
    private var _timer:Timer? = nil {
        willSet {
            _timer?.invalidate()
        }
    }
    
    var remainingRecordingDurationInMinutes: String {
        
        let remainingRecordingDurationInSeconds = Int(Double(_remainingRecordingDurationInTicks)/Double(_recordingFrequency))
        let minutes = String(format:"%02i", remainingRecordingDurationInSeconds/60)
        let seconds = String(format:"%02i", remainingRecordingDurationInSeconds%60)
        let result = minutes + ":" + seconds
        
        return result
    }
    
    var progressAngle: Double {
        
        let currentExercise = self.currentExercise
        var i = 0, j = 1
        
        while true {
            if currentExercise != _workOut[safe: _remainingRecordingDurationInTicks - i - 1] {break}
            i += 1
        }
        
        while true {
            if currentExercise != _workOut[safe: _remainingRecordingDurationInTicks + j] {break}
            j += 1
        }
        
        return 360.0*Double(j)/Double(i+j)
    }
    
    var currentExercise: MetaData {
        return _workOut[_remainingRecordingDurationInTicks]
    }
    
    var nextExercise: MetaData {
        
        let currentExercise = self.currentExercise
        var result: MetaData? = currentExercise
        var i = 1
        
        while result == currentExercise {
            result = _workOut[safe: _remainingRecordingDurationInTicks - i]
            if result == nil {return MetaData(exerciseType: nil, exerciseSubType: nil)}
            i += 1
        }
        
        return result!
    }
    
    func attemptRecording(completion: @escaping (Bool)->()) {
        
        _recordingFrequency = UserDefaults.standard.integer(forKey: USER_DEFAULTS_RECORDING_FREQUENCY)
        let totalDurationInMinutes = UserDefaults.standard.integer(forKey: USER_DEFAULTS_RECORDING_DURATION)
        _remainingRecordingDurationInTicks = _recordingFrequency*totalDurationInMinutes*60
        
        _ticksSinceUIUpdate = _recordingFrequency
        let recordingInterval = 1.0/Double(_recordingFrequency)
        _timer = Timer.scheduledTimer(timeInterval: recordingInterval, target: self, selector: #selector(recordData), userInfo: nil, repeats: true)
        completion(true)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_UPDATE_RECORDING_DURATION), object: nil)
    }
    
    @objc private func recordData(){
        
        _remainingRecordingDurationInTicks -= 1
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_UPDATE_RECORDING_PROGRESS_ANGLE), object: nil)
        
        if _ticksSinceUIUpdate == _recordingFrequency {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_UPDATE_RECORDING_DURATION), object: nil)
            _ticksSinceUIUpdate = 0
        }
        
        let previousMetaData = _workOut[safe: _remainingRecordingDurationInTicks + 1]
        let metaData = _workOut[_remainingRecordingDurationInTicks]
        
        if previousMetaData != metaData {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_UPDATE_RECORDING_META_DATA), object: nil)
        }
        
        let iBeaconStates = BLEManager.instance.iBeaconStates.filter{$0.isSelected}
        let measurementPoint = MeasurementPoint(iBeaconStates: iBeaconStates, metaData: metaData)
        
        _recordedMeasurementPoints.append(measurementPoint)
        
        _ticksSinceUIUpdate += 1
        if _remainingRecordingDurationInTicks == 0 {stopRecording(success: true)}
    }
    
    func stopRecording(success: Bool) {
        
        defer {_recordedMeasurementPoints = []}
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_RECORDING_STOPPED), object: nil, userInfo: ["success":success])
        _timer = nil
        
        if success {
            
            let data = writeDataToString()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "y-MM-dd HH-mm-ss"
            
            let fileName = dateFormatter.string(from: Date()) + ".csv"
            
            saveFileToiCloud(data: data, fileName: fileName)
        }
    }
    
    private func writeDataToString() -> String {
        
        let delimeterData = "sep=" + CSV_DELIMETER + CSV_LINE_BREAK
        let headerData = MeasurementPoint.CSVHeaderString()
        var data: String = ""
        
        for measurementPoint in _recordedMeasurementPoints {
            data = data + measurementPoint.CSVDataString()
        }
        
        return delimeterData + headerData + data
    }
    
    private func saveFileToiCloud(data: String, fileName: String) {
        
        let localDocumentsUrl = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last!
        let localFileUrl = localDocumentsUrl.appendingPathComponent(fileName)
        
        do {
           try data.write(to: localFileUrl, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print(error.localizedDescription)
            return
        }
        
        let iCloudDocumentsUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
        let iCloudFileUrl = iCloudDocumentsUrl?.appendingPathComponent(fileName)
        
        if  iCloudFileUrl != nil {
            
            if (!FileManager.default.fileExists(atPath: iCloudDocumentsUrl!.path, isDirectory: nil)) {
                do {
                    try FileManager.default.createDirectory(at: iCloudDocumentsUrl!, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                    return
                }
            }
        } else {
            return
        }
        
        if FileManager.default.fileExists(atPath: (iCloudFileUrl?.path)!) {
            do {
                try FileManager.default.removeItem(at: iCloudFileUrl!)
            } catch {
                print(error.localizedDescription)
                return
            }
        }
        
        do {
            try FileManager.default.setUbiquitous(true, itemAt: localFileUrl, destinationURL: iCloudFileUrl!)
        } catch {
            print(error)
            return
        }
    }
}
