//
//  RecapProtocol.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 06/08/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

protocol RecapCell where Self:UITableViewCell {
    
    var product: Product? { get set }
    var metadata: Metadata? { get }
    
    func updateUI();
}
