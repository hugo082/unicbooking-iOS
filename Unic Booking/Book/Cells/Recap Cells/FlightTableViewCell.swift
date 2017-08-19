//
//  FlightTableViewCell.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 20/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class FlightTableViewCell: UITableViewCell, RecapCell {
    
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var flightView: UTFlightView!
    @IBOutlet var flightTransitView: UTFlightView!
    @IBOutlet var serviceTypeLabel: UILabel!
    
    var product: Product? {
        didSet {
            updateUI()
        }
    }
    var metadata: Metadata? {
        return self.product?.airport
    }
    var airportMetadata: AirportMetadata? {
        return self.metadata as? AirportMetadata
    }
    
    func updateUI() {
        self.iconView.image = self.airportMetadata?.flight.icon
        self.serviceTypeLabel.text = self.product?.type.name
        self.flightView.flight = self.airportMetadata?.flight
        self.flightTransitView.flight = self.airportMetadata?.flightTransit
    }
}
