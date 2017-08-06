//
//  BookListTableViewController.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 19/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class ProductListTableViewController: UITableViewController {
    
    typealias ServiceType = Product.Base.Service.ServiceType
    
    @IBOutlet var logoutBBI: UIBarButtonItem!
    @IBOutlet var filterBBI: UIBarButtonItem!
    
    var products: [Product]?
    var data: [[Product]]?
    var selectedProduct: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Fetch data ?")
        self.refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataManager.shared.productManager.getData() { products, error in
            if let error = error {
                debugPrint(error)
                self.showErrorAlert(title: "Loading error", error: error)
            } else {
                self.reorderData(products)
            }
        }
    }

    @IBAction func logoutAction(_ sender: UIBarButtonItem) {
        DataManager.shared.logout()
        self.performSegue(withIdentifier: "logout", sender: self)
    }
    
    @IBAction func filterAction(_ sender: UIBarButtonItem) {
        let controller = UIAlertController(title: "Filter", message: "Choose the type of service", preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Airport", style: .default, handler: { _ in self.filter(by: .airport) }))
        controller.addAction(UIAlertAction(title: "Limousine", style: .default, handler: { _ in self.filter(by: .limousine) }))
        controller.addAction(UIAlertAction(title: "Train", style: .default, handler: { _ in self.filter(by: .train) }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in self.filter(by: nil) }))
        self.present(controller, animated: true, completion: nil)
    }
    
    func filter(by serviceType: ServiceType?) {
        let products: [Product]
        if let type = serviceType {
            products = DataManager.shared.productManager.filter() { product in
                return product.type.service.type == type
            }
        } else {
            products = DataManager.shared.productManager.getData()
        }
        self.reorderData(products)
    }
    
    func reorderData(_ products: [Product]?) {
        self.data = []
        var last: Date? = nil
        var buf: [Product] = []
        for prod in products ?? [] {
            last = last ?? prod.date
            if prod.date == last {
                buf.append(prod)
            } else {
                self.data?.append(buf)
                last = prod.date
                buf = [prod]
            }
        }
        self.data?.append(buf)
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.data?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?[section].count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.data?[section].first?.date.dateString(" ")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "product_cell", for: indexPath) as! ProductTableViewCell
        cell.product = self.data?[indexPath.section][indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let product = self.data?[indexPath.section][indexPath.row] {
            self.selectedProduct = product
            self.performSegue(withIdentifier: "product_details", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ProductDetailsTableViewController {
            controller.product = self.selectedProduct
        }
    }
    
    // MARK: - Actions
    
    @objc func refreshData(_ sender: UIRefreshControl) {
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Fetching data...")
        DataManager.shared.productManager.getData(force: true) { products, error in
            self.refreshControl?.endRefreshing()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "Fetch data ?")
            if let error = error {
                debugPrint(error)
                self.showErrorAlert(title: "Loading error", error: error)
            } else {
                self.reorderData(products)
            }
        }
    }

}
