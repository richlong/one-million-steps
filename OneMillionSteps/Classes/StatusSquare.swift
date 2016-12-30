//
//  StatusSquare.swift
//  OneMillionSteps
//
//  Created by Rich Long on 02/12/2016.
//  Copyright © 2016 Rich Long. All rights reserved.
//


import UIKit

class StatusSquare:UIView {
    
    let iconLabel:UILabel = UILabel()
    let titleLabel:UILabel = UILabel()
    let amountLabel:UILabel = UILabel()
    let imageView:UIImageView = UIImageView()
    internal let activityView = UIActivityIndicatorView()
    var chartView:PieChart? = nil
    
    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addTitleLabelConstraints()
        addAmountLabelConstraints()
        addImageViewConstraints()
        addActivityView()
        addIconLabel()
        self.titleLabel.text = "Title"
        self.amountLabel.text = "Title"
    }
    
    internal func addActivityView() {
        
        activityView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityView)

        // center titleLabel horizontally in self.view
        self.addConstraint(NSLayoutConstraint(item: activityView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0));
        
        
        // center titleLabel vertically in self.view
        self.addConstraint(NSLayoutConstraint(item: activityView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0));
        
        activityView.isHidden = true

    }
    
    internal func addIconLabel() {
        
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(iconLabel)
        iconLabel.font = UIFont(fa_fontSize: 50)
        iconLabel.textColor = UIColor.white
        iconLabel.textAlignment = .center

        // center titleLabel horizontally in self.view
        self.addConstraint(NSLayoutConstraint(item: iconLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0));
        
        
        // center titleLabel vertically in self.view
        self.addConstraint(NSLayoutConstraint(item: iconLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0));
        
        // align titleLabel from the left
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view(50)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": iconLabel]));
        
        // align titleLabel from the top
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view(50)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": iconLabel]));

    }

    
    func showActivityView() {
        activityView.isHidden = false
        activityView.startAnimating()
    }
    
    func hideActivityView() {
        activityView.isHidden = true
        activityView.stopAnimating()
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
