//
//  Limousine.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 23/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import Foundation

struct LimousineMetadata: Model, Metadata {
    
    enum CodingKeys: String, CodingKey  {
        case id, car, dropOff = "drop_off", pickUp = "pick_up", time
    }
    
    let id: Int
    let dropOff: String
    let pickUp: String
    let time: Date?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.dropOff = try container.decode(String.self, forKey: .dropOff)
        self.pickUp = try container.decode(String.self, forKey: .pickUp)
        let timeString = try container.decode(String.self, forKey: .time)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        self.time = formatter.date(from: timeString)
    }
}
