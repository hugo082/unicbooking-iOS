//
//  Environment.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 29/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import Foundation

struct Configuration {
    static var environment: Environment = {
        if let value = ProcessInfo.processInfo.environment["Environment"], value == Environment.Localhost.rawValue {
            return Environment.Localhost
        } else if let value = ProcessInfo.processInfo.environment["Environment"], value == Environment.Staging.rawValue {
                return Environment.Staging
        }
        return Environment.Production
    }()
}

enum Environment: String {
    case Localhost = "localhost"
    case Staging = "staging"
    case Production = "production"
    
    var baseURL: String {
        switch self {
        case .Localhost:
            return "http://localhost:8000/api"
        case .Staging:
            return "http://safe-fortress-60581.herokuapp.com/api"
        case .Production:
            print("WARNING : Staging ENV")
            return "http://safe-fortress-60581.herokuapp.com/api"
        }
    }
}
