import UIKit
import SwiftUIKit
import Combine

class ViewController: UIViewController {
    var bag = [AnyCancellable]()
    var table = TableView()
    let zipcodes = [33060, 91010, 32084, 04106, 44720]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Navigate.shared.configure(controller: navigationController)
        
        table.register(cells: [WeatherCell.self])
            .headerView { _ in UIView() }
            .footerView { _ in UIView() }
        
        view.embed {
            table
        }
        
        zipcodes.forEach {
            fetch(zipCodeWeather: $0)
        }
    }
    
    func fetch(zipCodeWeather zipcode: Int) {
        URLSession.shared.dataTaskPublisher(for: URL(string: "https://api.openweathermap.org/data/2.5/weather?zip=\(zipcode),us&appid=fee115205fbe7fe93bae2a86baad8e7f&units=imperial")!)
            .sink(receiveCompletion: { _ in }) { (data, response) in
                guard let weather = try? JSONDecoder().decode(WeatherForecast.self, from: data) else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.table.append {
                        [
                            [weather]
                        ]
                    }
                    .reloadData()
                }
        }.store(in: &bag)
    }
}

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
}

extension WeatherForecast: CellDisplayable {
    var cellID: String {
        WeatherCell.ID
    }
}

class WeatherCell: UITableViewCell {
    let nameLabel = Label.title1("")
    let weatherTitle = Label.title2("")
    let weatherDescription = Label.body("")
    let temp = Label.title1("")
}

extension WeatherCell: TableViewCell {
    func configure(forData data: CellDisplayable) {
        guard let data = data as? WeatherForecast else {
            return
        }
        
        contentView
            .clear()
            .embed(withPadding: 8) {
                Button({ Navigate.shared.go(UIViewController {
                    UIView(backgroundColor: .white) {
                        SafeAreaView {
                        VStack {
                            [
                                Label("\(data.main.temp)F"),
                                Label(data.name),
                                Label(data.weather.first?.main ?? ""),
                                Label(data.weather.first?.description ?? ""),
                                Spacer()
                            ]
                        }
                        }
                        
                    }
                }, style: .push) }) {
                    HStack {
                        [
                            VStack {
                                [
                                    self.nameLabel,
                                    self.weatherTitle,
                                    self.weatherDescription
                                ]
                            },
                            Spacer(),
                            self.temp
                        ]
                    }
                }
        }
    }
    
    func update(forData data: CellDisplayable) {
        guard let data = data as? WeatherForecast else {
            return
        }
        
        nameLabel.text = data.name
        weatherTitle.text = data.weather.first?.main
        weatherDescription.text = data.weather.first?.description
        temp.text = "\(data.main.temp)F"
    }
    
    static var ID: String {
        "weather"
    }
}
