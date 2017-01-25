//
//  MeasurementCell.swift
//  Exermote
//
//  Created by Stephan Lerner on 14.01.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit

class MeasurementCell: UITableViewCell {

    @IBOutlet weak var beaconIdentifierLbl: UILabel!
    @IBOutlet weak var companyIdentifierLbl: UILabel!
    @IBOutlet weak var xAccelerationLbl: UILabel!
    @IBOutlet weak var yAccelerationLbl: UILabel!
    @IBOutlet weak var zAccelerationLbl: UILabel!
    @IBOutlet weak var durationCurrentStateLbl: UILabel!
    @IBOutlet weak var durationPreviousStateLbl: UILabel!
    @IBOutlet weak var rssiLbl: UILabel!
    
    func configureCell(measurementPoint: MeasurementPoint) {
        beaconIdentifierLbl.text = "Beacond ID: \(measurementPoint.beaconIdentifier)"
        companyIdentifierLbl.text = "Company ID: \(measurementPoint.companyIdentifier)"
        xAccelerationLbl.text = String(format: "x: %.2f", measurementPoint.xAcceleration)
        yAccelerationLbl.text = String(format: "y: %.2f", measurementPoint.yAcceleration)
        zAccelerationLbl.text = String(format: "z: %.2f", measurementPoint.zAcceleration)
        durationCurrentStateLbl.text = "Current State: \(measurementPoint.durationCurrentState)"
        durationPreviousStateLbl.text = "Previous State: \(measurementPoint.durationPreviousState)"
        rssiLbl.text = "RSSI: \(measurementPoint.rssi)"
    }

}
