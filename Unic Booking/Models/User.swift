//
//  User.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 20/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class User: Model {
    
    enum CodingKeys : String, CodingKey {
        case id
        case username
        case email
        case roles
    }
    
    static var shared: User?
    
    let username: String
    let id: Int?
    var email: String?
    var roles: [String]?
    var agenda: [Book]?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.email = try container.decode(String.self, forKey: .email)
        self.roles = try container.decode([String].self, forKey: .roles)
        self.username = try container.decode(String.self, forKey: .username)
        self.agenda = []
    }
    
    func loadAgenda() {
        self.agenda = agendaGen()
    }
    
    // Mark: - Generators
    
    func gen() {
        self.id = idg()
        self.email = "user@email.com"
        self.roles = ["ROLE_GREETER"]
        self.agenda = []
    }
    
    func agendaGen() -> [Book] {
        var books: [Book] = []
        for _ in 0...idg(10) {
            books.append(bookGen())
        }
        return books
    }
    
    func bookGen() -> Book {
        var products: [Product] = []
        for _ in 0...idg(10) {
            products.append(productGen())
        }
        return Book(id: idg(), products: products)
    }
    
    func productGen(_ defServiceType: String? = nil) -> Product {
        let base = baseGen(defServiceType)
        if base.service.type == "Airport" {
            let airport = airportGen()
            return Product(id: idg(), type: base, airport: airport, limousine: nil, train: nil, note: nil, execution: execGen(), passengers: passengersGen(), baggage: idg(20))
        }
        if base.service.type == "Limousine" {
            let lim = limousineGen()
            return Product(id: idg(), type: base, airport: nil, limousine: lim, train: nil, note: nil, execution: execGen(), passengers: passengersGen(), baggage: idg(20))
        }
        let train = trainGen()
        return Product(id: idg(), type: base, airport: nil, limousine: nil, train: train, note: nil, execution: execGen(), passengers: passengersGen(), baggage: idg(20))
    }
    
    func execGen() -> Execution {
        let state = (["WAITING", "FINISHED"])[idg(2)]
        let (steps, cStep) = stepsGen()
        return Execution(id: idg(), currentStep: cStep, state: state, steps: steps)
    }
    
    func stepsGen() -> ([Execution.Step], Int) {
        var finish: Bool = true
        var cStep: Int = 0
        var steps: [Execution.Step] = []
        for i in 0...(idg(2) + 2) {
            finish = finish && (idg(5) > 1)
            if (finish) {
                cStep += 1
            }
            steps.append(stepGen(i, finish))
        }
        return (steps, cStep)
    }
    
    func stepGen(_ index: Int, _ finished: Bool) -> Execution.Step {
        let (title, icon): (String, String) = ([("Welcome passenger", "icn_passenger"), ("Passport control", "icn_passport"), ("Baggages", "icn_baggage"), ("Car drop", "icn_car")])[index]
        let finishTime = finished ? Date() : nil
        return Execution.Step(id: idg(), title: title, icon: icon, finishTime: finishTime, note: nil)
    }
    
    func trainGen() -> TrainMetadata {
        let code = (["FDSG3", "FDSF43", "JHGF43", "3F32F", "DG55R", "FDS32"])[idg(6)]
        let stat = (["Paris", "Lyon", "Marseille", "Nice", "Dubai", "Nantes"])[idg(6)]
        let time = (["12:34", "10:23", "6:45", "18:37", "23:59", "21:12"])[idg(6)]
        return TrainMetadata(code: code, station: stat, time: time)
    }
    
    func limousineGen() -> LimousineMetadata {
        let DO = (["Paris", "Lyon", "Marseille", "Nice", "Dubai", "Nantes"])[idg(6)]
        let PU = (["Paris", "Lyon", "Marseille", "Nice", "Dubai", "Nantes"])[idg(6)]
        return LimousineMetadata(id: idg(), car: carGen(), dropOff: DO, pickUp: PU)
    }
    
    func carGen() -> LimousineMetadata.Car {
        let name = (["Ferrari", "Audi", "BMW", "Testla", "Ford", "Citroen"])[idg(6)]
        return LimousineMetadata.Car(id: idg(), name: name)
    }
    
    func airportGen() -> AirportMetadata {
        return AirportMetadata(id: idg(), flight: flightGen()!, flightTransit: flightGen(idg(2) > 0), code: "__CODE__")
    }
    
    func flightGen(_ force: Bool = true) -> AirportMetadata.Flight? {
        if !force {
            return nil
        }
        return AirportMetadata.Flight(id: idg(), code: "AF\(idg(89) + 10)", arrivalTime: Date(), departureTime: Date())
    }
    
    func baseGen(_ defServiceType: String? = nil) -> Product.Base {
        let service = serviceGen(defServiceType)
        let option = (["Bronze", "Argent", "Gold"])[idg(3)]
        let name = service.type + " " + service.name + " " + option
        return Product.Base(id: idg(), name: name, service: service)
    }
    
    func serviceGen(_ defType: String? = nil) -> Product.Base.Service {
        let type = defType ?? (["Airport", "Limousine", "Train"])[idg(3)]
        let name = (["Departure", "Arrival", "Transit"])[idg(3)]
        return Product.Base.Service(id: idg(), name: name, type: type, iconCode: "__ICON__")
    }
    
    func passengersGen() -> [Product.Passenger] {
        var pass: [Product.Passenger] = []
        for _ in 0...idg(8) {
            pass.append(passengerGen())
        }
        return pass
    }
    
    func passengerGen() -> Product.Passenger {
        let firstName = (["Hugo", "Clemence", "Elisa", "Corentin", "Clhoé", "Romain", "Simon"])[idg(7)]
        let lastName = (["Fouquet", "Lejeune", "Gaudin", "Oury", "Yerro", "LeRhun", "Simon"])[idg(7)]
        return Product.Passenger(id: idg(), firstName: firstName, lastName: lastName)
    }
    
    func idg(_ max: UInt32 = 100) -> Int {
        return Int(arc4random_uniform(max))
    }
}
