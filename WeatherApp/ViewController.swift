import UIKit
import SwiftUIKit
import Combine

enum WeatherType: String {
    case clear
    case clouds
}

extension WeatherType {
    var emoji: String {
        switch self {
        case .clear:
            return "☀️"
        case .clouds:
            return "☁️"
        }
    }
}

class ViewController: UIViewController {
    var bag = [AnyCancellable]()
    var table = TableView()
    let zipcodes = ["26554",
    "Fairmont, WV",
    "29483",
    "Summerville, SC",
    "45103",
    "Batavia, OH",
    "61821",
    "43035",
    "43612",
    "Toledo, OH",
    "16101",
    "New Castle, PA",
    "36109",
    "Montgomery, AL",
    "44012",
    "Avon Lake, OH",
    "32159",
    "Lady Lake, FL",
    "46383",
    "Valparaiso, IN",
    "48150",
    "Livonia, MI",
    "60062",
    "Northbrook, IL",
    "78023",
    "Helotes, TX",
    "48205",
    "Detroit, MI",
    "19061",
    "Marcus Hook, PA",
    "43040",
    "Marysville, OH",
    "30721",
    "Dalton, GA",
    "01970",
    "Salem, MA",
    "95050",
    "Santa Clara, CA",
    "14075",
    "Hamburg, NY",
    "43081",
    "Westerville, OH",
    "46060",
    "Noblesville, IN",
    "27529",
    "Garner, NC",
    "07731",
    "Howell, NJ",
    "29577",
    "Myrtle Beach, SC",
    "33952",
    "Port Charlotte, FL",
    "01876"]
        .compactMap { Int($0) }
    var data: [WeatherForecast] = [] {
        didSet {
            DispatchQueue.main.async {
                self.table.update { _ in
                    [
                        self.data
                    ]
                }
                .reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Navigate.shared.configure(controller: navigationController)
            .setLeft(barButtons: [
                UIBarButtonItem {
                    Button("Edit") {
                        self.table.isEditing.toggle()
                    }
                },
                UIBarButtonItem {
                    Button("Fetch") {
                        self.zipcodes.forEach {
                            self.fetch(zipCodeWeather: $0)
                        }
                    }
                }
            ])
            .setRight(barButton: UIBarButtonItem {
                Button("Add") {
                    Navigate.shared.go(UIViewController {
                        UIView(backgroundColor: .white) {
                            var zipcodeValue: Int?
                            
                            return VStack {
                                [
                                    HStack {
                                        [
                                            Button("Cancel") {
                                                Navigate.shared.dismiss()
                                            },
                                            Spacer(),
                                            Button("Add") {
                                                print("Do stuff")
                                                guard let zipcode = zipcodeValue else {
                                                    Navigate.shared.toast(style: .error, pinToTop: true, secondsToPersist: 3, padding: 16) {
                                                        Label("Zipcode Required!")
                                                    }
                                                    return
                                                }
                                                
                                                self.fetch(zipCodeWeather: zipcode)
                                                Navigate.shared.dismiss()
                                            }
                                        ]
                                    }
                                    .padding(8),
                                    Label("Zipcode").text(alignment: .center),
                                    Field(value: "", placeholder: "12345", keyboardType: .numberPad)
                                        .inputHandler { (value) in
                                        zipcodeValue = Int(value)
                                    },
                                    Spacer()
                                ]
                            }
                        .padding()
                        }
                    }, style: .modal)
                }
            })
        
        table.register(cells: [WeatherCell.self])
            .headerView { _ in UIView() }
            .footerView { _ in UIView() }
            .canEditRowAtIndexPath { _ in true }
            .canMoveRowAtIndexPath { _ in true }
            .editingStyleForRowAtIndexPath { _ in .delete }
            .commitEditingStyleForRowAtIndexPath({ (style, path) in
                self.data.remove(at: path.row)
            })
            .moveRowAtSourceIndexPathToDestinationIndexPath { (from, to) in
                let fromData = self.data[from.row]
                
                self.data.remove(at: from.row)
                
                self.data.insert(fromData, at: to.row)
        }
        .leadingSwipeActionsConfigurationForRowAtIndexPath { (path) -> UISwipeActionsConfiguration in
            UISwipeActionsConfiguration(actions: [
                UIContextualAction(style: .normal, title: "Move to Top", handler: { (action, view, comp) in
                    let fromData = self.data[path.row]
                    
                    self.data.remove(at: path.row)
                    
                    self.data.insert(fromData, at: 0)
                })
            ])
        }
        
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
                guard var weather = try? JSONDecoder().decode(WeatherForecast.self, from: data) else {
                    return
                }
                weather.zipcode = zipcode
                
                if let index = self.data.firstIndex(where: { $0.zipcode == zipcode }) {
                    self.data[index] = weather
                } else {
                    self.data.append(weather)
                }
        }.store(in: &bag)
    }
}
