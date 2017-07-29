//
//  Product.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 20/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class Book: Model {
    
    enum CodingKeys: String, CodingKey  {
        case id, products
    }
    
    let id: Int
    let products: [Product]
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.products = try container.decode([Product].self, forKey: .products)
    }
}
