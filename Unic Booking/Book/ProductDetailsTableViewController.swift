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
            if (self.product.execution.complete(step: cell.step!)) {
                ApiManager.shared.update(self.product.execution) { error in
                    if let error = error {
                        self.showErrorAlert(title: "Update Error", error: error)
                        return
                    }
                    tableView.reloadData()
                }
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

}
