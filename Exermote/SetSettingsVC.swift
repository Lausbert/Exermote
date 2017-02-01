//
//  SetSettingsVC.swift
//  Exermote
//
//  Created by Stephan Lerner on 28.01.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit
import Eureka

class SetSettingsVC: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "back"), target: self, action: #selector(leftBarButtonItemPressed))
        
        form = Section("Recording Duration and Frequency")
            <<< CustomSliderRow(){
                $0.title = "Duration [min]"
                $0.minimumValue = RECORDING_DURATION_MINIMUM
                $0.maximumValue = RECORDING_DURATION_MAXIMUM
                $0.steps = RECORDING_DURATION_STEPS
                $0.value = UserDefaults.standard.float(forKey: USER_DEFAULTS_RECORDING_DURATION)
            }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDING_DURATION)
            }
            <<< CustomSliderRow(){
                $0.title = "Frequency [Hz]"
                $0.minimumValue = RECORDING_FREQUENCY_MINIMUM
                $0.maximumValue = RECORDING_FREQUENCY_MAXIMUM
                $0.steps = RECORDING_FREQUENCY_STEPS
                $0.value = UserDefaults.standard.float(forKey: USER_DEFAULTS_RECORDING_FREQUENCY)
            }.onChange {
                    if UserDefaults.standard.bool(forKey: USER_DEFAULTS_SHOW_FREQUENCY_ALERT) {
                      self.frequencyAlert()
                    }
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDING_FREQUENCY)
            }
            +++ Section("Recorded Data")
            <<< CustomCheckRow(){
                $0.title = "Nearable ID"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA_NEARABLE_ID)
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_NEARABLE_ID)
            }
            <<< CustomCheckRow(){
                $0.title = "Frequency"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA_FREQUENCY)
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_FREQUENCY)
            }
            <<< CustomCheckRow(){
                $0.title = "RSSI"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA_RSSI)
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_RSSI)
            }
            <<< CustomCheckRow(){
                $0.title = "X Acceleration"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA_X_ACCELERATION)
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_X_ACCELERATION)
            }
            <<< CustomCheckRow(){
                $0.title = "Y Acceleration"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA_Y_ACCELERATION)
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_Y_ACCELERATION)
            }
            <<< CustomCheckRow(){
                $0.title = "Z Acceleration"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA_Z_ACCELERATION)
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_Z_ACCELERATION)
            }
            <<< CustomCheckRow(){
                $0.title = "Current State Duration"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA_CURRENT_STATE_DURATION)
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_CURRENT_STATE_DURATION)
            }
            <<< CustomCheckRow(){
                $0.title = "Previous State Duration"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA_PREVIOUS_STATE_DURATION)
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_PREVIOUS_STATE_DURATION)
            }
            <<< CustomCheckRow(){
                $0.title = "Time"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA_TIME)
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_TIME)
            }
    }
    
    func leftBarButtonItemPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func frequencyAlert() {
        let alert = UIAlertController(title: "Notification", message: "Please be aware, that the mentioned recording frequency is not necessarily equal to sending frequeny of the nearables. The latter could be changed in the official ESTIMOTE Application.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: { (action) in
            UserDefaults.standard.set(false, forKey: USER_DEFAULTS_SHOW_FREQUENCY_ALERT)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
