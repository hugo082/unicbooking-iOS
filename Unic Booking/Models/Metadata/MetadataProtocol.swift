//
//  MetadataProtocol.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 06/08/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import Foundation
import UIKit

protocol Metadata {
    
    var time: Date? { get }
    
    func configure(alert: UIAlertController)
    func sendData(product: Product, data: Any?)
}
