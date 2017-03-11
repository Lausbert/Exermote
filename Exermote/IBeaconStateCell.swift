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
        } else {
            nearableIdentifierLbl.text = iBeaconState.nearableIdentifier
        }

        frequencyLbl.text = iBeaconState.frequency
        rssiLbl.text = iBeaconState.rssi
        xAccelerationLbl.text = iBeaconState.xAcceleration
        yAccelerationLbl.text = iBeaconState.yAcceleration
        zAccelerationLbl.text = iBeaconState.zAcceleration
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        idView.addGestureRecognizer(tap)
        idView.isUserInteractionEnabled = true
        
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
    
    func handleTap(_ sender: UIGestureRecognizer) {
    
        guard let id = nearableIdentifier else {return}
        
            let alert = UIAlertController(title: "Edit Nearable", message: "Enter a new name.", preferredStyle: .alert)
            alert.addTextField { (textField) in
                if let text = UserDefaults.standard.string(forKey: id) {
                    textField.text = text
                } else {
                    textField.placeholder = "Name"
                }
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let text = alert!.textFields![0].text!
                if text != self.nearableIdentifier && text != "" {
                    UserDefaults.standard.set(text, forKey: id)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_BLE_MANAGER_NEW_PERIPHERALS), object: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                UserDefaults.standard.removeObject(forKey: id)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_BLE_MANAGER_NEW_PERIPHERALS), object: nil)
            }))
            
            self.parentViewController?.present(alert, animated: true, completion: nil)
    }
}
