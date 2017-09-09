//
//  StatisticsManager.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 09/09/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import Foundation

class StatisticManager<Type:Model, Stat:Numeric> {
    
    private var result: Stat
    
    var isComputed: Bool
    var startValue: Stat
    var data: [Type]
    var handler: ((Type) -> Stat)
    
    init(data: [Type] = [], startValue: Stat = 0, handler: @escaping ((Type) -> Stat)) {
        self.result = startValue
        self.startValue = startValue
        self.data = data
        self.handler = handler
        self.isComputed = false
    }
    
    func compute() {
        self.result = self.startValue
        for model in data {
            self.result += self.handler(model)
        }
        self.isComputed = true
    }
    
    func reset() {
        self.result = startValue
        self.isComputed = false
    }
    
    func insert(stat: Stat) {
        self.result += stat
    }
    
    /// Auto compute result if needed
    func getResult(force: Bool = false) -> Stat {
        if force || !self.isComputed {
            self.compute()
        }
        return self.result
    }
}
