//
//  BookDetailsTableViewController.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 19/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

import CoreLocation
import MapKit

class ProductDetailsTableViewController: UITableViewController {
    
    enum Cell: String {
        case recapAirport = "book_flight_cell", recapTrain = "book_train_cell", recapLimousine = "book_limousine_cell"
        case recap = "product_recap_cell"
        case step = "book_execution_step_cell"
        case note = "book_note_cell"
        
        static func get(from serviceType: Product.Base.Service.ServiceType) -> Cell {
            switch serviceType {
            case .airport:
                return Cell.recapAirport
            case .train:
                return Cell.recapTrain
            case .limousine:
                return Cell.recapLimousine
            }
        }
    }
    
    @IBOutlet var statusLabel: UILabel!
    
    var product: Product!
    var stepNotes: [Execution.Step] = []
    var currentNote: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.statusLabel.text = product.execution.state.rawValue
        self.statusLabel.backgroundColor = UIConstants.Color.get(with: product.execution.state)
        
        self.enableTouchesDismiss()
        self.tableView.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Fetch data ?")
        self.refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(startAction(_:)))
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return self.product.execution.steps.count
        }
        self.stepNotes = self.product.execution.getStepWithNote()
        return self.stepNotes.count + (self.product.execution.state == .progress ? 1 : 0)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.recap.rawValue, for: indexPath) as! RecapTableViewCell
            cell.product = product
            cell.controller = self
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.step.rawValue, for: indexPath) as! ExecutionStepTableViewCell
            cell.step = self.product.execution.steps[indexPath.row]
            cell.computeStep(with: indexPath.row, currentStep: self.product.execution.currentStepIndex ?? -1, baggages: self.product.baggage)
            if cell.step?.tag == .linkInfo {
                cell.actionButton.addTarget(self, action: #selector(linkAction(_:)), for: .touchUpInside)
            } else if cell.step?.tag == .limousineStop {
                cell.actionButton.addTarget(self, action: #selector(iteneraryAction(_:)), for: .touchUpInside)
            } else if cell.step?.tag == .bagCount {
                cell.actionButton.addTarget(self, action: #selector(bagAction(_:)), for: .touchUpInside)
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.note.rawValue, for: indexPath) as! NoteTableViewCell
        if indexPath.row < self.stepNotes.count {
            cell.step = self.stepNotes[indexPath.row]
            cell.noteView.isEditable = false
        } else {
            cell.step = self.product.execution.currentStep
            cell.noteView.isEditable = true
        }
        self.currentNote = cell.noteView
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ExecutionStepTableViewCell {
            if (cell.step?.isFinish ?? false) && self.product.execution.isStarted {
                self.confirmFinish(step: cell.step!)
            } else if cell.step?.tag == .addStop {
                self.addStop()
            } else {
                self.updateState(step: cell.step!)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func startAction(_ sender: UIBarButtonItem) {
        if let product = Product.shared {
            self.showAlert(title: "Error", message: "You have already started an execution : \(product.id)")
            return
        }
        let alert = UIAlertController(title: "Confirm", message: "Start this mission", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.product.metadata?.configure(alert: alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
            self.executeStart(alert.textFields?.first?.text)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func executeStart(_ data: Any?) {
        self.product.metadata?.sendData(product: self.product, data: data)
        ApiManager.shared.update(self.product.execution) { error in
            if let error = error {
                self.showErrorAlert(title: "Update Error", error: error)
                return
            } else {
                self.product.start()
                self.tableView.reloadData()
            }
        }
    }
    
    func confirmFinish(step: Execution.Step) {
        let alert = UIAlertController(title: "Confirm", message: "Finish this mission", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
            self.product.finish()
            self.updateState(step: step)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateState(step: Execution.Step) {
        if (self.product.execution.complete(step: step)) {
            ApiManager.shared.update(self.product.execution) { error in
                if let error = error {
                    self.showErrorAlert(title: "Update Error", error: error)
                    return
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func addStop() {
        self.promptData(title: "Add stop", message: nil, cancel: "Cancel", placeholder: "Stop address", confirm: "Confirm") { data in
            if let stop = data {
                ApiManager.shared.limousineAddStop(self.product, stop: stop, completionHandler: { (_) in
                    DataManager.shared.productManager.getData(with: self.product.id, force: true, completionHandler: { (product, error) in
                        if let error = error {
                            self.showErrorAlert(title: "Error Update", error: error)
                        } else if let product = product {
                            self.product = product
                        }
                        self.tableView.reloadData()
                    })
                })
            } else {
                self.showAlert(title: "Error", message: "Impossible to get Stop address")
            }
        }
    }
    
    @objc func refreshData(_ sender: UIRefreshControl) {
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Fetching data...")
        ApiManager.shared.detail(model: self.product.execution) { (object, error) in
            if let object = object {
                self.product.execution.update(from: object)
            }
            self.refreshControl?.endRefreshing()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "Fetch data ?")
            self.tableView.reloadData()
        }
    }
    
    @objc func iteneraryAction(_ sender: UIButton) {
        guard let location = self.product.execution.getStep(with: sender.tag)?.title else {
            self.showAlert(title: "Error", message: "Impossible to load loaction")
            return
        }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressDictionary([
            "Street" : location
        ]) { (placemarks, error) in
            if let placemark = placemarks?.first {
                let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
                mapItem.name = location
                mapItem.openInMaps(launchOptions: [:])
            } else {
                self.showErrorAlert(title: "Error", error: error)
            }
        }
    }
    
    @objc func bagAction(_ sender: UIButton) {
        self.promptData(title: "Baggages", message: nil, cancel: "Cancel", placeholder: "Bag count", confirm: "Confirm", configure: { textField in
            textField.keyboardType = .numberPad
        }) { (data) in
            if let bag = Int(data ?? "a") {
                ApiManager.shared.update(model: self.product, parameters: ["baggages": String(bag)], completionHandler: { (error) in
                    if let error = error {
                        self.showErrorAlert(title: "Error", error: error)
                    }
                    self.tableView.reloadData()
                })
            } else {
                self.showAlert(title: "Error", message: "Impossible to convert data to number")
            }
        }
    }
    
    @objc func linkAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Contact Greeter/Driver to next mission", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let driver = self.product.driver {
            alert.addAction(UIAlertAction(title: driver.phoneDescription, style: .default, handler: { (action) in
                self.call(user: driver)
            }))
        }
        if let greeter = self.product.greeter {
            alert.addAction(UIAlertAction(title: greeter.phoneDescription, style: .default, handler: { (action) in
                self.call(user: greeter)
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }

    private func call(user: User) {
        if let url = URL(string: "tel://\(user.normalizePhone)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            self.showAlert(title: "Error", message: "Impossible to call number \(user.normalizePhone)")
        }
    }
}
