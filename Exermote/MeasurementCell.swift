//
//  MeasurementCell.swift
//  Exermote
//
//  Created by Stephan Lerner on 14.01.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit

class MeasurementCell: UITableViewCell {

    @IBOutlet weak var nearableIdentifierLbl: UILabel!
    @IBOutlet weak var xAccelerationLbl: UILabel!
    @IBOutlet weak var yAccelerationLbl: UILabel!
    @IBOutlet weak var zAccelerationLbl: UILabel!
    @IBOutlet weak var rssiLbl: UILabel!
    @IBOutlet weak var frequencyLbl: UILabel!
    
    @IBOutlet weak var ContainerView: MaterialView!
    
    func configureCell(measurementPoint: MeasurementPoint) {
        nearableIdentifierLbl.text = measurementPoint.nearableIdentifier
        frequencyLbl.text = measurementPoint.frequency
        rssiLbl.text = measurementPoint.rssi
        xAccelerationLbl.text = measurementPoint.xAcceleration
        yAccelerationLbl.text = measurementPoint.yAcceleration
        zAccelerationLbl.text = measurementPoint.zAcceleration
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            ContainerView.backgroundColor = COLOR_HIGHLIGHTED
        } else {
            ContainerView.backgroundColor = COLOR_NOT_HIGHLIGHTED
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.backgroundColor = UIColor.clear
    }
}
