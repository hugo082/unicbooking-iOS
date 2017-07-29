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
        if let value = ProcessInfo.processInfo.environment["Environment"], value.contains("Staging") {
            return Environment.Staging
        }
        return Environment.Production
    }()
}

enum Environment: String {
    case Staging = "staging"
    case Production = "production"
    
    var baseURL: String {
        switch self {
        case .Staging: return "http://localhost:8000/api"
        case .Production: return "missing"
        }
    }
}
