//
//  PieChart.swift
//  OneMillionSteps
//
//  Created by Rich Long on 02/12/2016.
//  Copyright © 2016 Rich Long. All rights reserved.
//

import UIKit

class PieChart: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var chartPercentage = 0

//    init(withPercentage:Int) {
//        super.init()
//        chartPercentage = withPercentage
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    override func draw(_ rect: CGRect) {

        self.backgroundColor = UIColor.white
        
        let backgroundArc = createArc(percentage: 100)
        backgroundArc.opacity = 0.5
        
        self.layer.addSublayer(backgroundArc)
        
        let mainArc = createArc(percentage: chartPercentage)
        self.layer.addSublayer(mainArc)


//        let centreX = (self.frame.size.width) / 2
//        let centreY = (self.frame.size.height) / 2
//        
//        let endAngle = (CGFloat(M_PI * 2) / 100) * CGFloat(chartPercentage)
//        let circlePath = UIBezierPath(arcCenter: CGPoint(x: centreY,y: centreX),
//                                      radius: CGFloat(50),
//                                      startAngle: CGFloat(0),
//                                      endAngle:endAngle,
//                                      clockwise: true)
//        
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = circlePath.cgPath
//        
//        //change the fill color
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        //you can change the stroke color
//        shapeLayer.strokeColor = UIColor.white.cgColor
//        //you can change the line width
//        shapeLayer.lineWidth = 20.0
//        
//        self.layer.addSublayer(shapeLayer)
        

        //Rotate view to start at 12 o'clock
        let degrees = CGFloat(270) * CGFloat(M_PI/180)  //the value in degrees
        self.transform = CGAffineTransform(rotationAngle: degrees)
    }
    
    internal func createArc(percentage:Int) -> CAShapeLayer {
        
        let centreX = (self.frame.size.width) / 2
        let centreY = (self.frame.size.height) / 2
        
        let endAngle = (CGFloat(M_PI * 2) / 100) * CGFloat(percentage)
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: centreY,y: centreX),
                                      radius: CGFloat(50),
                                      startAngle: CGFloat(0),
                                      endAngle:endAngle,
                                      clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        //change the fill color
        shapeLayer.fillColor = UIColor.clear.cgColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor.white.cgColor
        //you can change the line width
        shapeLayer.lineWidth = 20.0
        
        return shapeLayer
    
    }

}
