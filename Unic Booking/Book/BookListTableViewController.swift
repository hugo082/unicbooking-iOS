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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "book_cell", for: indexPath) as! BookTableViewCell
        let data = self.data[indexPath.row]
        cell.titleLabel.text = data.0
        cell.informationLabel.text = data.1
        cell.timeLabel.text = data.2
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "book_details", sender: self)
    }

}