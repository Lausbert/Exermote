//
//  RecordingDataVC.swift
//  Exermote
//
//  Created by Stephan Lerner on 31.01.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit
import SwiftSpinner

class RecordingDataVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        SwiftSpinner.setTitleFont(UIFont(name: "NotoSans", size: 22.0))
        SwiftSpinner.show("Recording").addTapHandler({
            SwiftSpinner.hide()
            self.cancelAlert()
        })
    }
    
    func cancelAlert() {
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to stop recording? All unsaved data will be lost.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
            SwiftSpinner.show("Recording").addTapHandler({
                SwiftSpinner.hide()
                self.cancelAlert()
            })
        }))
        alert.addAction(UIAlertAction(title: "Stop", style: .destructive, handler: { (action) in
            self.navigationController?.navigationBar.isHidden = false
            _ = self.navigationController?.popViewController(animated: false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
