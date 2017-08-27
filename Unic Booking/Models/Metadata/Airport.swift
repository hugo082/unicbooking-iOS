//
//  Airport.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 23/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

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
        
        enum FlightType: String, Decodable {
            case arrival = "ARR", departure = "DEP"
        }
        
        enum CodingKeys: String, CodingKey  {
            case id, codes, type
            case arrivalTime = "arrival_time", departureTime = "departure_time"
            case origin, destination
        }
        
        let id: Int
        let codes: Codes
        let origin: Airport
        let destination: Airport
        let type: FlightType
        let arrivalTime: Date
        let departureTime: Date
        
        var time: Date {
            return self.type == .arrival ? arrivalTime : departureTime
        }
        
        var icon: UIImage {
            return self.type == .arrival ? #imageLiteral(resourceName: "icn_flight_arrival") : #imageLiteral(resourceName: "icn_flight_departure")
        }
        
        /// Airport where service take place
        var airport: Airport {
            return self.type == .arrival ? destination : origin
        }
    }
    
    enum CodingKeys: String, CodingKey  {
        case id, flight, flightTransit = "flight_transit"
    }
    
    let id: Int
    let flight: Flight
    let flightTransit: Flight?
    
    var time: Date? {
        return flight.time
    }
    
    /// Airport where service take place
    var mainAirport: Airport {
        return self.flight.airport
    }
    
    func configure(alert: UIAlertController) {
        alert.message = "Start time : \(Date().timeString())"
    }
    
    func sendData(product: Product, data: Any?) {}
}
