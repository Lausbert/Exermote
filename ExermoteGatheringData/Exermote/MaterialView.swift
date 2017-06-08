//
//  MaterialView.swift
//  LausNet
//
//  Created by Stephan Lerner on 21.10.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import UIKit

class MaterialView: UIView {

    override func awakeFromNib() {
        layer.cornerRadius = 5.0
        layer.shadowColor = COLOR_SHADOW
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    }

}
