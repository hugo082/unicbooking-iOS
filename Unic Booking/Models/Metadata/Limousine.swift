//
//  Limousine.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 23/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import Foundation

struct LimousineMetadata: Model {
    
    struct Car: Model {
        let id: Int
        let name: String
    }
    
    enum CodingKeys: String, CodingKey  {
        case id, car, dropOff = "drop_off", pickUp = "pick_up"
    }
    
    let id: Int
    let car: Car
    let dropOff: String
    let pickUp: String
    
    // TODO: Support time
    var time: Date {
        return Date()
    }
}
