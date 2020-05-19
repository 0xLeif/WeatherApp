//
//  WeatherCell.swift
//  WeatherApp
//
//  Created by Zach Eriksen on 5/12/20.
//  Copyright © 2020 oneleif. All rights reserved.
//

import UIKit
import SwiftUIKit

class WeatherCell: UITableViewCell {
    let nameLabel = Label.title1("")
    let weatherTitle = Label.title2("")
    let weatherDescription = Label.body("")
    let temp = Label.title1("")
    let zipcodeLabel = Label.headline("")
}

extension WeatherCell: TableViewCell {
    func configure(forData data: CellDisplayable) {
        guard let data = data as? WeatherForecast else {
            return
        }
        
        
        contentView
            .clear()
            .embed(withPadding: 8) {
                HStack {
                    [
                        VStack {
                            [
                                HStack(withSpacing: 4) {
                                    [
                                        self.nameLabel,
                                        self.weatherTitle
                                    ]
                                },
                                self.zipcodeLabel
                            ]
                        },
                        Spacer(),
                        self.temp
                    ]
                }
                
        }
    }
    
    func update(forData data: CellDisplayable) {
        guard let data = data as? WeatherForecast else {
            return
        }
        
        if let weatherType = data.weather.first?.main,
            let weather = WeatherType(rawValue: weatherType.lowercased()) {
            weatherTitle.text = weather.emoji
        }
        
        zipcodeLabel.text = "\(data.zipcode ?? 0)" 
        nameLabel.text = data.name
        temp.text = "\(data.main.temp)F"
    }
    
    static var ID: String {
        "weather"
    }
}
