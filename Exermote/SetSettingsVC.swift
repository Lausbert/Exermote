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
                $0.title = "Frequency [Hz]"
                $0.minimumValue = 0.2
                $0.maximumValue = 10.0
                $0.steps = 98
                $0.minimumTrackTintColor = COLOR_HIGHLIGHTED
                
            }
            <<< StepperRow(){
                $0.title = "Duration [min]"
            }
            +++ Section("Recorded Data")
            <<< TextRow(){
                $0.title = "bla"
        }
    }
    
    func leftBarButtonItemPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func rightBarButtonItemPressed() {
        print("rightBarButtonItemPressed")
    }
}
