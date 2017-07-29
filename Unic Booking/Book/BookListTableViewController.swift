//
//  BookListTableViewController.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 19/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class BookListTableViewController: UITableViewController {
    
    let data = [
            ("Gordon Burke","2 people • 2 bagages","5.00 PM",""),
            ("Jeremia Dean","3 people • 2 bagages","6.20 PM",""),
            ("Carole Arnold","1 people • 3 bagages","3.15 PM","")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ApiManager.shared.getProducts() { products, error in
            if products == nil {
                self.showErrorAlert(title: "Loading error", error: error)
            } else {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return User.shared!.agenda!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "book_cell", for: indexPath) as! BookTableViewCell
        let book = User.shared!.agenda![indexPath.row]
        cell.titleLabel.text = "\(book.products.first?.passengers.first?.lastName ?? "empty")"
        cell.informationLabel.text = "\(book.products.first?.passengers.count ?? 0) people • \(book.products.first?.baggage ?? 0) bagages"
        cell.timeLabel.text = "6.20 PM"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "book_details", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? BookDetailsTableViewController {
            controller.product = User.shared!.agenda![self.tableView.indexPathForSelectedRow?.row ?? 0].products.first!
        }
    }

}
