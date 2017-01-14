//
//  ViewController.swift
//  Excermote
//
//  Created by Stephan Lerner on 30.10.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import UIKit

class MeasurementVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReload), name: NSNotification.Name(rawValue: "newPeripherals"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "measurementCell")! as UITableViewCell
        
        let measurementPoint = BLEManager.instance.measurementPoints[indexPath.row]
        cell.textLabel?.text = ("\(measurementPoint.beaconIdentifier), x'': \(measurementPoint.xAcceleration), y'':  \(measurementPoint.yAcceleration), z'': \(measurementPoint.zAcceleration)")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return BLEManager.instance.measurementPoints.count
    }
    
    func shouldReload() {
        self.tableView.reloadData()
    }
}
