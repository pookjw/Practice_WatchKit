//
//  InterfaceController.swift
//  Project4 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/23/21.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var amountLabel: WKInterfaceLabel!
    @IBOutlet weak var amountSlider: WKInterfaceSlider!
    @IBOutlet weak var currencyPicker: WKInterfacePicker!
    
    static let currencies = ["USD", "AUD", "CAD", "CHF", "CNY", "EUR", "GBP", "HKD", "JPY", "SGD"]
    static let defaultCurrencies = ["USD", "EUR"]
    static let selectedCurrenciesKey = "SelectedCurrencies"
    var currentCurrency = "USD"
    var currentAmount = 500
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        var items = [WKPickerItem]()
        
        for currency in Self.currencies {
            let item = WKPickerItem()
            item.title = currency
            items.append(item)
        }
        
        currencyPicker.setItems(items)
    }
    
    @IBAction func amountChanged(_ value: Float) {
        currentAmount = Int(value)
        amountLabel.setText(String(currentAmount))
    }
    
    @IBAction func convertTapped() {
        let context = ["amount": String(currentAmount), "base": currentCurrency]
        WKInterfaceController.reloadRootPageControllers(withNames: ["Results"], contexts: [context], orientation: .horizontal, pageIndex: 0)
    }
    
    @IBAction func baseCurrencyChanged(_ value: Int) {
        currentCurrency = Self.currencies[value]
    }
}
