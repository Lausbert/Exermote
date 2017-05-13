//
//  IBeaconStateCell.swift
//  Exermote
//
//  Created by Stephan Lerner on 14.01.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit

class IBeaconStateCell: UITableViewCell {

    @IBOutlet weak var nearableIdentifierLbl: UILabel!
    @IBOutlet weak var xAccelerationLbl: UILabel!
    @IBOutlet weak var yAccelerationLbl: UILabel!
    @IBOutlet weak var zAccelerationLbl: UILabel!
    @IBOutlet weak var rssiLbl: UILabel!
    @IBOutlet weak var frequencyLbl: UILabel!
    @IBOutlet weak var idView: UIView!
    
    @IBOutlet weak var ContainerView: MaterialView!
    @IBOutlet weak var editImgView: UIImageView!
    
    private var nearableIdentifier: String!
    
    func configureCell(iBeaconState: IBeaconState) {
        
        nearableIdentifier = iBeaconState.nearableIdentifier
        
        if let text = UserDefaults.standard.string(forKey: nearableIdentifier) {
            nearableIdentifierLbl.text = text
            if !iBeaconState.isSelected {
                iBeaconState.wasSelected()
            }
        } else {
            if iBeaconState.isSelected {
                iBeaconState.wasSelected()
            }
            nearableIdentifierLbl.text = iBeaconState.nearableIdentifier
        }

        frequencyLbl.text = iBeaconState.frequency
        rssiLbl.text = iBeaconState.rssi
        xAccelerationLbl.text = iBeaconState.xAcceleration
        yAccelerationLbl.text = iBeaconState.yAcceleration
        zAccelerationLbl.text = iBeaconState.zAcceleration
        
        let image = UIImage(named: "edit")
        let editImage = image?.withRenderingMode(.alwaysTemplate)
        editImgView.image = editImage
        editImgView.tintColor = UIColor.white
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
