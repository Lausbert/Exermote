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
        tableView.reloadData()
    }
    
    // MARK: tableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BLEManager.instance.measurementPoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let measurementPoint = BLEManager.instance.measurementPoints[safe: indexPath.row] else {return MeasurementCell()}
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "measurementCell") as? MeasurementCell {
            cell.configureCell(measurementPoint: measurementPoint)
            return cell
        } else {
            return MeasurementCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let measurementPoint = BLEManager.instance.measurementPoints[safe: indexPath.row] else {return}
        measurementPoint.wasSelected()
        tableView.cellForRow(at: indexPath)?.setSelected(measurementPoint.isSelected, animated: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let measurementPoint = BLEManager.instance.measurementPoints[safe: indexPath.row] else {return}
        cell.setSelected(measurementPoint.isSelected, animated: false)
    }
    
    func shouldReload() {
        self.tableView.reloadData()
    }
    
    // MARK: Navigation
    
    func leftBarButtonItemPressed() {
        if isAnyNearableSelected() {
            performSegue(withIdentifier: SEGUE_RECORDING_WORKOUT, sender: nil)
        } else {
            selectionAlert()
        }
    }
    
    func isAnyNearableSelected() -> Bool {
        let selectedMeasurementPoints = BLEManager.instance.measurementPoints.filter{$0.isSelected}
        return !selectedMeasurementPoints.isEmpty
    }
    
    func rightBarButtonItemPressed() {
        performSegue(withIdentifier: SEGUE_SET_SETTINGS, sender: nil)
    }
    
        
    // MARK: Alerts
    
    func selectionAlert() {
        let alert = UIAlertController(title: "Warning", message: "Select at least one nearable to be recorded.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
