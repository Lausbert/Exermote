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
                $0.value = 4.0
            }
            <<< CustomSliderRow(){
                $0.title = "Frequency [Hz]"
                $0.minimumValue = 0.2
                $0.maximumValue = 10.0
                $0.steps = 98
            }
            +++ Section("Recorded Data")
            <<< CustomCheckRow(){
                $0.title = "Nearable ID"
                $0.value = true
            }
            <<< CustomCheckRow(){
                $0.title = "Frequency"
            }
            <<< CustomCheckRow(){
                $0.title = "RSSI"
            }
            <<< CustomCheckRow(){
                $0.title = "X Acceleration"
            }
            <<< CustomCheckRow(){
                $0.title = "Y Acceleration"
            }
            <<< CustomCheckRow(){
                $0.title = "Z Acceleration"
            }
            <<< CustomCheckRow(){
                $0.title = "Current State Duration"
            }
            <<< CustomCheckRow(){
                $0.title = "Previous State Duration"
            }
            <<< CustomCheckRow(){
                $0.title = "Time"
            }
    }
    
    func leftBarButtonItemPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func rightBarButtonItemPressed() {
        print("rightBarButtonItemPressed")
    }
}
