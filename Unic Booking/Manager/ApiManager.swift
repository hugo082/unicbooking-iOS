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
    let executionDetailsEndPoint = "/execution/"
    
    var headers: HTTPHeaders? {
        guard let token = Credential.shared?.token else { return nil }
        return [
            "Authorization": "Bearer " + token,
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
    }
    
    // MARK: - User
    
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
    
    // MARK: - Execution
    
    func update(_ execution: Execution, completionHandler: @escaping (Error?) -> Void) {
        guard let url = self.getUrl(execution) else { return }
        let parameters: Parameters = ["current_step" : (execution.forceCurrentStepIndex + 1), "note" : execution.currentStep?.note ?? ""]
        self.coreRequest(type: Execution.self, url: url, method: .put, parameters: parameters, encoding: URLEncoding.default, headers: self.headers) { object, error in
            if let object = object {
                execution.update(from: object)
            }
            completionHandler(error)
        }
    }
    
    // MARK: - Genrics
    
    func list<Type: Model>(model: Type.Type, completionHandler: @escaping ([Type]?, Error?) -> Void) {
        guard let url = self.getUrl(model) else { return }
        self.coreRequest(url: url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.headers) { data, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let objects = try decoder.decode([Type].self, from: data)
                    let manager = DataManager.shared.manager(object: model)
                    manager?.push(objects: objects)
                    manager?.isLoaded = true
                    completionHandler(objects, nil)
                } catch let error {
                    completionHandler(nil, error)
                }
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    func detail<Type: Model>(model: Type, completionHandler: @escaping (Type?, Error?) -> Void) {
        guard let url = self.getUrl(model) else { return }
        self.coreRequest(type: Type.self, url: url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.headers) { object, error in
            if let object = object {
                let manager = DataManager.shared.manager(object: type(of: model))
                manager?.push(object: object)
                completionHandler(object, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    func update<Type: Updatable>(model: Type, completionHandler: @escaping (Error?) -> Void) {
        guard let url = self.getUrl(model) else { return }
        self.coreRequest(type: Type.self, url: url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.headers) { object, error in
            if let object = object {
                model.update(from: object)
                completionHandler(nil)
            }
            completionHandler(error)
        }
    }
    
    // MARK: Core Request
    
    func coreRequest<Type: Decodable>(type: Type.Type, url: URLConvertible, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, headers: HTTPHeaders?, completionHandler: @escaping (Type?, Error?) -> Void) {
        self.coreRequest(url: url, method: method, parameters: parameters, encoding: encoding, headers: headers) { data, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let object = try decoder.decode(Type.self, from: data)
                    completionHandler(object, nil)
                } catch let error {
                    completionHandler(nil, error)
                }
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    func coreRequest(url: URLConvertible, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, headers: HTTPHeaders?, completionHandler: @escaping (Data?, Error?) -> Void) {
        Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).validate().responseString { response in
            switch response.result {
            case .success:
                guard let jsonData = response.result.value?.data(using: .utf8) else {
                    completionHandler(nil, RequestError.encodageFailed)
                    return
                }
                completionHandler(jsonData, nil)
            case .failure(let error):
                completionHandler(nil, error)
                break
            }
        }
    }
    
    // MARK: - Url
    
    func getUrl(_ model: Model) -> String? {
        guard let url = self.getUrl(type(of: model)) else { return nil}
        return url + "/\(model.id)"
    }
    
    func getUrl(_ model: Model.Type) -> String? {
        let endPoint: String
        switch model {
        case is Product.Type:
            endPoint = "/product"
        case is Book.Type:
            endPoint = "/book"
        case is Execution.Type:
            endPoint = "/execution"
        default:
            return nil
        }
        return baseURL + endPoint
    }
}
