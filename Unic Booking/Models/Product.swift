//
//  Product.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 23/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class Product: Model {
    
    enum CodingKeys: String, CodingKey  {
        case id, type, airport, limousine, train, execution, baggage, note, date
        case passengers = "customers"
    }
    
    let id: Int
    let type: Base
    let airport: AirportMetadata?
    let limousine: LimousineMetadata?
    let train: TrainMetadata?
    let note: String?
    let date: Date
    let execution: Execution
    let passengers: [Passenger]
    let baggage: Int
    
    var isAirport: Bool {
        return self.type.service.type == .airport
    }
    var isLimousine: Bool {
        return self.type.service.type == .limousine
    }
    var isTrain: Bool {
        return self.type.service.type == .train
    }
    var time: Date? {
        switch self.type.service.type {
        case .airport:
            return self.airport?.time
        case .train:
            return self.train?.time
        case .limousine:
            return self.limousine?.time
        }
    }
    var icon: UIImage {
        switch self.type.service.type {
        case .airport:
            return #imageLiteral(resourceName: "icn_flight_arrival")
        case .train:
            return #imageLiteral(resourceName: "icn_train")
        case .limousine:
            return #imageLiteral(resourceName: "icn_car")
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.type = try container.decode(Base.self, forKey: .type)
        self.note = try container.decodeIfPresent(String.self, forKey: .note)
        self.date = try container.decode(Date.self, forKey: .date)
        self.baggage = try container.decode(Int.self, forKey: .baggage)
        self.passengers = try container.decode([Passenger].self, forKey: .passengers)
        self.execution = try container.decode(Execution.self, forKey: .execution)
        self.airport = try container.decodeIfPresent(AirportMetadata.self, forKey: .airport)
        self.train = try container.decodeIfPresent(TrainMetadata.self, forKey: .train)
        self.limousine = try container.decodeIfPresent(LimousineMetadata.self, forKey: .limousine)
    }
}


extension Product {
    
    struct Base: Model {
        
        enum CodingKeys: String, CodingKey  {
            case id, name, service
        }
        
        let id: Int
        let name: String
        let service: Service
    }
    struct Passenger: Model {
        
        enum CodingKeys: String, CodingKey  {
            case id, firstName = "first_name", lastName = "last_name"
        }
        
        let id: Int
        let firstName: String
        let lastName: String
        
        var fullName: String {
            return firstName + " " + lastName
        }
    }
}

extension Product.Base {
    
    struct Service: Model {
        
        enum ServiceType: String, Decodable {
            case train = "Train"
            case airport = "Airport"
            case limousine = "Limousine"
        }
        
        enum CodingKeys: String, CodingKey  {
            case id, name, type, iconCode = "icon_code"
        }
        
        let id: Int
        let name: String
        let type: ServiceType
        let iconCode: String
    }
}
