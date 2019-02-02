//
//  Network.swift
//  Virtual Tourist
//
//  Created by Saud Alhelali on 02/02/2019.
//  Copyright © 2019 Saud Alhelali. All rights reserved.
//

import Foundation

class Network {
    
    var session = URLSession.shared
    private var tasks: [String: URLSessionDataTask] = [:]
    
    class func shared() -> Network {
        struct Singleton {
            static var shared = Network()
        }
        return Singleton.shared
    }
    
    func searchBy(latitude: Double, longitude: Double, totalPages: Int?, completion: @escaping (_ result: PhotosParser?, _ error: Error?) -> Void) {
        
        // choosing a random page.
        var page: Int {
            if let totalPages = totalPages {
                let page = min(totalPages, 4000/APIParameterValues.PhotosPerPage)
                return Int(arc4random_uniform(UInt32(page)) + 1)
            }
            return 1
        }
        let bboxVal = bbox(latitude: latitude, longitude: longitude)
        
        let parameters = [
            APIParameterKeys.Method           : APIParameterValues.SearchMethod
            , APIParameterKeys.APIKey         : APIParameterValues.APIKey
            , APIParameterKeys.Format         : APIParameterValues.ResponseFormat
            , APIParameterKeys.Extras         : APIParameterValues.MediumURL
            , APIParameterKeys.NoJSONCallback : APIParameterValues.DisableJSONCallback
            , APIParameterKeys.BoundingBox    : bboxVal
            , APIParameterKeys.PhotosPerPage  : "\(APIParameterValues.PhotosPerPage)"
            , APIParameterKeys.Page           : "\(page)"
        ]
        
        _ = GetCall(parameters: parameters) { (data, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "Could not retrieve data."]
                completion(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
                return
            }
            
            do {
                let photosParser = try JSONDecoder().decode(PhotosParser.self, from: data)
                completion(photosParser, nil)
            } catch {
                print("\(#function) error: \(error)")
                completion(nil, error)
            }
        }
    }
    
    func downloadImage(imageUrl: String, result: @escaping (_ result: Data?, _ error: NSError?) -> Void) {
        guard let url = URL(string: imageUrl) else {
            return
        }
        let task = GetCall(nil, url, parameters: [:]) { (data, error) in
            result(data, error)
            self.tasks.removeValue(forKey: imageUrl)
        }
        
        if tasks[imageUrl] == nil {
            tasks[imageUrl] = task
        }
    }
    
}

extension Network {
    
    // MARK: - GET
    func GetCall(
        _ method               : String? = nil,
        _ customUrl            : URL? = nil,
        parameters             : [String: String],
        completionHandlerForGET: @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request: NSMutableURLRequest!
        if let customUrl = customUrl {
            request = NSMutableURLRequest(url: customUrl)
        } else {
            request = NSMutableURLRequest(url: buildURLFromParameters(parameters, withPathExtension: method))
        }
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            if let error = error {
                
                // the request got canceled
                if (error as NSError).code == URLError.cancelled.rawValue {
                    completionHandlerForGET(nil, nil)
                } else {
                    sendError("There was an error with your request: \(error.localizedDescription)")
                }
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            completionHandlerForGET(data, nil)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func buildURLFromParameters(_ parameters: [String: String], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = API.Schema
        components.host = API.Host
        components.path = API.Path + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: value)
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    private func bbox(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        let minimumLon = max(longitude - API.SearchBBoxHalfWidth, API.SearchLonRange.0)
        let minimumLat = max(latitude  - API.SearchBBoxHalfHeight, API.SearchLatRange.0)
        let maximumLon = min(longitude + API.SearchBBoxHalfWidth, API.SearchLonRange.1)
        let maximumLat = min(latitude  + API.SearchBBoxHalfHeight, API.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
}
