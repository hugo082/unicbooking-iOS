//
//  BookDetailsTableViewController.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 19/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class BookDetailsTableViewController: UITableViewController {
    
    var product: Product!
    var stepNotes: [Execution.Step] = []
    var currentNote: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            return self.product.execution.steps.count
        } else if section == 1 {
            return 1
        }
        self.stepNotes = self.product.execution.getStepWithNote()
        return self.stepNotes.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "book_execution_step_cell", for: indexPath) as! ExecutionStepTableViewCell
            cell.step = self.product.execution.steps[indexPath.row]
            cell.computeStep(with: indexPath.row, currentStep: self.product.execution.currentStepIndex ?? -1)
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "book_flight_cell", for: indexPath) as! FlightTableViewCell
            if let airportMetadata = self.product.airport {
                cell.flightView.flight = airportMetadata.flight
                cell.flightTransitView.flight = airportMetadata.flightTransit
                cell.serviceTypeLabel.text = self.product.type.service.name
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "book_note_cell", for: indexPath) as! NoteTableViewCell
        if indexPath.row < self.stepNotes.count {
            cell.step = self.stepNotes[indexPath.row]
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
                    print("Updated", self.product.execution)
                    if let error = error {
                        self.showErrorAlert(title: "Update Error", error: error)
                        return
                    } else {
                        self.product.execution.nextStep()
                    }
                    tableView.reloadSections([0, 2], with: UITableViewRowAnimation.top)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func startAction(_ sender: UIBarButtonItem) {
        self.product.execution.currentStepIndex = 0
        ApiManager.shared.update(self.product.execution) { error in
            if let error = error {
                self.showErrorAlert(title: "Update Error", error: error)
                return
            } else {
                self.tableView.reloadSections([0, 2], with: UITableViewRowAnimation.top)
            }
        }
    }
    
    @objc func refreshData(_ sender: UIRefreshControl) {
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Fetching data...")
        ApiManager.shared.update(model: self.product.execution) { error in
            self.refreshControl?.endRefreshing()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "Fetch data ?")
            self.tableView.reloadData()
        }
    }

}
