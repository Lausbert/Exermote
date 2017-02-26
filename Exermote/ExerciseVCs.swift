//
//  SelectExerciseVC.swift
//  Exermote
//
//  Created by Stephan Lerner on 19.02.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit
import Eureka

class ManageExerciseVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var exercises: [Exercise] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "back"), target: self, action: #selector(leftBarButtonItemPressed))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "create"), target: self, action: #selector(rightBarButtonItemPressed))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let data = UserDefaults.standard.data(forKey: USER_DEFAULTS_EXERCISES) {
            exercises =  NSKeyedUnarchiver.unarchiveObject(with: data) as! [Exercise]
            }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        }
        
        cell!.textLabel?.text = exercises[indexPath.row].name
        cell!.accessoryType = .disclosureIndicator
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: STORYBOARD_ID_EDIT_EXERCISE_VC) as! EditExerciseVC
        viewController.navigationItem.title = "Create Exercise"
        viewController.exercises = exercises
        viewController.selectedExerciseIndex = indexPath.row
        self.navigationController?.push(viewController: viewController, transitionType: TRANSITION_TYPE, transitionSubType: kCATransitionFromRight, duration: TRANSITION_DURATION)
    }
    
    func leftBarButtonItemPressed() {
        self.navigationController?.pop(transitionType: TRANSITION_TYPE, transitionSubType: kCATransitionFromLeft, duration: TRANSITION_DURATION)
    }
    
    func rightBarButtonItemPressed() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: STORYBOARD_ID_EDIT_EXERCISE_VC) as! EditExerciseVC
        viewController.navigationItem.title = "Edit Exercise"
        viewController.exercises = exercises
        self.navigationController?.push(viewController: viewController, transitionType: TRANSITION_TYPE, transitionSubType: kCATransitionFromRight, duration: TRANSITION_DURATION)
    }
}

class EditExerciseVC: FormViewController {
    
    var exercises: [Exercise]!
    var selectedExerciseIndex: Int?
    
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
                $0.value = true
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
        
        if let index = selectedExerciseIndex {
            form.setValues(exercises[index].dictionary)
        }
    }
        
    func leftBarButtonItemPressed() {
        
        if let index = selectedExerciseIndex {
            exercises.remove(at: index)
        }
        
        let exerciseDict = form.values()
        
        if !exerciseDict.values.contains(where: {$0 == nil}) {
            
            let exercise = Exercise(exerciseDict: exerciseDict)
            exercises.append(exercise)
            exercises.sort(by: {$0.name < $1.name})
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: exercises)
            UserDefaults.standard.set(encodedData, forKey: USER_DEFAULTS_EXERCISES)
            
            self.navigationController?.pop(transitionType: TRANSITION_TYPE, transitionSubType: kCATransitionFromLeft, duration: TRANSITION_DURATION)
        } else {
            saveAlert()
        }
    }
    
    func rightBarButtonItemPressed() {
        cancelAlert()
    }
    
    func saveAlert() {
        let alert = UIAlertController(title: "Warning", message: "Please complete exercise information.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func cancelAlert() {
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete exercise", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            if let index = self.selectedExerciseIndex {
                self.exercises.remove(at: index)
            }
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.exercises)
            UserDefaults.standard.set(encodedData, forKey: USER_DEFAULTS_EXERCISES)
            self.navigationController?.pop(transitionType: TRANSITION_TYPE, transitionSubType: kCATransitionFromLeft, duration: TRANSITION_DURATION)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
