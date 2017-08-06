//
//  UIConstants.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 23/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class UIConstants {
    
    class Color {
        static let BLACK_BACKGROUND = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1)
        
        static let GRAY_TEXT = UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1)
        static let GRAY_PLACEHOLDER = UIColor(red: 188/255, green: 188/255, blue: 190/255, alpha: 1)
        
        static let GRAY_WAITING_BACKGROUND = UIColor(red: 248/255, green: 247/255, blue: 251/255, alpha: 1)
        
        static let GREEN_SUCCESS_BACKGROUND = UIColor(red: 117/255, green: 207/255, blue: 194/255, alpha: 1)
        
        static let BLUE_CURRENT_BACKGROUND = UIColor(red: 70/255, green: 120/255, blue: 176/255, alpha: 1)
        
        static let RED_ERROR_BACKGROUND = UIColor(red: 255/255, green: 82/255, blue: 82/255, alpha: 1)
        
        static func get(with state: Execution.State) -> UIColor {
            switch state {
            case .waiting:
                return GRAY_WAITING_BACKGROUND
            case .progress:
                return BLUE_CURRENT_BACKGROUND
            case .finished:
                return GREEN_SUCCESS_BACKGROUND
            case .empty:
                return GRAY_WAITING_BACKGROUND
            }
        }
    }
    
}

