//
//  ViewController.swift
//  Exermote
//
//  Created by Stephan Lerner on 30.10.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import UIKit
import SwiftSpinner

class SelectNearablesVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "record"), target: self, action: #selector(leftBarButtonItemPressed), tintColor: UIColor.red.withAlphaComponent(0.5))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "settings"), target: self, action: #selector(rightBarButtonItemPressed))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReload), name: NSNotification.Name(rawValue: NOTIFICATION_BLE_MANAGER_NEW_PERIPHERALS), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return BLEManager.instance.measurementPoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let measurementPoint = BLEManager.instance.measurementPoints[indexPath.row]
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "measurementCell") as? MeasurementCell {
            cell.configureCell(measurementPoint: measurementPoint)
            return cell
        } else {
            return MeasurementCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let measurementPoint = BLEManager.instance.measurementPoints[indexPath.row]
        measurementPoint.wasSelected()
        tableView.cellForRow(at: indexPath)?.setSelected(measurementPoint.isSelected, animated: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let measurementPoint = BLEManager.instance.measurementPoints[indexPath.row]
        cell.setSelected(measurementPoint.isSelected, animated: false)
    }
    
    func shouldReload() {
        self.tableView.reloadData()
    }
    
    func leftBarButtonItemPressed() {
        if isAnyNearableSelected() {
            RecordingManager.instance.attemptRecording() {success in
                if success {
                    NotificationCenter.default.addObserver(self, selector: #selector(self.updateSwiftSpinner), name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_SWIFT_SPINNER_UPDATE_NEEDED), object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(self.recordingStopped), name: NSNotification.Name(rawValue: NOTIFICATION_RECORDING_MANAGER_RECORDING_STOPPED), object: nil)
                    self.showSwiftSpinner()
                }
            }
        } else {
            selectionAlert()
        }
    }
    
    func rightBarButtonItemPressed() {
        performSegue(withIdentifier: SEGUE_SET_SETTINGS, sender: nil)
    }
    
    func updateSwiftSpinner() {
        SwiftSpinner.sharedInstance.titleLabel.text = RecordingManager.instance.remainingRecordingDurationInMinutes
    }
    
    func recordingStopped() {
        SwiftSpinner.hide()
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelAlert() {
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to stop recording? All unsaved data will be lost.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
            self.showSwiftSpinner()
        }))
        alert.addAction(UIAlertAction(title: "Stop", style: .destructive, handler: { (action) in
            RecordingManager.instance.stopRecording(success: false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showSwiftSpinner(){
        SwiftSpinner.setTitleFont(UIFont(name: "NotoSans", size: 22.0))
        let title = RecordingManager.instance.remainingRecordingDurationInMinutes
        SwiftSpinner.show(title).addTapHandler({
            SwiftSpinner.hide()
            self.cancelAlert()
        }, subtitle: "Tap to cancel recording")
    }
    
    func selectionAlert() {
        let alert = UIAlertController(title: "Warning", message: "Select at least one nearable to be recorded.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func isAnyNearableSelected() -> Bool {
        let selectedMeasurementPoints = BLEManager.instance.measurementPoints.filter{$0.isSelected}
        return !selectedMeasurementPoints.isEmpty
    }
}
