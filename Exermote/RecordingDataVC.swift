//
//  RecordingDataVC.swift
//  Exermote
//
//  Created by Stephan Lerner on 31.01.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit

class RecordingDataVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

         self.navigationItem.leftBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "cancel"), target: self, action: #selector(leftBarButtonItemPressed))
    }
    
    func leftBarButtonItemPressed() {
        cancelAlert()
    }
    
    func cancelAlert() {
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to stop recording? All unsaved data will be lost.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Continue", style: .default))
        alert.addAction(UIAlertAction(title: "Stop", style: .destructive, handler: { (action) in
            _ = self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
