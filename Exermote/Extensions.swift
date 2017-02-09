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
    class func itemWith(colorfulImage: UIImage?, target: AnyObject, action: Selector, tintColor: UIColor = UIColor.darkGray) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        let buttonImage = colorfulImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(buttonImage, for: .normal)
        button.tintColor = tintColor
        button.frame = CGRect(x:0,y:0,width:35.0,height:35.0)
        button.addTarget(target, action: action, for: .touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }
}

extension String {
    subscript (r: CountableClosedRange<Int>) -> String {
        get {
            let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
            return self[startIndex...endIndex]
        }
    }
}
