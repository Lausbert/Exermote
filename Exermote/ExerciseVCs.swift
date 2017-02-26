//
//  SelectExerciseVC.swift
//  Exermote
//
//  Created by Stephan Lerner on 19.02.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit
import Eureka

class SelectExerciseVC: UIViewController {
    
    var exercises: [Exercise] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "back"), target: self, action: #selector(leftBarButtonItemPressed))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "create"), target: self, action: #selector(rightBarButtonItemPressed))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let data = UserDefaults.standard.data(forKey: USER_DEFAULTS_EXERCISES) {
            exercises =  NSKeyedUnarchiver.unarchiveObject(with: data) as! [Exercise]
            }
        
    }
    
    func leftBarButtonItemPressed() {
        self.navigationController?.pop(transitionType: TRANSITION_TYPE, transitionSubType: kCATransitionFromLeft, duration: TRANSITION_DURATION)
    }
    
    func rightBarButtonItemPressed() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: STORYBOARD_ID_MANAGE_EXERCISE_VC) as! ManageExerciseVC
        viewController.navigationItem.title = "Create Exercise"
        viewController.exercises = exercises
        self.navigationController?.push(viewController: viewController, transitionType: TRANSITION_TYPE, transitionSubType: kCATransitionFromRight, duration: TRANSITION_DURATION)
    }
}

class ManageExerciseVC: FormViewController {
    
    var exercises: [Exercise]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "back"), target: self, action: #selector(leftBarButtonItemPressed))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "delete"), target: self, action: #selector(rightBarButtonItemPressed))
        
        form +++ Section()
            <<< TextRow(){
                $0.title = "Name"
                $0.placeholder = "Exercise Name"
                $0.tag = EXERCISE_ATTRIBUTES[0]
            }
            <<< CheckRow(){
                $0.title = "Included in Workout"
                $0.tag = EXERCISE_ATTRIBUTES[1]
            }
            +++ Section("Repetition Durations")
            <<< DecimalRow(){
                $0.title = "Maximum"
                $0.placeholder = "Duration"
                $0.tag = EXERCISE_ATTRIBUTES[2]
            }
            <<< DecimalRow(){
                $0.title = "Minimum"
                $0.placeholder = "Duration"
                $0.tag = EXERCISE_ATTRIBUTES[3]
            }
            <<< SliderRow(){
                $0.title = "First Half / Second Half"
                $0.minimumValue = 0.0
                $0.maximumValue = 1.0
                $0.steps = 10
                $0.value = 0.5
                $0.tag = EXERCISE_ATTRIBUTES[4]
            }
            +++ Section("Break Durations")
            <<< DecimalRow(){
                $0.title = "Repetition"
                $0.placeholder = "Duration"
                $0.tag = EXERCISE_ATTRIBUTES[5]
            }
            <<< DecimalRow(){
                $0.title = "Set"
                $0.placeholder = "Duration"
                $0.tag = EXERCISE_ATTRIBUTES[6]
            }
            <<< DecimalRow(){
                $0.title = "Exercise"
                $0.placeholder = "Duration"
                $0.tag = EXERCISE_ATTRIBUTES[7]
            }
        }
        
    func leftBarButtonItemPressed() {
        
        let exerciseDict = form.values()
        
        if !exerciseDict.values.contains(where: {$0 == nil}) {
            
            let exercise = Exercise(exerciseDict: exerciseDict)
            exercises.append(exercise)
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: exercises)
            UserDefaults.standard.set(encodedData, forKey: USER_DEFAULTS_EXERCISES)
            
            self.navigationController?.pop(transitionType: TRANSITION_TYPE, transitionSubType: kCATransitionFromLeft, duration: TRANSITION_DURATION)
        } else {
            saveAlert()
        }
    }
    
    func rightBarButtonItemPressed() {
    }
    
    func saveAlert() {
        let alert = UIAlertController(title: "Warning", message: "Please complete exercise information.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
