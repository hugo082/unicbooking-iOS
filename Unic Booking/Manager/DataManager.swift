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
        self.bookManager = ModelManager<Book>()
        self.productManager = ModelManager<Product>()
        self.productManager.statistics = [
            "month": self.monthStatistic(),
            "day": self.dayStatistic()
        ]
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
    
    func dayStatistic() -> StatisticManager<Product, Int> {
        return StatisticManager<Product, Int>() { product in
            return Calendar.current.isDateInToday(product.date) ? 1 : 0
        }
    }
    
    func monthStatistic() -> StatisticManager<Product, Int> {
        return StatisticManager<Product, Int>() { product in
            return Calendar.current.isDate(product.date, equalTo: Date(), toGranularity: Calendar.Component.month) ? 1 : 0
        }
    }
}
