//
//  StatusSquare.swift
//  OneMillionSteps
//
//  Created by Rich Long on 02/12/2016.
//  Copyright © 2016 Rich Long. All rights reserved.
//


import UIKit

class StatusSquare:UIView {
    
    let titleLabel:UILabel = UILabel()
    let amountLabel:UILabel = UILabel()
    let imageView:UIImageView = UIImageView()
    var chartView:PieChart? = nil
    
    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addTitleLabelConstraints()
        addAmountLabelConstraints()
        addImageViewConstraints()

        self.titleLabel.text = "Title"
        self.amountLabel.text = "Title"
    }
    
    func addPieChart(withPercentage:Int) {

        if let existingChartView = chartView {
            existingChartView.removeFromSuperview()
            chartView = nil
        }
        
        let chart = PieChart()
        chart.chartPercentage = withPercentage
        
        chartView = chart
        chart.backgroundColor = UIColor.clear
        chart.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(chart)
        
        // align titleLabel from the left
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": chart]));
        
        // align titleLabel from the top
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[view]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": chart]));


//        chartView.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(chartView)
//        
//        chartView.backgroundColor = UIColor.white
//        
//        let centreX = (self.frame.size.width) / 2
//        let centreY = (self.frame.size.height) / 2
//
//        let endAngle = (CGFloat(M_PI * 2) / 100) * CGFloat(withPercentage)
//        let circlePath = UIBezierPath(arcCenter: CGPoint(x: -centreY,y: centreX),
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
//        self.chartView.layer.addSublayer(shapeLayer)
//        
//        //Rotate view to start at 12 o'clock
//        let degrees = CGFloat(270) * CGFloat(M_PI/180)  //the value in degrees
//        chartView.transform = CGAffineTransform(rotationAngle: degrees)
        
    }
    
    internal func addTitleLabelConstraints() {
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        
        // align titleLabel from the left
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": titleLabel]));
        
        // align titleLabel from the top
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[view]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": titleLabel]));

    }
    
    internal func addAmountLabelConstraints() {
        
        amountLabel.textColor = UIColor.white
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(amountLabel)
        
        amountLabel.textAlignment = .center
        
        // align titleLabel from the left
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": amountLabel]));
        
        // align titleLabel from the top
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view]-5-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": amountLabel]));
        
    }
    
    internal func addImageViewConstraints() {
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)

        // center titleLabel horizontally in self.view
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0));
        
        
        // center titleLabel vertically in self.view
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0));

        
        // width constraint
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view(==20)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": imageView]));
        
        // height constraint
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view(==20)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": imageView]));
        
    }

}
