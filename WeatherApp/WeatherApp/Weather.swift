//
//  Weather.swift
//  WeatherApp
//
//  Created by Daria on 15/09/2019.
//  Copyright © 2019 D.Misch. All rights reserved.
//

import Foundation
import CoreLocation

struct Weather {
    let temp:Double
    let description:String
    let icon:String
    let name:String
    
    enum SerializationError:Error {
        case missing(String)
    }
    
    init(json:[String:Any]) throws {
        guard let temp = json["temp"] as? Double else {throw SerializationError.missing("temp is missing")}
        
        guard let description = json["description"] as? String else {throw SerializationError.missing("description is missing")}
        
        guard let icon = json["icon"] as? String else {throw SerializationError.missing("icon is missing")}
        guard let name = json["name"] as? String else {throw SerializationError.missing("name is missing")}
        self.temp = temp
        self.description = description
        self.icon = icon
        self.name = name
    }
    
    
    static func forecast (withLocation location:CLLocationCoordinate2D, completion: @escaping ([Weather]?) -> ()) {
        
        let lat = location.latitude
        let lon = location.longitude
        
        let basePath = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=7825e551018559bf92b8e1d21cec37a8"
        
        let url = URLRequest(url: URL(string: basePath)!)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            var forecastArray:[Weather] = []
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let listForecast = json["list"] as? [String:Any] {
                            if let mainListForecast = listForecast["main"] as? [[String:Any]] {
                                for data in mainListForecast {
                                    if let weatherObject = try? Weather(json: data) {
                                        forecastArray.append(weatherObject)
                                    }
                                }
                            }
                            if let weatherListForecast = listForecast["weather"] as? [[String:Any]] {
                                for data in weatherListForecast {
                                    if let weatherObject = try? Weather(json: data) {
                                        forecastArray.append(weatherObject)
                                    }
                                }
                            }
                        }                        
                    }
                }catch {
                    print(error.localizedDescription)
                }
                completion(forecastArray)
            }
        }
        task.resume()
    }
}
