//
//  UTTextField.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 19/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class UTTextField: UITextField {
    
    var borderWidth: CGFloat = 1.0
    var borderColor: CGColor = UIColor.darkGray.cgColor
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let border = CALayer()
        border.borderWidth = self.borderWidth
        border.borderColor = self.borderColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - self.borderWidth, width:  self.frame.size.width, height: self.frame.size.height)
        
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        self.borderStyle = UITextBorderStyle.none
    }

}
