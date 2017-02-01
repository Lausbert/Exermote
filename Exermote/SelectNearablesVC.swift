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
        
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReload), name: NSNotification.Name(rawValue: "newPeripherals"), object: nil)
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
            //stop recording
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func rightBarButtonItemPressed() {
        performSegue(withIdentifier: SEGUE_SET_SETTINGS, sender: nil)
    }
}
