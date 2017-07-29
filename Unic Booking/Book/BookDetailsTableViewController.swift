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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.enableTouchesDismiss()
        self.tableView.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Fetching data...")
        self.refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
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
        return self.stepNotes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "book_execution_step_cell", for: indexPath) as! ExecutionStepTableViewCell
            cell.step = self.product.execution.steps[indexPath.row]
            cell.computeStep(with: indexPath.row, currentStep: self.product.execution.currentStepIndex)
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
        cell.step = self.stepNotes[indexPath.row]
        cell.noteView.isEditable = self.product.execution.currentStepIndex == indexPath.row
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ExecutionStepTableViewCell {
            if (self.product.execution.complete(step: cell.step!)) {
                tableView.reloadSections([0, 2], with: UITableViewRowAnimation.top)
            }
        }
    }
    
    @objc func refreshData(_ sender: UIRefreshControl) {
        print("refresh")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        })
    }
    

}
