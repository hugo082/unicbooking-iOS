//
//  LimousineTableViewCell.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 06/08/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LimousineTableViewCell: UITableViewCell, RecapCell {
    
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var serviceTypeLabel: UILabel!
    @IBOutlet var pickUpAddressLabel: UILabel!
    @IBOutlet var dropOffAddressLabel: UILabel!
    @IBOutlet var carLabel: UILabel!
    
    var controller: UIViewController?
    var product: Product? {
        didSet {
            updateUI()
        }
    }
    var metadata: Metadata? {
        return self.product?.limousine
    }
    var limousineMetadata: LimousineMetadata? {
        return self.metadata as? LimousineMetadata
    }
    
    func updateUI() {
        self.iconView.image =  #imageLiteral(resourceName: "icn_car")
        self.serviceTypeLabel.text = self.product?.type.name
        self.pickUpAddressLabel.text = self.limousineMetadata?.pickUp
        self.dropOffAddressLabel.text = self.limousineMetadata?.dropOff
        self.carLabel.text = self.limousineMetadata?.car.name
    }

    @IBAction func openMap(_ sender: UIButton) {
        let alert = UIAlertController(title: "Destination", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Pick up", style: .default, handler: { (action) in
            self.computeLocation(name: "Pick up", location: self.product?.limousine?.pickUp ?? "")
        }))
        alert.addAction(UIAlertAction(title: "Drop off", style: .default, handler: { (action) in
            self.computeLocation(name: "Drop off", location: self.product?.limousine?.dropOff ?? "")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.controller?.present(alert, animated: true, completion: nil)
    }
    
    func computeLocation(name: String, location: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressDictionary([
            "Street" : location
        ]) { (placemarks, error) in
            if let placemark = placemarks?.first {
                let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
                mapItem.name = name
                mapItem.openInMaps(launchOptions: [:])
            } else {
                self.controller?.showErrorAlert(title: "Error", error: error)
            }
        }
    }
}
