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
                $0.minimumValue = Float(RECORDING_DURATION_MINIMUM)
                $0.maximumValue = Float(RECORDING_DURATION_MAXIMUM)
                $0.steps = UInt($0.maximumValue-$0.minimumValue)
                $0.value = UserDefaults.standard.float(forKey: USER_DEFAULTS_RECORDING_DURATION)
            }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDING_DURATION)
            }
            <<< CustomSegmentedRow<Int>(){
                $0.title = "Frequency [Hz]"
                $0.options = RECORDING_FREQUENCY_OPTIONS
                $0.value = UserDefaults.standard.integer(forKey: USER_DEFAULTS_RECORDING_FREQUENCY)
            }.onChange {
                    if UserDefaults.standard.bool(forKey: USER_DEFAULTS_SHOW_FREQUENCY_ALERT) {
                      self.frequencyAlert()
                    }
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDING_FREQUENCY)
            }
            +++ Section("Recorded Data")
            <<< CustomCheckRow(){
                $0.title = "Nearable ID"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA[0])
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA[0])
            }
            <<< CustomCheckRow(){
                $0.title = "Frequency"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA[1])
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA[1])
            }
            <<< CustomCheckRow(){
                $0.title = "RSSI"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA[2])
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA[2])
            }
            <<< CustomCheckRow(){
                $0.title = "X Acceleration"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA[3])
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA[3])
            }
            <<< CustomCheckRow(){
                $0.title = "Y Acceleration"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA[4])
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA[4])
            }
            <<< CustomCheckRow(){
                $0.title = "Z Acceleration"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA[5])
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA[5])
            }
            <<< CustomCheckRow(){
                $0.title = "Current State Duration"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA[6])
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA[6])
            }
            <<< CustomCheckRow(){
                $0.title = "Previous State Duration"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA[7])
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA[7])
            }
            <<< CustomCheckRow(){
                $0.title = "Time"
                $0.value = UserDefaults.standard.bool(forKey: USER_DEFAULTS_RECORDED_DATA[8])
                }.onChange {
                    UserDefaults.standard.set($0.value, forKey: USER_DEFAULTS_RECORDED_DATA[8])
            }
    }
    
    func leftBarButtonItemPressed() {
        if isAnyDataSelected() {
            _ = navigationController?.popViewController(animated: true)
        } else {
            selectionAlert()
        }
    }
    
    func frequencyAlert() {
        let alert = UIAlertController(title: "Notification", message: "Please be aware, that the mentioned recording frequency is not necessarily equal to sending frequeny of the nearables. The latter could be changed in the official ESTIMOTE Application.", preferredStyle: .actionSheet)
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
    
    func isAnyDataSelected() -> Bool {
        for key in USER_DEFAULTS_RECORDED_DATA {
            if UserDefaults.standard.bool(forKey: key) {return true}
        }
        return false
    }
}
