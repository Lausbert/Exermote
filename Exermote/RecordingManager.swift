//
//  RecordingManager.swift
//  Exermote
//
//  Created by Stephan Lerner on 01.02.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import Foundation

class RecordingManager {
    
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
    private var recordedIBeaconStates: [IBeaconState] = []
    private var recordingFrequency: Int = 10
    private var ticksSinceUIUpdate: Int = 10
    
    func attemptRecording(completion: @escaping (Bool)->()) {
        
        recordingFrequency = UserDefaults.standard.integer(forKey: USER_DEFAULTS_RECORDING_FREQUENCY)
        let totalDurationInMinutes = UserDefaults.standard.integer(forKey: USER_DEFAULTS_RECORDING_DURATION)
        remainingRecordingDurationInTicks = recordingFrequency*totalDurationInMinutes*60
        
        ticksSinceUIUpdate = recordingFrequency
        let recordingInterval = 1.0/Double(recordingFrequency)
        timer = Timer.scheduledTimer(timeInterval: recordingInterval, target: self, selector: #selector(recordData), userInfo: nil, repeats: true)
        completion(true)
    }
    
    @objc private func recordData(){
        
        remainingRecordingDurationInTicks -= 1
        
        if ticksSinceUIUpdate == recordingFrequency {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_SWIFT_SPINNER_UPDATE_NEEDED), object: nil)
            ticksSinceUIUpdate = 0
        }
        
        let iBeaconStatesToBeRecorded = BLEManager.instance.iBeaconStates.filter{$0.isSelected}
        recordedIBeaconStates.append(contentsOf: iBeaconStatesToBeRecorded)
        
        ticksSinceUIUpdate += 1
        if remainingRecordingDurationInTicks == 0 {stopRecording(success: true)}
    }
    
    func stopRecording(success: Bool) {
        
        defer {recordedIBeaconStates = []}
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_RECORDING_STOPPED), object: nil, userInfo: ["success":success])
        timer = nil
        
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
        
        var headerData:[String] = []
        
        for key in USER_DEFAULTS_RECORDED_DATA {
            if UserDefaults.standard.bool(forKey: key) {
                headerData.append(key)
            }
        }
        
        let headerDataString = headerData.joined(separator: CSV_DELIMETER) + CSV_LINE_BREAK
        
        var recordedDataString = ""
        
        for iBeaconState in recordedIBeaconStates {
            
            let iBeaconStateDictionary = iBeaconState.stringDictionary
            var recordedData:[String] = []
            
            for key in USER_DEFAULTS_RECORDED_DATA {
                if UserDefaults.standard.bool(forKey: key) {
                    recordedData.append(iBeaconStateDictionary[key]!)
                }
            }
            
            recordedDataString = recordedDataString + recordedData.joined(separator: CSV_DELIMETER) + CSV_LINE_BREAK
        }
        
        return delimeterData + headerDataString + recordedDataString
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
