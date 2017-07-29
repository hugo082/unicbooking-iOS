//
//  Airport.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 23/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import Foundation

struct AirportMetadata: Model {
    
    struct Flight: Model {
        
        enum CodingKeys: String, CodingKey  {
            case id, arrivalTime = "arrival_time", departureTime = "departure_time"
        }
        
        let id: Int
//        let code: String
        let arrivalTime: Date
        let departureTime: Date
    }
    
    enum CodingKeys: String, CodingKey  {
        case id, flight, flightTransit = "flight_transit", code
    }
    
    let id: Int
    let flight: Flight
    let flightTransit: Flight?
    let code: String
}
