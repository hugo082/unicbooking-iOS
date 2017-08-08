//
//  Airport.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 23/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import Foundation

struct AirportMetadata: Model, Metadata {
    
    struct Codes: Decodable {
        
        let master: String
        let icao: String
        let iata: String
        
    }
    
    struct Airport: Model {
        
        let id: Int
        let name: String
        let codes: Codes
        
    }
    
    struct Flight: Model {
        
        enum CodingKeys: String, CodingKey  {
            case id, codes
            case arrivalTime = "arrival_time", departureTime = "departure_time"
            case origin, destination
        }
        
        let id: Int
        let codes: Codes
        let origin: Airport
        let destination: Airport
        let arrivalTime: Date
        let departureTime: Date
    }
    
    enum CodingKeys: String, CodingKey  {
        case id, flight, flightTransit = "flight_transit"
    }
    
    let id: Int
    let flight: Flight
    let flightTransit: Flight?
    
    var time: Date? {
        return flight.arrivalTime
    }
}
