//
//  Extensions.swift
//  Exermote
//
//  Created by Stephan Lerner on 30.10.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import Foundation
import UIKit

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension UIBarButtonItem { //credits to Jovan Stankovic and Mihriban Minaz
    class func itemWith(colorfulImage: UIImage?, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        let buttonImage = colorfulImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(buttonImage, for: .normal)
        button.tintColor = UIColor.darkGray
        button.frame = CGRect(x:0,y:0,width:35.0,height:35.0)
        button.addTarget(target, action: action, for: .touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }
}
