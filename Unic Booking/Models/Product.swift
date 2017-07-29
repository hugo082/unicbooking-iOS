//
//  Product.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 23/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import Foundation

class Product: Model {
    
    enum CodingKeys: String, CodingKey  {
        case id, type, airport, limousine, train, execution, baggage, note
        case passengers = "customers"
    }
    
    let id: Int
    let type: Base
    let airport: AirportMetadata?
    let limousine: LimousineMetadata?
    let train: TrainMetadata?
    let note: String?
    let execution: Execution
    let passengers: [Passenger]
    let baggage: Int
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.type = try container.decode(Base.self, forKey: .type)
        self.note = try container.decodeIfPresent(String.self, forKey: .note)
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
        
        struct Service: Model {
            
            enum CodingKeys: String, CodingKey  {
                case id, name, type, iconCode = "icon_code"
            }
            
            let id: Int
            let name: String
            let type: String
            let iconCode: String
        }
        
        enum CodingKeys: String, CodingKey  {
            case id, name, service
        }
        
        let id: Int
        let name: String
        let service: Service
    }
    struct Passenger: Model {
        let id: Int
        let firstName: String
        let lastName: String
    }
}
