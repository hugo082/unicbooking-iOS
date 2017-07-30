//
//  DataManager.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 29/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import Foundation

class DataManager {
    
    static var shared = DataManager()
    
    var productManager: ModelManager<Product>
    var bookManager: ModelManager<Book>
    
    init(){
        self.productManager = ModelManager<Product>()
        self.bookManager = ModelManager<Book>()
    }
    
    func manager<Type>(object: Type.Type) -> ModelManager<Type>? {
        switch object {
        case is Product.Type:
            return self.productManager as? ModelManager<Type>
        case is Book.Type:
            return self.bookManager as? ModelManager<Type>
        default:
            return nil
        }
    }
    
    func logout() {
        User.shared = nil
        Credential.destroy()
        self.productManager.clean()
        self.bookManager.clean()
    }
}
