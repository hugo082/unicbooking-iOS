//
//  UTFlightView.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 23/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class UTFlightView: UIView {
    
    typealias Flight = AirportMetadata.Flight
    
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    var flight: Flight? {
        didSet {
            self.updateUI()
        }
    }
    
    func updateUI() {
        if let flight = self.flight {
            self.isHidden = false
            self.numberLabel.text = "AF432_"//flight.code
            self.timeLabel.text = flight.arrivalTime.dateString()
        } else {
            self.isHidden = true
        }
    }

}
