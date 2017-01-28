//
//  SetSettingsVC.swift
//  Exermote
//
//  Created by Stephan Lerner on 28.01.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit

class SetSettingsVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "backward"), target: self, action: #selector(leftBarButtonItemPressed))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "forward"), target: self, action: #selector(rightBarButtonItemPressed))
    }
    
    func leftBarButtonItemPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func rightBarButtonItemPressed() {
        print("rightBarButtonItemPressed")
    }
}
