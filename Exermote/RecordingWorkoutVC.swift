//
//  RecordingWorkoutVC.swift
//  Exermote
//
//  Created by Stephan Lerner on 16.02.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit
import SwiftSpinner

class RecordingWorkoutVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "back"), target: self, action: #selector(leftBarButtonItemPressed))

        RecordingManager.instance.attemptRecording() {success in
            if success {
                NotificationCenter.default.addObserver(self, selector: #selector(self.updateSwiftSpinner), name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_SWIFT_SPINNER_UPDATE_NEEDED), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.hideSwiftSpinner(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_RECORDING_STOPPED), object: nil)
                self.showSwiftSpinner()
            } else {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: Navigation
    
    func leftBarButtonItemPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: SwiftSpinner
    
    func showSwiftSpinner(){
        SwiftSpinner.setTitleFont(UIFont(name: "NotoSans", size: 22.0))
        let title = RecordingManager.instance.remainingRecordingDurationInMinutes
        SwiftSpinner.show(title).addTapHandler({
            SwiftSpinner.hide()
            self.cancelAlert()
        }, subtitle: "Tap to cancel recording")
    }
    
    func updateSwiftSpinner() {
        SwiftSpinner.sharedInstance.titleLabel.text = RecordingManager.instance.remainingRecordingDurationInMinutes
    }
    
    func hideSwiftSpinner(_ notification: NSNotification) {
        SwiftSpinner.hide()
        self.dismiss(animated: false, completion: nil)
        
        let success = notification.userInfo?["success"] as! Bool
        if success && UserDefaults.standard.bool(forKey: USER_DEFAULTS_SHOW_ICLOUD_ALERT) {
            self.iCloudAlert()
        }
    }
    
    // MARK: Alerts
    
    func cancelAlert() {
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to stop recording? All unsaved data will be lost.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
            self.showSwiftSpinner()
        }))
        alert.addAction(UIAlertAction(title: "Stop", style: .destructive, handler: { (action) in
            RecordingManager.instance.stopRecording(success: false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func iCloudAlert() {
        let alert = UIAlertController(title: "Notification", message: "The recorded data will now be uploaded to your iCLoud drive. Please check it on your MacBook or on iCloud.com.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: { (action) in
            UserDefaults.standard.set(false, forKey: USER_DEFAULTS_SHOW_ICLOUD_ALERT)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
