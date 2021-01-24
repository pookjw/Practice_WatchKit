//
//  ResultsInterfaceController.swift
//  Project4 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/24/21.
//

import WatchKit
import Foundation


class ResultsInterfaceController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
    @IBOutlet weak var status: WKInterfaceLabel!
    @IBOutlet weak var done: WKInterfaceButton!
    
    var fetchedCurrencies = [(symbol: String, rate: Double)]()
    var amountToConvert = 0.0
    let appID = "051bce45cd804955bfdfedbab80dd347"
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let settings = context as? [String: String] else { return }
        guard let amount = settings["amount"] else { return }
        guard let baseCurrency = settings["base"] else { return }
        
        amountToConvert = Double(amount) ?? 50
        setTitle("\(amount) \(baseCurrency)")
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.fetchData(for: baseCurrency)
        }
    }
    
    override func willActivate() {
        super.willActivate()
        WKExtension.shared().isAutorotating = true
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        WKExtension.shared().isAutorotating = false
    }
    
    @IBAction func doneTapped() {
        WKInterfaceController.reloadRootPageControllers(withNames: ["Home", "Currencies"], contexts: nil, orientation: .horizontal, pageIndex: 0)
    }
    
    func fetchData(for baseCurrency: String) {
        if let url = URL(string: "https://openexchangerates.org/api/latest.json?app_id=\(appID)&base=\(baseCurrency)") {
            let urlRequest = URLRequest(url: url)
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let data = data {
                    self.parse(data)
                } else {
                    DispatchQueue.main.async {
                        self.status.setText("Fetch failed")
                        self.done.setHidden(false)
                    }
                }
            }.resume()
        }
    }
    
    func parse(_ contents: Data) {
        let decoder = JSONDecoder()
        
        guard let result = try? decoder.decode(CurrencyResult.self, from: contents) else {
            // we failed to decode - show an error!
            DispatchQueue.main.async {
                self.status.setText("Fetch failed")
                self.done.setHidden(false)
            }
            
            return
        }
        
        // load their currency selection
        let defaults = UserDefaults.standard
        let selectedCurrencies = defaults.array(forKey: InterfaceController.selectedCurrenciesKey) as? [String] ?? InterfaceController.defaultCurrencies
        
        for symbol in result.rates {
            // only include currencies the user wants
            guard selectedCurrencies.contains(symbol.key) else { continue }
            let rateName = symbol.key
            let rateValue = symbol.value
            fetchedCurrencies.append((symbol: rateName, rate: rateValue))
        }
        
        updateTable()
        status.setHidden(true)
        table.setHidden(false)
        done.setHidden(false)
    }
    
    func updateTable() {
        // load as many rows as we have currencies
        table.setNumberOfRows(fetchedCurrencies.count, withRowType: "Row")
        
        // loop over each currency, getting its position and symbol
        for (index, currency) in fetchedCurrencies.enumerated() {
            // find the row at that position
            guard let row = table.rowController(at: index) as? CurrencyRow else { return }
            
            // multiply the rate by the user's input amount
            let value = currency.rate * amountToConvert
            
            // convert it to a rounded string
            let formattedValue = String(format: "%.2f", value)
            
            // show it in the label
            row.textLabel.setText("\(formattedValue) \(currency.symbol)")
        }
    }
}
