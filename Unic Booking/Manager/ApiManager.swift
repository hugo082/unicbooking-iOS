//
//  ApiManager.swift
//  Unic Booking
//
//  Created by Hugo Fouquet on 29/07/2017.
//  Copyright © 2017 Hugo Fouquet. All rights reserved.
//

import Foundation
import Alamofire

class ApiManager {
    
    enum RequestError: Error {
        case encodageFailed
    }
    
    static let shared = ApiManager()
    
    let baseURL = Configuration.environment.baseURL
    let loginEndPoint = "/login_check"
    let userDetailsEndPoint = "/user/detail"
    let productListEndPoint = "/product"
    
    var headers: HTTPHeaders? {
        guard let token = Credential.shared?.token else { return nil }
        return [
            "Authorization": "Bearer " + token,
            "Accept": "application/json"
        ]
    }
    
    // Mark: - User
    
    func login(credential: Credential, completionHandler: @escaping (String?, Error?) -> Void) {
        let url = baseURL + loginEndPoint
        let parameters: Parameters = [
            "username": credential.username,
            "password": credential.password!
        ]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let json = response.result.value as? Dictionary<String,String> {
                    completionHandler(json["token"], nil)
                } else {
                    completionHandler(nil, RequestError.encodageFailed)
                }
            case .failure(let error):
                completionHandler(nil, error)
                break
            }
        }
    }
    
    func getUserDetails(completionHandler: @escaping (User?, Error?) -> Void) {
        let url = baseURL + userDetailsEndPoint
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.headers).validate().responseString { response in
            switch response.result {
            case .success:
                guard let jsonData = response.result.value?.data(using: .utf8) else {
                    completionHandler(nil, RequestError.encodageFailed)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let user = try decoder.decode(User.self, from: jsonData)
                    //DataManager.shared.productManager.push(objects: products)
                    completionHandler(user, nil)
                } catch let error {
                    completionHandler(nil, error)
                }
            case .failure(let error):
                completionHandler(nil, error)
                break
            }
        }
    }
    
    // Mark: - Products
    
    func getProducts(completionHandler: @escaping ([Product]?, Error?) -> Void) {
        let url = baseURL + productListEndPoint
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.headers).validate().responseString { response in
            switch response.result {
            case .success:
                guard let jsonData = response.result.value?.data(using: .utf8) else {
                    completionHandler(nil, RequestError.encodageFailed)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let products = try decoder.decode([Product].self, from: jsonData)
                    DataManager.shared.productManager.push(objects: products)
                    completionHandler(products, nil)
                } catch let error {
                    completionHandler(nil, error)
                }
            case .failure(let error):
                completionHandler(nil, error)
                break
            }
        }
    }
    
    func list<Type: Model>(model: Type.Type, completionHandler: @escaping ([Type]?, Error?) -> Void) {
        guard let endPoint = self.listEndPoint(model) else { return }
        Alamofire.request(baseURL + endPoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.headers).validate().responseString { response in
            switch response.result {
            case .success:
                guard let jsonData = response.result.value?.data(using: .utf8) else {
                    completionHandler(nil, RequestError.encodageFailed)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let objects = try decoder.decode([Type].self, from: jsonData)
                    let manager = DataManager.shared.manager(object: model)
                    manager?.push(objects: objects)
                    manager?.isLoaded = true
                    completionHandler(objects, nil)
                } catch let error {
                    completionHandler(nil, error)
                }
            case .failure(let error):
                completionHandler(nil, error)
                break
            }
        }
    }
    
    func listEndPoint(_ model: Model.Type) -> String? {
        switch model {
        case is Product.Type:
            return "/product"
        case is Book.Type:
            return "/book"
        default:
            return nil
        }
    }
}
