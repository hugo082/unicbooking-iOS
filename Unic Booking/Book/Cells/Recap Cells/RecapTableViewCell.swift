//
//  TrainTableViewCell.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 19/08/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class RecapTableViewCell: UITableViewCell, RecapCell {
    
    @IBOutlet var serviceDetailsLabel: UILabel!
    @IBOutlet var passengersDetailsLabel: UILabel!
    @IBOutlet var timeButton: UIButton!
    
    var controller: UIViewController?
    var product: Product? {
        didSet {
            updateUI()
        }
    }
    var metadata: Metadata? {
        return self.product?.metadata
    }
    
    func updateUI() {
        guard let prod = self.product else {
            return
        }
        self.passengersDetailsLabel.text = self.passengerDetails(prod)
        self.serviceDetailsLabel.text = self.serviceDetails(prod)
        self.timeButton.setTitle(self.product?.time?.timeString(), for: .normal)
    }
    
    @IBAction func timeAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Destination", message: nil, preferredStyle: .actionSheet)
        if let limousineMet = self.metadata as? LimousineMetadata {
            alert.addAction(UIAlertAction(title: "Pick up", style: .default, handler: { (action) in
                self.computeLocation(name: "Pick up", location: limousineMet.pickUp)
            }))
            alert.addAction(UIAlertAction(title: "Drop off", style: .default, handler: { (action) in
                self.computeLocation(name: "Drop off", location: limousineMet.dropOff)
            }))
        } else if let airportMet = self.metadata as? AirportMetadata {
            alert.addAction(UIAlertAction(title: airportMet.mainAirport.codes.master, style: .default, handler: { (action) in
                self.computeLocation(name: "Airport", location: airportMet.mainAirport.codes.master)
            }))
        } else if let station = (self.metadata as? TrainMetadata)?.station {
            alert.addAction(UIAlertAction(title: station, style: .default, handler: { (action) in
                self.computeLocation(name: "Station", location: station)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.controller?.present(alert, animated: true, completion: nil)
    }
    
    func passengerDetails(_ product: Product) -> String? {
        var content = ""
        for passenger in product.passengers {
            content += passenger.fullName + "\n"
        }
        if let limousineMet = self.metadata as? LimousineMetadata {
            content += "\nPick up: " + limousineMet.pickUp + "\n"
            content += "Drop off: " + limousineMet.dropOff
        }
        return content
    }
    
    func serviceDetails(_ product: Product) -> String? {
        var content = ""
        if let airportMet = self.metadata as? AirportMetadata {
            content += recap(airportMet.flight)
            if let flight = airportMet.flightTransit {
                content += "\n" + recap(flight)
            }
        } else if product.isLimousine {
            content += product.type.name
        } else if let trainMet = self.metadata as? TrainMetadata {
            content += trainMet.code ?? " - "
            content += "\n" + (trainMet.station ?? " - ")
        }
        return content
    }
    
    func recap(_ flight: AirportMetadata.Flight) -> String {
        return flight.codes.master + " " + flight.airport.codes.master
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

