import UIKit
import SwiftUIKit

protocol ItemAddable: class {
    func add(zipcode: Int)
}

class AddViewController: UIViewController {
    weak var delegate: ItemAddable?
    
    private var zipCodeLabel = Label("Zipcode")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.background(color: .white).embed {
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
                                self.delegate?.add(zipcode: zipcode)
                                Navigate.shared.dismiss()
                            }
                        ]
                    }
                    .padding(8),
                    self.zipCodeLabel.text(alignment: .center),
                    Field(value: "", placeholder: "12345", keyboardType: .numberPad)
                        .inputHandler { [weak self] (value) in
                            zipcodeValue = Int(value)
                            self?.zipCodeLabel.text = "\(zipcodeValue ?? 0)"
                    },
                    Spacer()
                ]
            }
            .padding()
        }
    }
}
