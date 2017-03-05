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

extension String { //credits to Rob (http://stackoverflow.com/questions/26501276/converting-hex-string-to-nsdata-in-swift)
    
        func dataFromHexadecimalString() -> NSData? {
        let data = NSMutableData(capacity: characters.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, options: [], range: NSMakeRange(0, characters.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)
            data?.append(&num, length: 1)
        }
        
        return data
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

extension Collection where Indices.Iterator.Element == Index { //credits to nkukushkin http://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UINavigationController { //credits to Luca Davanzo http://stackoverflow.com/a/36428937/5722895
    
    func pop(transitionType type: String = kCATransitionPush, transitionSubType subType: String = kCATransitionFromRight, duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, transitionSubType: subType, duration: duration)
        self.popViewController(animated: false)
    }
    
    func push(viewController vc: UIViewController, transitionType type: String = kCATransitionPush, transitionSubType subType: String = kCATransitionFromRight, duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, transitionSubType: subType, duration: duration)
        self.pushViewController(vc, animated: false)
    }
    
    private func addTransition(transitionType type: String = kCATransitionPush, transitionSubType subType: String = kCATransitionFromRight, duration: CFTimeInterval = 0.3) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = type
        transition.subtype = subType
        self.view.layer.add(transition, forKey: nil)
    }
}

extension Array { // credits to Phae Deepsky http://stackoverflow.com/a/24101606/5722895
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

extension Double { // http://stackoverflow.com/a/39172194/5722895
    private static let arc4randomMax = Double(UInt32.max)
    
    static func random0to1() -> Double {
        return Double(arc4random()) / arc4randomMax
    }
}
