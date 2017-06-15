//
//  CustomButton.swift
//  ExermoteMachineLearningEngine
//
//  Created by Stephan Lerner on 15.06.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 7
    }

}
