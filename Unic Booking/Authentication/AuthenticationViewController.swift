//
//  AuthenticationViewController.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 20/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import UIKit

class AuthenticationViewController: UIViewController {
    
    @IBOutlet weak var usernameTF: UTTextField!
    @IBOutlet weak var passwordTF: UTTextField!
    
    var credential: Credential? {
        guard let password = passwordTF.text,
            let username = usernameTF.text else { return nil }
        return Credential(username: username, password: password, token: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Credential.load() != nil {
            self.createUser()
        }
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        guard let credential = self.credential else {
            self.showAlert(title: "Invalid credentials", message: "Please enter username and password")
            return
        }
        UILoadingView.shared.presentLoader(self, message: "Check credentials...")
        ApiManager.shared.login(credential: credential) { token, error in
            if token == nil {
                UILoadingView.shared.dismissLoader() {
                    self.showAlert(title: "Invalid credentials", message: nil)
                }
            } else {
                credential.token = token
                credential.save()
                self.createUser()
            }
        }
    }
    
    func createUser() {
        UILoadingView.shared.update(message: "Fetching user data...", parentController: self)
        ApiManager.shared.getUserDetails() { user, error in
            UILoadingView.shared.dismissLoader() {
                if let error = error {
                    self.showErrorAlert(title: "Login error", error: error)
                    return
                } else if user == nil {
                    self.showAlert(title: "Unknow error", message: "Code: auth_384")
                } else {
                    User.shared = user
                    self.performSegue(withIdentifier: "main_list", sender: self)
                }
            }
        }
    }

}
