//
//  Extension.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 23/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

extension Date {
    
    func dateString(_ before: String = "", _ separator: String = " ") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "fr_FR")
        dateFormatter.dateFormat = "dd\(separator)MMM\(separator)yy"
        return before + dateFormatter.string(from: self)
    }
    
    func timeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "fr_FR")
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
}

extension UIViewController {
    
    func enableTouchesDismiss() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(title: String?, error: Error?) {
        self.showAlert(title: title, message: error?.localizedDescription)
    }
    
    func promptData(title: String?, message: String?, cancel: String?, placeholder: String?, confirm: String?,
                    completion: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let cancel = cancel {
            alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
        }
        alert.addTextField { (textField) in
            textField.placeholder = placeholder
        }
        alert.addAction(UIAlertAction(title: confirm, style: .default, handler: { (action) in
            completion(alert.textFields?.first?.text)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
