//
//  Credential.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 29/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import Foundation

class Credential {
    
    static var shared: Credential? = nil
    
    let username: String
    var password: String?
    var token: String?
    
    init(username: String, password: String?, token: String?) {
        self.username = username
        self.password = password
        self.token = token
    }
    
    func save(forKey key: String = "auth") {
        Credential.shared = self
        UserDefaults.standard.set(self.token, forKey: key + "_token")
        UserDefaults.standard.set(self.username, forKey: key + "_username")
        UserDefaults.standard.synchronize()
    }
    
    static func destroy(forKey key: String = "auth") {
        Credential.shared = nil
        UserDefaults.standard.set(nil, forKey: key + "_token")
        UserDefaults.standard.set(nil, forKey: key + "_username")
        UserDefaults.standard.synchronize()
    }
    
    static func load(forKey key: String = "auth") -> Credential? {
        if let token = UserDefaults.standard.string(forKey: key + "_token"),
            let username = UserDefaults.standard.string(forKey: key + "_username") {
            Credential.shared = Credential(username: username, password: nil, token: token)
        }
        return Credential.shared
    }
    
}
