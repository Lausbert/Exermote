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
    @IBOutlet weak var xAccelerationLbl: UILabel!
    @IBOutlet weak var yAccelerationLbl: UILabel!
    @IBOutlet weak var zAccelerationLbl: UILabel!
    @IBOutlet weak var rssiLbl: UILabel!
    @IBOutlet weak var periodLbl: UILabel!
    
    @IBOutlet weak var ContainerView: MaterialView!
    
    func configureCell(measurementPoint: MeasurementPoint) {
        beaconIdentifierLbl.text = "\(measurementPoint.beaconIdentifier)"
        xAccelerationLbl.text = String(format: "%.2f", measurementPoint.xAcceleration)
        yAccelerationLbl.text = String(format: "%.2f", measurementPoint.yAcceleration)
        zAccelerationLbl.text = String(format: "%.2f", measurementPoint.zAcceleration)
        rssiLbl.text = "\(measurementPoint.rssi)"
        periodLbl.text = String(format: "%.2f", measurementPoint.period)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            ContainerView.backgroundColor = MEASUREMENT_CELL_SELECTED_COLOR
        } else {
            ContainerView.backgroundColor = MEASUREMENT_CELL_DESELECTED_COLOR
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.backgroundColor = UIColor.clear
    }
}
