//
//  UILoadingView.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 29/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class UILoadingView {
    
    static var shared = UILoadingView()
    
    var parentVC: UIViewController?
    var contentAC: UIAlertController?
    
    init() {
        
    }
    
    func presentLoader(_ parentController: UIViewController, message: String) {
        self.parentVC = parentController
        self.contentAC = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let indicatorView = UIActivityIndicatorView(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
        self.contentAC?.view.addSubview(indicatorView)
        self.parentVC?.present(self.contentAC!, animated: true, completion: {
            indicatorView.startAnimating()
        })
    }
    
    func dismissLoader(_ completion: (()->Void)? = nil) {
        self.contentAC?.dismiss(animated: true, completion: completion)
    }
    
    func update(message: String, parentController: UIViewController? = nil) {
        if let controller = self.contentAC  {
            controller.message = message
        } else if let pc = parentController {
            self.presentLoader(pc, message: message)
        }
    }
}
