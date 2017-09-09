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
    
    @IBOutlet var title1: UILabel!
    @IBOutlet var title2: UILabel!
    @IBOutlet var title3: UILabel!
    @IBOutlet var title4: UILabel!
    
    @IBOutlet var value1: UILabel!
    @IBOutlet var value2: UILabel!
    @IBOutlet var value3: UILabel!
    @IBOutlet var value4: UILabel!
    
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
//        self.serviceDetailsLabel.text = self.serviceDetails(prod)
        self.serviceDetails(prod)
        //self.timeButton.setTitle(self.product?.time?.timeString(), for: .normal)
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
        return content
    }
    
    func serviceDetails(_ product: Product) {
        let time = product.time?.timeString() ?? "-"
        if let airportMet = self.metadata as? AirportMetadata {
            self.title1.text = "flight"
            self.value1.text = recap(airportMet.flight)
            
            self.title2.text = "transit"
            self.value2.text = recap(airportMet.flightTransit)
            
            self.title3.text = "time/loc"
            self.value3.text = time + " " + product.location
            
            self.title4.text = "greeter"
            self.value4.text = product.greeter?.username ?? "-"
        } else if let limousineMet = self.metadata as? LimousineMetadata {
            self.title1.text = "time/loc"
            self.value1.text = time + " " + product.location
            
            self.title2.text = "pickUp"
            self.value2.text = limousineMet.pickUp
            
            self.title3.text = "dropOff"
            self.value3.text = limousineMet.dropOff
            
            self.title4.text = "driver"
            self.value4.text = product.driver?.username ?? "-"
        } else if let trainMet = self.metadata as? TrainMetadata {
            self.title1.text = "time/loc"
            self.value1.text = time + " " + product.location
            
            self.title2.text = "code"
            self.value2.text = trainMet.code ?? "-"
            
            self.title4.text = "greeter"
            self.value4.text = product.greeter?.username ?? "-"
        }
    }
    
    func recap(_ flight: AirportMetadata.Flight?) -> String {
        if let flight = flight {
            return flight.codes.master + " " + flight.airport.codes.master
        }
        return "-"
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

