//
//  ViewController.swift
//  Exermote
//
//  Created by Stephan Lerner on 30.10.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import UIKit

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
    
    override func viewWillAppear(_ animated: Bool) {
        shouldReload()
    }
    
    // MARK: tableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BLEManager.instance.iBeaconStates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let iBeaconState = BLEManager.instance.iBeaconStates[safe: indexPath.row] else {return MeasurementCell()}
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "measurementCell") as? MeasurementCell {
            cell.configureCell(iBeaconState: iBeaconState)
            return cell
        } else {
            return MeasurementCell()
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
        if isAnyNearableSelected() {
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: STORYBOARD_ID_RECORDING_WORKOUT_VC) as UIViewController
            self.navigationController?.push(viewController: viewController, transitionType: TRANSITION_TYPE, transitionSubType: kCATransitionFromLeft, duration: TRANSITION_DURATION)
        } else {
            selectionAlert()
        }
    }
    
    func isAnyNearableSelected() -> Bool {
        let selectedIBeaconStates = BLEManager.instance.iBeaconStates.filter{$0.isSelected}
        return !selectedIBeaconStates.isEmpty
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
}
