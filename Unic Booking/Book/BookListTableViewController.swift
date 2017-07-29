//
//  BookListTableViewController.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 19/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class BookListTableViewController: UITableViewController {
    
    var products: [Product]?
    var selectedProduct: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataManager.shared.productManager.getData() { products, error in
            self.products = products
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "book_cell", for: indexPath) as! BookTableViewCell
        if let product = self.products?[indexPath.row] {
            debugPrint(product)
            cell.titleLabel.text = "\(product.passengers.first?.lastName ?? "empty")"
            cell.informationLabel.text = "\(product.passengers.count) people • \(product.baggage) bagages"
            cell.timeLabel.text = "6:20 PM"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let product = self.products?[indexPath.row] {
            self.selectedProduct = product
            self.performSegue(withIdentifier: "book_details", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? BookDetailsTableViewController {
            controller.product = self.selectedProduct
        }
    }

}
