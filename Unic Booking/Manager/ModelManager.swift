//
//  ModelManager.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 29/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import Foundation

class ModelManager<Type:Model> {
    
    private var data: [Int:Type]
    var statistics: [String:StatisticManager<Type, Int>]
    var isLoaded: Bool
    var isEmpty: Bool {
        return self.data.isEmpty
    }
    
    init(data: [Int:Type] = [:], isLoaded: Bool = false) {
        self.statistics = [:]
        self.data = data
        self.isLoaded = isLoaded
    }
    
    func push(objects: [Type]) {
        for object in objects {
            self.push(object: object)
        }
    }
    
    func push(object: Type) {
        self.data[object.id] = object
        if let link = (object as? Product)?.linked {
            DataManager.shared.productManager.push(object: link)
        }
    }
    
    func getData(force: Bool = false, completionHandler: @escaping ([Type]?, Error?) -> Void) {
        if force || !self.isLoaded {
            ApiManager.shared.list(model: Type.self, completionHandler: completionHandler)
        } else {
            completionHandler(self.getData(), nil)
        }
    }
    
    func getData(with id: Int, force: Bool = false, completionHandler: @escaping (Type?, Error?) -> Void) {
        if force {
            ApiManager.shared.detail(model: Type.self, id: id, completionHandler: completionHandler)
            return
        }
        for (_, object) in self.data {
            if object.id == id {
                completionHandler(object, nil)
                return
            }
        }
        ApiManager.shared.detail(model: Type.self, id: id, completionHandler: completionHandler)
    }
    
    func getData() -> [Type] {
        return Array(self.data.values)
    }
    
    func filter(handler: (Type) -> Bool) -> [Type] {
        return self.data.values.filter(handler)
    }
    
    func clean() {
        self.data.removeAll()
        self.isLoaded = false
    }
    
    // MARK: - Statistics
    
    func computeStatistics() {
        self.resetStatistics()
        for (_, model) in self.data {
            for (_, manager) in self.statistics {
                manager.isComputed = true
                manager.insert(stat: manager.handler(model))
            }
        }
    }
    
    func resetStatistics() {
        for (_, manager) in self.statistics {
            manager.reset()
        }
    }
}
