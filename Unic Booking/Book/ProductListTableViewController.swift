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
    enum DateFilter {
        case today, month
    }
    
    @IBOutlet var logoutBBI: UIBarButtonItem!
    @IBOutlet var filterBBI: UIBarButtonItem!
    @IBOutlet var filterDateBBI: UIBarButtonItem!
    
    @IBOutlet var dayTotal: UILabel!
    @IBOutlet var monthTotal: UILabel!
    
    var products: [Product]?
    var data: [[Product]]?
    var selectedProduct: Product?
    
    var filters: (ServiceType?, DateFilter) = (nil, .month)
    
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
                self.showErrorAlert(title: "Loading error", error: error)
            } else {
                self.filter()
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
        controller.addAction(UIAlertAction(title: "All", style: .cancel, handler: { _ in self.filter(by: nil) }))
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func filterDateAction(_ sender: UIBarButtonItem) {
        if self.filters.1 == .today {
            self.filter(by: .month)
        } else {
            self.filter(by: .today)
        }
    }
    
    func filter(by dateFilter: DateFilter) {
        self.filters.1 = dateFilter
        self.filterDateBBI.image = dateFilter == .today ? #imageLiteral(resourceName: "icn_calendar_check") : #imageLiteral(resourceName: "icn_calendar_month")
        self.filter()
    }
    
    func filter(by serviceType: ServiceType?) {
        self.filters.0 = serviceType
        self.filter()
    }
    
    func filter() {
        DataManager.shared.productManager.computeStatistics()
        let products: [Product]
        products = DataManager.shared.productManager.filter() { product in
            if self.filters.1 == .today {
                return Calendar.current.isDateInToday(product.date)
            } else if let type = self.filters.0 {
                return product.type.service.type == type
            }
            return true
        }
        self.reorderData(products)
    }
    
    func reorderData(_ products: [Product]?) {
        self.data = []
        let sorted = (products ?? []).sorted(by: { (product1, product2) -> Bool in
            return product1.date < product2.date
        })
        var last: Date? = nil
        var buf: [Product] = []
        for prod in sorted {
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
        self.updateTabView()
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
                self.showErrorAlert(title: "Loading error", error: error)
            } else {
                self.filter()
            }
        }
    }
    
    @IBAction func dayListAction(_ sender: UIButton) {
        self.filter(by: .today)
    }
    
    @IBAction func monthListAction(_ sender: UIButton) {
        self.filter(by: .month)
    }
    
    // MARK: - Tab View
    
    func updateTabView() {
        let stats = DataManager.shared.productManager.statistics
        self.dayTotal.text = "\(stats["day"]?.getResult() ?? 0) \n Today"
        self.monthTotal.text = "\(stats["month"]?.getResult() ?? 0) \n Month"
    }
    
}
