//
//  Product.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 23/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class Product: Model, Updatable {
    
    static let kSharedId = "product_shared_id"
    static var shared: Product? = nil
    
    static func load() {
        let defaults = UserDefaults.standard
        if let id = defaults.object(forKey: kSharedId) as? Int {
            DataManager.shared.productManager.getData(with: id, completionHandler: { (product, error) in
                Product.shared = product
            })
        }
    }
    
    enum CodingKeys: String, CodingKey  {
        case id, type, airport, limousine, train
        case location, execution, baggage, note, date
        case passengers = "customers"
    }
    
    let id: Int
    var type: Base
    var airport: AirportMetadata?
    var limousine: LimousineMetadata?
    var train: TrainMetadata?
    var location: String
    var note: String?
    var date: Date
    var execution: Execution
    var passengers: [Passenger]
    var baggage: Int
    
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
            return self.airport?.flight.icon ?? #imageLiteral(resourceName: "icn_flight_arrival")
        case .train:
            return #imageLiteral(resourceName: "icn_train")
        case .limousine:
            return #imageLiteral(resourceName: "icn_car")
        }
    }
    
    var metadata: Metadata? {
        return self.airport ?? self.limousine ?? self.train
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
        self.location = try container.decode(String.self, forKey: .location)
    }
    
    // MARK: - Execution Management
    
    func start() {
        Product.shared = self
        let defaults = UserDefaults.standard
        defaults.set(self.id, forKey: Product.kSharedId)
        defaults.synchronize()
    }
    
    func end() {
        Product.shared = nil
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: Product.kSharedId)
        defaults.synchronize()
    }
    
    // MARK: - Update
    
    func update(from object: Product) {
        self.baggage = object.baggage
        self.airport = object.airport
        self.limousine = object.limousine
        self.train = object.train
        self.location = object.location
        self.note = object.note
        self.date = object.date
        self.execution = object.execution
        self.passengers = object.passengers
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
