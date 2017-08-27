//
//  Train.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 23/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import Foundation
import UIKit

struct TrainMetadata: Decodable, Metadata {
    
    enum CodingKeys: String, CodingKey  {
        case code, station, time
    }
    
    let code: String?
    let station: String?
    let time: Date?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decodeIfPresent(String.self, forKey: .code)
        self.station = try container.decodeIfPresent(String.self, forKey: .station)
        if let timeString = try container.decodeIfPresent(String.self, forKey: .time) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            self.time = formatter.date(from: timeString)
        } else {
            self.time = nil
        }
    }
    
    func configure(alert: UIAlertController) {}
    func sendData(product: Product, data: Any?) {}
}
