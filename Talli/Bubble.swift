//
//  Bubble.swift
//  Talli
//
//  Created by James Boric on 28/12/2015.
//  Copyright © 2015 Ode To Code. All rights reserved.
//

import UIKit

class Bubble: UIView {

    
    let circle = CAShapeLayer()
    override func drawRect(rect: CGRect) {
    
        let path = UIBezierPath(ovalInRect: rect)
        circle.path = path.CGPath
        circle.fillColor = UIColor.blackColor().CGColor
        
        layer.addSublayer(circle)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.duration = 0.35
        let downSize: CGFloat = 20
        pathAnimation.fillMode = kCAFillModeForwards
        pathAnimation.removedOnCompletion = false
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        pathAnimation.toValue = UIBezierPath(ovalInRect: CGRectMake(downSize, downSize, bounds.size.width - downSize * 2, bounds.size.height - downSize * 2)).CGPath
        circle.addAnimation(pathAnimation, forKey: "path")
        // circle.path = UIBezierPath(ovalInRect: CGRectMake(downSize, downSize, bounds.size.width - downSize * 2, bounds.size.height - downSize * 2)).CGPath

    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        

        print("Hello, touches ended")
    }
}
