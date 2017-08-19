//
//  BookTableViewCell.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 19/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var informationLabel: UILabel!
    @IBOutlet var iconImage: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var stateView: UIView!
    @IBOutlet var locationLabel: UILabel!
    
    var product: Product? {
        didSet {
            self.updateUI()
        }
    }

    func updateUI() {
        self.iconImage.image = self.product?.icon
        self.stateView.backgroundColor = UIConstants.Color.get(with: self.product?.execution.state ?? .empty)
        self.titleLabel.text = self.product?.passengers.first?.fullName ?? self.product?.type.name
        self.informationLabel.text = "\(self.product?.passengers.count ?? 0) people • \(self.product?.baggage ?? 0) bagages"
        self.timeLabel.text = self.product?.time?.timeString() ?? " - "
        self.locationLabel.text = self.product?.airport?.mainAirport.codes.master ?? self.product?.location
    }
}
