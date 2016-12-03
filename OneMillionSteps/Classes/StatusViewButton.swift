//
//  statusViewButton.swift
//  OneMillionSteps
//
//  Created by Rich Long on 02/12/2016.
//  Copyright © 2016 Rich Long. All rights reserved.
//

import UIKit

class StatusViewButton: UIButton {

    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
    }
}
