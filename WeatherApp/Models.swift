//
//  Models.swift
//  WeatherApp
//
//  Created by Zach Eriksen on 5/12/20.
//  Copyright © 2020 oneleif. All rights reserved.
//

import Foundation
import SwiftUIKit

struct Weather: Codable {
    let description: String
    let main: String
}

struct Temp: Codable {
    let feels_like: Double
    let humidity: Int
    let pressure: Int
    let temp: Double
    let temp_max: Double
    let temp_min: Double
}

struct WeatherForecast: Codable {
    let name: String
    let weather: [Weather]
    let main: Temp
    var zipcode: Int?
}

extension WeatherForecast: CellDisplayable {
    var cellID: String {
        WeatherCell.ID
    }
}
