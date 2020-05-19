import UIKit
import SwiftUIKit
import Combine
import EKit

enum WeatherType: String {
    case clear, clouds, rain, mist
}

extension WeatherType {
    var emoji: String {
        switch self {
        case .clear:
            return E.sun.rawValue
        case .clouds:
            return E.cloud.rawValue
        case .rain:
            return E.cloud_with_rain.rawValue
        case .mist:
            return E.fog.rawValue
        }
    }
}

class ViewController: UIViewController {
    var bag = [AnyCancellable]()
    var table = TableView()
    let zipcodes = ["26554"]
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
                    Navigate.shared.go(AddViewController()
                        .configure { $0.delegate = self }, style: .modal)
                }
            })
        
        table.register(cells: [WeatherCell.self])
            .headerView { _ in UIView() }
            .footerView { _ in UIView() }
            .canEditRowAtIndexPath { _ in true }
            .canMoveRowAtIndexPath { _ in true }
            .shouldHighlightRowAtIndexPath { _ in true }
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
        .didSelectRowAtIndexPath { (path) in
            let data = self.data[path.row]
            
            Navigate.shared.go(
                UIViewController {
                    UIView(backgroundColor: .white) {
                        SafeAreaView {
                            VStack {
                                [
                                    UIView {
                                        Label.title1("\(data.main.temp)F")
                                            .text(alignment: .center)
                                            .font(UIFont.boldSystemFont(ofSize: 72))
                                    }.frame(height: 200),
                                    List {
                                        [
                                            Label.title1(data.name),
                                            Label("\(data.weather.first?.main ?? "") (\(data.weather.first?.description ?? "..."))")
                                        ]
                                    }
                                    .configure {
                                        $0.allowsSelection = false
                                    }
                                ]
                            }
                        }
                        
                    }
            }, style: .push)
        }
        
        view.embed {
            VStack {
                [
                    table,
                    ContainerView(parent: self) {
                        AddViewController()
                            .configure { $0.delegate = self }
                    }
                    .frame(height: 164)
                ]
            }
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

extension ViewController: ItemAddable {
    func add(zipcode: Int) {
        fetch(zipCodeWeather: zipcode)
    }
}
