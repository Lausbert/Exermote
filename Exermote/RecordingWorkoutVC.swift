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

class RecordingWorkoutVC: UIViewController {

    @IBOutlet weak var remaingRecordingDurationLbl: UILabel!
    @IBOutlet weak var currentExerciseTypeLbl: UILabel!
    @IBOutlet weak var currentExerciseSubTypeLbl: UILabel!
    @IBOutlet weak var nextExerciseTypeLbl: UILabel!
    @IBOutlet weak var nextExerciseSubTypeLbl: UILabel!
    @IBOutlet weak var circularProgress: KDCircularProgress!
    
    private let _speechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    var recordingWorkoutManager: RecordingWorkoutManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "forward"), target: self, action: #selector(rightBarButtonItemPressed))
        
        self.circularProgress.progressColors = [COLOR_HIGHLIGHTED]
        
        recordingWorkoutManager = RecordingWorkoutManager()

        recordingWorkoutManager.attemptRecording() {success in
            if success {
                NotificationCenter.default.addObserver(self, selector: #selector(self.updateRemainingDuration), name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_UPDATE_RECORDING_DURATION), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.updateMetaData), name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_UPDATE_RECORDING_META_DATA), object: nil)
                 NotificationCenter.default.addObserver(self, selector: #selector(self.updateCircularProgress), name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_UPDATE_RECORDING_PROGRESS_ANGLE), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.stopRecording(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_RECORDING_STOPPED), object: nil)
            } else {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: Navigation
    
    func rightBarButtonItemPressed() {
        cancelAlert()
    }
    
    // MARK: Recording
    
    func updateRemainingDuration() {
        remaingRecordingDurationLbl.text = recordingWorkoutManager.remainingRecordingDurationInMinutes
    }
    
    func updateMetaData() {
        if currentExerciseTypeLbl.text == EXERCISE_SET_BREAK {
            let speechUtterance = AVSpeechUtterance(string: recordingWorkoutManager.nextExercise.exerciseType)
            speechUtterance.rate = 0.4
            _speechSynthesizer.speak(speechUtterance)
        }
        currentExerciseTypeLbl.text = recordingWorkoutManager.currentExercise.exerciseType
        currentExerciseSubTypeLbl.text = recordingWorkoutManager.currentExercise.exerciseSubType
        nextExerciseTypeLbl.text = recordingWorkoutManager.nextExercise.exerciseType
        nextExerciseSubTypeLbl.text = recordingWorkoutManager.nextExercise.exerciseSubType
    }
    
    func updateCircularProgress() {
        circularProgress.angle = recordingWorkoutManager.progressAngle
    }
    
    func stopRecording(_ notification: NSNotification) {

        self.dismiss(animated: false, completion: nil)
        
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
            self.recordingWorkoutManager.stopRecording(success: false)
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
