//
//  SelectExerciseVC.swift
//  Exermote
//
//  Created by Stephan Lerner on 19.02.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit
import Eureka

class SelectExerciseVC: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "back"), target: self, action: #selector(leftBarButtonItemPressed))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "create"), target: self, action: #selector(rightBarButtonItemPressed))
    }
    
    func leftBarButtonItemPressed() {
        self.navigationController?.pop(transitionType: TRANSITION_TYPE, transitionSubType: kCATransitionFromLeft, duration: TRANSITION_DURATION)
    }
    
    func rightBarButtonItemPressed() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: STORYBOARD_ID_MANAGE_EXERCISE_VC) as UIViewController
        viewController.navigationItem.title = "Create Exercise"
        self.navigationController?.push(viewController: viewController, transitionType: TRANSITION_TYPE, transitionSubType: kCATransitionFromRight, duration: TRANSITION_DURATION)
    }
}

class ManageExerciseVC: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "back"), target: self, action: #selector(leftBarButtonItemPressed))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "delete"), target: self, action: #selector(rightBarButtonItemPressed))
    }
    
    func leftBarButtonItemPressed() {
        self.navigationController?.pop(transitionType: TRANSITION_TYPE, transitionSubType: kCATransitionFromLeft, duration: TRANSITION_DURATION)
    }
    
    func rightBarButtonItemPressed() {
    }
}
