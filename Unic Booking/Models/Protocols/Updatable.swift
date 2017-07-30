//
//  Updatable.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 30/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import Foundation

protocol Updatable: Model {
    
    func update(from object: Self);
    
}
