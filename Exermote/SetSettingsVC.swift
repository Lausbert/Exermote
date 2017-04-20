//
//  SetSettingsVC.swift
//  Exermote
//
//  Created by Stephan Lerner on 28.01.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit
import Eureka
import Firebase

class SetSettingsVC: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "back"), target: self, action: #selector(leftBarButtonItemPressed))
        
        // MARK: tableView
        
        form = Section("Athlete")
            <<< TextRow(){
                $0.title = "Name"
                $0.placeholder = "Name"
                $0.tag = USER_DEFAULTS_ATHLETE_NAME
                if let name = UserDefaults.standard.string(forKey: USER_DEFAULTS_ATHLETE_NAME) {
                    $0.value = name
                }
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_ATHLETE_NAME)
            }
            +++ Section("Exercises")
            <<< ButtonRow() {
                $0.title = "Manage Exercises"
                $0.presentationMode = .segueName(segueName: SEGUE_MANAGE_EXERCISE, onDismiss: nil)
            }
            +++ Section("Recording Duration and Frequency")
            <<< SliderRow(){
                $0.title = "Duration [min]"
                $0.minimumValue = Float(RECORDING_DURATION_MINIMUM)
                $0.maximumValue = Float(RECORDING_DURATION_MAXIMUM)
                $0.steps = UInt($0.maximumValue-$0.minimumValue)
                $0.value = UserDefaults.standard.float(forKey: USER_DEFAULTS_RECORDING_DURATION)
                $0.tag = USER_DEFAULTS_RECORDING_DURATION
            }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDING_DURATION)
            }
            <<< SegmentedRow<Int>(){
                $0.title = "Frequency [Hz]"
                $0.options = RECORDING_FREQUENCY_OPTIONS
                $0.value = UserDefaults.standard.integer(forKey: USER_DEFAULTS_RECORDING_FREQUENCY)
                $0.tag = USER_DEFAULTS_RECORDING_FREQUENCY
            }.onChange {
                    if UserDefaults.standard.bool(forKey: USER_DEFAULTS_SHOW_FREQUENCY_ALERT) {
                      self.frequencyAlert()
                    }
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDING_FREQUENCY)
            }
            +++ Section("Recorded Data")
            <<< CustomMultipleSelectorRow<String>(){
                let title = "Nearable Data"
                $0.title = title
                $0.selectorTitle = title
                $0.options = USER_DEFAULTS_RECORDED_DATA_I_BEACON_STATE
                var values: [String] = []
                for key in USER_DEFAULTS_RECORDED_DATA_I_BEACON_STATE {
                    if UserDefaults.standard.bool(forKey: key) {
                        values.append(key)
                    }
                }
                $0.value = Set(values)
                }.onChange {
                    for key in USER_DEFAULTS_RECORDED_DATA_I_BEACON_STATE {
                        if ($0.value?.contains(key))! {
                            UserDefaults.standard.set(true, forKey: key)
                        } else {
                            UserDefaults.standard.set(false, forKey: key)
                        }
                    }
            }
            <<< CustomMultipleSelectorRow<String>(){
                let title = "Device Data"
                $0.title = title
                $0.selectorTitle = title
                $0.options = USER_DEFAULTS_RECORDED_DATA_DEVICE_STATE
                var values: [String] = []
                for key in USER_DEFAULTS_RECORDED_DATA_DEVICE_STATE {
                    if UserDefaults.standard.bool(forKey: key) {
                        values.append(key)
                    }
                }
                $0.value = Set(values)
                }.onChange {
                    for key in USER_DEFAULTS_RECORDED_DATA_DEVICE_STATE {
                        if ($0.value?.contains(key))! {
                            UserDefaults.standard.set(true, forKey: key)
                        } else {
                            UserDefaults.standard.set(false, forKey: key)
                        }
                    }
            }
            <<< CustomMultipleSelectorRow<String>(){
                let title = "Meta Data"
                $0.title = title
                $0.selectorTitle = title
                $0.options = USER_DEFAULTS_RECORDED_DATA_META_DATA
                var values: [String] = []
                for key in USER_DEFAULTS_RECORDED_DATA_META_DATA {
                    if UserDefaults.standard.bool(forKey: key) {
                        values.append(key)
                    }
                }
                $0.value = Set(values)
                }.onChange {
                    for key in USER_DEFAULTS_RECORDED_DATA_META_DATA {
                        if ($0.value?.contains(key))! {
                            UserDefaults.standard.set(true, forKey: key)
                        } else {
                            UserDefaults.standard.set(false, forKey: key)
                        }
                    }
            }
    }
    
    // MARK: Navigation
    
    func leftBarButtonItemPressed() {
        
        let settingsRef = FIRDatabase.database().reference().child(FIREBASE_SETTINGS)
        settingsRef.updateChildValues(form.values() as Any as! [AnyHashable : Any])
        
        if isAnyDataSelected() {
            self.navigationController?.pop(transitionType: TRANSITION_TYPE, transitionSubType: kCATransitionFromLeft, duration: TRANSITION_DURATION)
        } else {
            selectionAlert()
        }
    }
    
    func isAnyDataSelected() -> Bool {
        for key in USER_DEFAULTS_RECORDED_DATA_I_BEACON_STATE {
            if UserDefaults.standard.bool(forKey: key) {return true}
        }
        return false
    }
    
    // MARK: Alerts
    
    func frequencyAlert() {
        let alert = UIAlertController(title: "Notification", message: "Please be aware, that mentioned recording frequency is not necessarily equal to sending frequeny of your nearables. The latter could be changed in the official ESTIMOTE Application.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: { (action) in
            UserDefaults.standard.set(false, forKey: USER_DEFAULTS_SHOW_FREQUENCY_ALERT)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func selectionAlert() {
        let alert = UIAlertController(title: "Warning", message: "Select at least one data property to be recorded.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
