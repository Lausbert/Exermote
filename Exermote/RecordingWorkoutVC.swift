//
//  RecordingWorkoutVC.swift
//  Exermote
//
//  Created by Stephan Lerner on 16.02.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit

class RecordingWorkoutVC: UIViewController {

    @IBOutlet weak var remaingRecordingDurationLbl: UILabel!
    var recordingManager: RecordingManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "forward"), target: self, action: #selector(rightBarButtonItemPressed))
        
        recordingManager = RecordingManager()

        recordingManager.attemptRecording() {success in
            if success {
                NotificationCenter.default.addObserver(self, selector: #selector(self.updateRemainingDuration), name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_UPDATE_RECORDING_DURATION), object: nil)
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
        remaingRecordingDurationLbl.text = recordingManager.remainingRecordingDurationInMinutes
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
            self.recordingManager.stopRecording(success: false)
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
