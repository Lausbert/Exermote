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
        
        defer {recordedMeasurementPoints = []}
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_RECORDING_STOPPED), object: nil)
        timer = nil
        
        if success {
            
            let data = writeDataToString()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "y-MM-dd HH-mm-ss"
            
            let fileName = dateFormatter.string(from: Date()) + ".csv"
            
            saveFileToiCloud(data: data, fileName: fileName)
        }
    }
    
    func writeDataToString() -> String {
        
        let delimeterData = "sep=" + CSV_DELIMETER + CSV_LINE_BREAK
        
        var headerData:[String] = []
        
        for key in USER_DEFAULTS_RECORDED_DATA {
            if UserDefaults.standard.bool(forKey: key) {
                headerData.append(key)
            }
        }
        
        let headerDataString = headerData.joined(separator: CSV_DELIMETER) + CSV_LINE_BREAK
        
        var recordedDataString = ""
        
        for measurementPoint in recordedMeasurementPoints {
            
            let measurementPointDictionary = measurementPoint.toStringDictionary
            var recordedData:[String] = []
            
            for key in USER_DEFAULTS_RECORDED_DATA {
                if UserDefaults.standard.bool(forKey: key) {
                    recordedData.append(measurementPointDictionary[key]!)
                }
            }
            
            recordedDataString = recordedDataString + recordedData.joined(separator: CSV_DELIMETER) + CSV_LINE_BREAK
        }
        
        return delimeterData + headerDataString + recordedDataString
    }
    
    func saveFileToiCloud(data: String, fileName: String) {
        
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
