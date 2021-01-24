//
//  CurrenciesInterfaceController.swift
//  Project4 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/23/21.
//

import WatchKit
import Foundation


class CurrenciesInterfaceController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
    
    let selectedColor = UIColor(red: 0, green: 0.55, blue: 0.25, alpha: 1)
    let deselectedColor = UIColor(red: 0.3, green: 0, blue: 0, alpha: 1)
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Set up as many rows as we have currencies
        table.setNumberOfRows(InterfaceController.currencies.count, withRowType: "Row")
        
        // load the list of selected currencies, or use the default list
        let defaults = UserDefaults.standard
        let selectedCurrencies = defaults.array(forKey: InterfaceController.selectedCurrenciesKey) as? [String] ?? InterfaceController.defaultCurrencies
        
        // loop over all the currencies, configuring the table rows
        for (index, currency) in InterfaceController.currencies.enumerated() {
            guard let row = table.rowController(at: index) as? CurrencyRow else { return }
            
            row.textLabel.setText(currency)
            
            // color the row's group depending on whether it's selected
            if selectedCurrencies.contains(currency) {
                row.group.setBackgroundColor(selectedColor)
            } else {
                row.group.setBackgroundColor(deselectedColor)
            }
        }
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        // 1: grab the row controller and safely typecast
        guard let row = table.rowController(at: rowIndex) as? CurrencyRow else { return }
        
        // 2: pull out the current list of selected currencies, or use the default list
        let defaults = UserDefaults.standard
        var selectedCurrencies = defaults.array(forKey: InterfaceController.selectedCurrenciesKey) as? [String] ?? InterfaceController.defaultCurrencies
        
        // 3: find the name of the tapped currency
        let selectedCurrency = InterfaceController.currencies[rowIndex]
        
        // 4: if that currency was found in our selected currencies, remove it
        if let index = selectedCurrencies.firstIndex(of: selectedCurrency) {
            selectedCurrencies.remove(at: index)
            row.group.setBackgroundColor(deselectedColor)
        } else {
            // 5: otherwise add it
            selectedCurrencies.append(selectedCurrency)
            row.group.setBackgroundColor(selectedColor)
        }
        
        // 6: save the new selected currencies
        defaults.set(selectedCurrencies, forKey: InterfaceController.selectedCurrenciesKey)
    }
}
