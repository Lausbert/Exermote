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
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "backward"), target: self, action: #selector(leftBarButtonItemPressed))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "forward"), target: self, action: #selector(rightBarButtonItemPressed))
        
        form = Section("Recording Duration and Frequency")
            <<< CustomSliderRow(){
                $0.title = "Duration [min]"
                $0.minimumValue = 1.0
                $0.maximumValue = 5.0
                $0.steps = 4
                if let value = UserDefaults.standard.value(forKey: USER_DEFAULTS_RECORDING_DURATION) as? Float {
                    $0.value = value
                }
            }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDING_DURATION)
            }
            <<< CustomSliderRow(){
                $0.title = "Frequency [Hz]"
                $0.minimumValue = 0.2
                $0.maximumValue = 10.0
                if let value = UserDefaults.standard.value(forKey: USER_DEFAULTS_RECORDING_FREQUENCY) as? Float {
                    $0.value = value
                }
                }.onChange {
                    let showFrequecnyAlert = UserDefaults.standard.value(forKey: USER_DEFAULTS_SHOW_FREQUENCY_ALERT) as? Bool ?? true
                    if showFrequecnyAlert {
                      self.frequencyAlert()
                    }
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDING_FREQUENCY)
                $0.steps = 98
            }
            +++ Section("Recorded Data")
            <<< CustomCheckRow(){
                $0.title = "Nearable ID"
                if let value = UserDefaults.standard.value(forKey: USER_DEFAULTS_RECORDED_DATA_NEARABLE_ID) as? Bool {
                    $0.value = value
                } else {
                    $0.value = true
                }
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_NEARABLE_ID)
            }
            <<< CustomCheckRow(){
                $0.title = "Frequency"
                if let value = UserDefaults.standard.value(forKey: USER_DEFAULTS_RECORDED_DATA_FREQUENCY) as? Bool {
                    $0.value = value
                } else {
                    $0.value = true
                }
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_FREQUENCY)
            }
            <<< CustomCheckRow(){
                $0.title = "RSSI"
                if let value = UserDefaults.standard.value(forKey: USER_DEFAULTS_RECORDED_DATA_RSSI) as? Bool {
                    $0.value = value
                } else {
                    $0.value = true
                }
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_RSSI)
            }
            <<< CustomCheckRow(){
                $0.title = "X Acceleration"
                if let value = UserDefaults.standard.value(forKey: USER_DEFAULTS_RECORDED_DATA_X_ACCELERATION) as? Bool {
                    $0.value = value
                } else {
                    $0.value = true
                }
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_X_ACCELERATION)
            }
            <<< CustomCheckRow(){
                $0.title = "Y Acceleration"
                if let value = UserDefaults.standard.value(forKey: USER_DEFAULTS_RECORDED_DATA_Y_ACCELERATION) as? Bool {
                    $0.value = value
                } else {
                    $0.value = true
                }
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_Y_ACCELERATION)
            }
            <<< CustomCheckRow(){
                $0.title = "Z Acceleration"
                if let value = UserDefaults.standard.value(forKey: USER_DEFAULTS_RECORDED_DATA_Z_ACCELERATION) as? Bool {
                    $0.value = value
                } else {
                    $0.value = true
                }
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_Z_ACCELERATION)
            }
            <<< CustomCheckRow(){
                $0.title = "Current State Duration"
                if let value = UserDefaults.standard.value(forKey: USER_DEFAULTS_RECORDED_DATA_CURRENT_STATE_DURATION) as? Bool {
                    $0.value = value
                } else {
                    $0.value = true
                }
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_CURRENT_STATE_DURATION)
            }
            <<< CustomCheckRow(){
                $0.title = "Previous State Duration"
                if let value = UserDefaults.standard.value(forKey: USER_DEFAULTS_RECORDED_DATA_PREVIOUS_STATE_DURATION) as? Bool {
                    $0.value = value
                } else {
                    $0.value = true
                }
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_PREVIOUS_STATE_DURATION)
            }
            <<< CustomCheckRow(){
                $0.title = "Time"
                if let value = UserDefaults.standard.value(forKey: USER_DEFAULTS_RECORDED_DATA_TIME) as? Bool {
                    $0.value = value
                } else {
                    $0.value = true
                }
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA_TIME)
            }
        
        let valuesDictionary = form.values()
        print(valuesDictionary)
    }
    
    func leftBarButtonItemPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func rightBarButtonItemPressed() {
        print("rightBarButtonItemPressed")
    }
    
    func frequencyAlert() {
        let alert = UIAlertController(title: "Notification", message: "Please be aware, that the mentioned recording frequency is not necessarily equal to sending frequeny of the nearables. The latter could be changed in the official ESTIMOTE Application.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: { (action) in
            UserDefaults.standard.set(false, forKey: USER_DEFAULTS_SHOW_FREQUENCY_ALERT)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
