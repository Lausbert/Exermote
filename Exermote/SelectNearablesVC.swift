//
//  ViewController.swift
//  Exermote
//
//  Created by Stephan Lerner on 30.10.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import UIKit
import Firebase

class SelectNearablesVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: viewDidLoad() & viewWillAppear
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "record"), target: self, action: #selector(leftBarButtonItemPressed), tintColor: UIColor.red.withAlphaComponent(0.5))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "settings"), target: self, action: #selector(rightBarButtonItemPressed))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReload), name: NSNotification.Name(rawValue: NOTIFICATION_BLE_MANAGER_NEW_PERIPHERALS), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let settingRef = FIRDatabase.database().reference().child(FIREBASE_SETTINGS)
        settingRef.observe(.value, with: { snapshot in
            
            if let settingDict = snapshot.value as? Dictionary<String, Any> {
                if let recording = settingDict[FIREBASE_SETTINGS_RECORDING] as? Bool {
                    if recording {
                        self.leftBarButtonItemPressed()
                    }
                }
                
                if let athleteName = settingDict[USER_DEFAULTS_ATHLETE_NAME] as? String {
                    UserDefaults.standard.set(athleteName, forKey: USER_DEFAULTS_ATHLETE_NAME)
                }
                
                if let recordingDuration = settingDict[USER_DEFAULTS_RECORDING_DURATION] as? Float {
                    UserDefaults.standard.set(recordingDuration, forKey: USER_DEFAULTS_RECORDING_DURATION)
                }
                
                if let recordingFrequency = settingDict[USER_DEFAULTS_RECORDING_FREQUENCY] as? Int {
                    UserDefaults.standard.set(recordingFrequency, forKey: USER_DEFAULTS_RECORDING_FREQUENCY)
                }
            }
        })
        
        let exercisesRef = FIRDatabase.database().reference().child(FIREBASE_EXERCISES)
        exercisesRef.observe(.value, with: { snapshot in
            
            if let exercisesDict = snapshot.value as? Dictionary<String, Any> {
                
                var exercises: [Exercise] = []
                
                for (_, value) in exercisesDict {
                    
                    if let exerciseDict = value as? Dictionary<String, Any> {
                        let exercise = Exercise(exerciseDict: exerciseDict)
                        exercises.append(exercise)
                    }
                }
                
                exercises.sort(by: {$0.name < $1.name})
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: exercises)
                UserDefaults.standard.set(encodedData, forKey: USER_DEFAULTS_EXERCISES)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        shouldReload()
    }
    
    // MARK: tableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BLEManager.instance.iBeaconStates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let iBeaconState = BLEManager.instance.iBeaconStates[safe: indexPath.row] else {return IBeaconStateCell()}
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "iBeaconStateCell") as? IBeaconStateCell {
            cell.configureCell(iBeaconState: iBeaconState)
            return cell
        } else {
            return IBeaconStateCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let iBeaconState = BLEManager.instance.iBeaconStates[safe: indexPath.row] else {return}
        iBeaconState.wasSelected()
        tableView.cellForRow(at: indexPath)?.setSelected(iBeaconState.isSelected, animated: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let iBeaconState = BLEManager.instance.iBeaconStates[safe: indexPath.row] else {return}
        cell.setSelected(iBeaconState.isSelected, animated: false)
    }
    
    func shouldReload() {
        self.tableView.reloadData()
    }
    
    // MARK: Navigation
    
    func leftBarButtonItemPressed() {
        if doesNoExerciseExist() {
            exerciseAlert()
        }
        else if isNoNearableSelected() {
            selectionAlert()
        } else {
            let settingRef = FIRDatabase.database().reference().child(FIREBASE_SETTINGS)
            settingRef.removeAllObservers()
            let settingDict = [FIREBASE_SETTINGS_RECORDING: true]
            settingRef.updateChildValues(settingDict)
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: STORYBOARD_ID_RECORDING_WORKOUT_VC) as UIViewController
            self.navigationController?.push(viewController: viewController, transitionType: TRANSITION_TYPE, transitionSubType: kCATransitionFromLeft, duration: TRANSITION_DURATION)
        }
    }
    
    func isNoNearableSelected() -> Bool {
        let selectedIBeaconStates = BLEManager.instance.iBeaconStates.filter{$0.isSelected}
        return selectedIBeaconStates.isEmpty
    }
    
    func doesNoExerciseExist() -> Bool {
        var exercises: [Exercise] = []
        if let data = UserDefaults.standard.data(forKey: USER_DEFAULTS_EXERCISES) {
            exercises =  NSKeyedUnarchiver.unarchiveObject(with: data) as! [Exercise]
        }
        return exercises.isEmpty
    }
    
    func rightBarButtonItemPressed() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: STORYBOARD_ID_SET_SETTINGS_VC) as UIViewController
        self.navigationController?.push(viewController: viewController, transitionType: TRANSITION_TYPE, transitionSubType: kCATransitionFromRight, duration: TRANSITION_DURATION)
    }
    
        
    // MARK: Alerts
    
    func selectionAlert() {
        let alert = UIAlertController(title: "Warning", message: "Select at least one nearable to be recorded.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func exerciseAlert() {
        let alert = UIAlertController(title: "Warning", message: "Create at least one exercise to be recorded.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
