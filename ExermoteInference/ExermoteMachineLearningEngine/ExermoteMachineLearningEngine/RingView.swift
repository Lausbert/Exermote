//
//  CircleView.swift
//  ExermoteMachineLearningEngine
//
//  Created by Stephan Lerner on 01.07.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit
@IBDesignable
class RingView:UIView
{
    @IBInspectable var ringColor: UIColor = UIColor.black
        {
        didSet { print("bColor was set here") }
    }
    @IBInspectable var ringThickness: CGFloat = 4
        {
        didSet { print("ringThickness was set here") }
    }
    
    override func draw(_ rect: CGRect)
    {
        let hw:CGFloat = ringThickness/2
        let circlePath = UIBezierPath(ovalIn: rect.insetBy(dx: hw, dy: hw))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = ringColor.cgColor
        shapeLayer.lineWidth = ringThickness
        layer.addSublayer(shapeLayer)
    }
}
