//
//  RecordingWorkoutVC.swift
//  Exermote
//
//  Created by Stephan Lerner on 16.02.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit
import KDCircularProgress
import AVFoundation
import Firebase

class RecordingWorkoutVC: UIViewController {

    @IBOutlet weak var remaingRecordingDurationLbl: UILabel!
    @IBOutlet weak var currentExerciseTypeLbl: UILabel!
    @IBOutlet weak var currentExerciseSubTypeLbl: UILabel!
    @IBOutlet weak var nextExerciseTypeLbl: UILabel!
    @IBOutlet weak var nextExerciseSubTypeLbl: UILabel!
    @IBOutlet weak var circularProgress: KDCircularProgress!
    
    private let _speechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    private let _toneOutputUnit: ToneOutputUnit = ToneOutputUnit()
    private let _recordingWorkoutManager: RecordingWorkoutManager = RecordingWorkoutManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "forward"), target: self, action: #selector(rightBarButtonItemPressed))
        
        self.circularProgress.progressColors = [COLOR_HIGHLIGHTED]
        
        _toneOutputUnit.enableSpeaker()
        _toneOutputUnit.setToneVolume(vol: 0.3)

        _recordingWorkoutManager.attemptRecording() {success in
            if success {
                NotificationCenter.default.addObserver(self, selector: #selector(self.updateRemainingDuration), name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_UPDATE_RECORDING_DURATION), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.updateMetaData), name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_UPDATE_RECORDING_META_DATA), object: nil)
                 NotificationCenter.default.addObserver(self, selector: #selector(self.updateCircularProgressAndPlaySound), name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_UPDATE_RECORDING_PROGRESS_ANGLE), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.stopRecording(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_RECORDING_STOPPED), object: nil)
            } else {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let settingRef = Database.database().reference().child(FIREBASE_SETTINGS)
        
        settingRef.observe(.value, with: { snapshot in
            
            if let settingDict = snapshot.value as? Dictionary<String, AnyObject> {
                if let recording = settingDict[FIREBASE_SETTINGS_RECORDING] as? Bool {
                    if !recording {
                        self._recordingWorkoutManager.stopRecording(success: false)
                    }
                }
            }
            
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: Navigation
    
    func rightBarButtonItemPressed() {
        cancelAlert()
    }
    
    // MARK: Recording
    
    func updateRemainingDuration() {
        remaingRecordingDurationLbl.text = _recordingWorkoutManager.remainingRecordingDurationInMinutes
    }
    
    func updateMetaData() {
        
        currentExerciseTypeLbl.text = _recordingWorkoutManager.currentExercise.exerciseType
        currentExerciseSubTypeLbl.text = _recordingWorkoutManager.currentExercise.exerciseSubType
        nextExerciseTypeLbl.text = _recordingWorkoutManager.nextExercise.exerciseType
        nextExerciseSubTypeLbl.text = _recordingWorkoutManager.nextExercise.exerciseSubType
        
        if currentExerciseTypeLbl.text == EXERCISE_SET_BREAK {
            let speechUtterance = AVSpeechUtterance(string: _recordingWorkoutManager.nextExercise.exerciseType)
            speechUtterance.rate = 0.4
            _speechSynthesizer.speak(speechUtterance)
        }
    }
    
    func updateCircularProgressAndPlaySound() {
        
        let progressAngle = _recordingWorkoutManager.progressAngle
        circularProgress.angle = progressAngle
        
        let currentExerciseType = _recordingWorkoutManager.currentExercise.exerciseType
        let currentExerciseSubType = _recordingWorkoutManager.currentExercise.exerciseSubType
        
        if currentExerciseType != EXERCISE_SET_BREAK && currentExerciseType != EXERCISE_BREAK && currentExerciseType != ERROR_VALUE_STRING {
            
            var frequency = STARTING_FREQUENCY_EXERCISE
            
            switch currentExerciseSubType {
            case EXERCISE_FIRST_HALF: frequency = frequency - progressAngle
            case EXERCISE_SECOND_HALF: frequency = frequency - (360.0 - progressAngle)
            default: break
            }
            
            _toneOutputUnit.setFrequency(freq: frequency)
            
            let recordingFrequency = UserDefaults.standard.integer(forKey: USER_DEFAULTS_RECORDING_FREQUENCY)
            let recordingInterval = 1.0/Double(recordingFrequency)
            
            _toneOutputUnit.setToneTime(t: recordingInterval)
            
        } else if currentExerciseType == EXERCISE_SET_BREAK && progressAngle >= 270.0 && progressAngle <= 300 {
            
            let frequency = ALERT_FREQUENCY_SET_BREAK
            let time = 0.5
            
            _toneOutputUnit.setFrequency(freq: frequency)
            _toneOutputUnit.setToneTime(t: time)
        }
    }
    
    func stopRecording(_ notification: NSNotification) {

        self.dismiss(animated: false, completion: nil)
        
        let settingRef = Database.database().reference().child(FIREBASE_SETTINGS)
        settingRef.removeAllObservers()
        let settingDict = [FIREBASE_SETTINGS_RECORDING: false]
        settingRef.updateChildValues(settingDict)
        
        let success = notification.userInfo?["success"] as! Bool
        if success && UserDefaults.standard.bool(forKey: USER_DEFAULTS_SHOW_ICLOUD_ALERT) {
            self.iCloudAlert()
        } else {
            self.navigationController?.pop(transitionType: TRANSITION_TYPE, transitionSubType: kCATransitionFromRight, duration: TRANSITION_DURATION)
        }
    }
    
    // MARK: Alerts
    
    func cancelAlert() {
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to stop recording? All unsaved data will be lost.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default))
        alert.addAction(UIAlertAction(title: "Stop", style: .destructive, handler: { (action) in
            self._recordingWorkoutManager.stopRecording(success: false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func iCloudAlert() {
        let alert = UIAlertController(title: "Notification", message: "The recorded data will now be uploaded to your iCLoud drive. Please check it on your MacBook or on iCloud.com.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: { (action) in
            UserDefaults.standard.set(false, forKey: USER_DEFAULTS_SHOW_ICLOUD_ALERT)
            _ = self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
