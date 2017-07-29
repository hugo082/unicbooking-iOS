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
    let id: Int
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
}
