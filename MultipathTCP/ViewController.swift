//
//  ViewController.swift
//  MultipathTCP
//
//  Created by Alexander v. Below on 07.08.17.
//  Copyright © 2017 Deutsche Telekom AG. All rights reserved.
//

import UIKit

// Structure for MPTCP Statistics

public struct SlowStart : Codable {
    var rtt : Double // Round Trip Time
    var rtt2 : Double // Round Trip Time 2
    var rto : Double // Retransmission TimeOut
    var cwnd : Double // congestion window
}

public struct Subflow : Codable {
    var id : String
    var send : Int
    var recv : Int
    var srtt : Int
    var mdev : Int
    var packetsOut : Int
    var retransOut : Int
    var sndCwnd : Int
    var source : String
    var dest : String
    var ex1 : String
    var ex2 : String
}

public struct Proc : Codable {
    var mptcp : Bool
    var ns : Int?
    var scheduler : String?
    var timestamp : Int?
    var subflows : [Subflow]?
}

struct MPTCPStats : Codable {
    var ss : SlowStart
    var proc : Proc
    var mptcp : Bool
    var persCounter : Int
    var interval : Int
}

// My own custom error

enum RequestError : Error {
    case noData
}

extension RequestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noData:
            return NSLocalizedString("The server returned no data", comment: "No data error")
        }
    }
}
class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var schedulerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.selectRow(1, inComponent: 0, animated: false    )
    }

    // Load MPTCP
    
    func loadWithMultipathServiceType ( _ type : URLSessionConfiguration.MultipathServiceType, handler:@escaping (MPTCPStats?, Error?) -> Void) {
        let urlString = "http://amiusingmptcp.de/v1/check_connection"
        
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.multipathServiceType = type
        let session = URLSession(configuration: sessionConfiguration)
        let url = URL(string: urlString)!
        session.dataTask(with: url) { (data, response, error) in
            
            // Error 1: Check error variable
            
            if let data = data {
                
                let decoder = JSONDecoder()
                do {
                    let stats = try decoder.decode(MPTCPStats.self, from: data)
                    handler (stats, nil)
                }
                catch {
                    handler (nil, error)
                }
                if let string = String(data: data, encoding: .utf8) {
                    print (string)
                }
            }
            else {
                handler(nil, RequestError.noData)
            }
            
            }.resume()
    }
    
    // Picker View
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    @IBAction func send() {
        self.resultLabel.text = ""
        let t = pickerView.selectedRow(inComponent: 0)
        if let type = URLSessionConfiguration.MultipathServiceType(rawValue: t) {
            self.resultLabel.text = "Loading …"
            self.loadWithMultipathServiceType(type) { (stats, error) in
                var text = "❌ No Multipath Connection"
                var scheduler = ""
                if let error = error {
                    text = "☠️" + error.localizedDescription
                }
                else {
                    if let stats = stats {
                        if stats.mptcp == true {
                            text = "✔️ Multipath Connection"
                        }
                        scheduler = stats.proc.scheduler ?? ""
                    }
                    
                }
                DispatchQueue.main.async {
                    self.resultLabel.text = text
                    self.schedulerLabel.text = scheduler
                }
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 1:
            return "Handover"
        case 2:
            return "Interactive"
        case 3:
            return "Aggregate"
        default:
            return "None"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

