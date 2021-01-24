//
//  CurrencyResult.swift
//  Project4 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/24/21.
//

import Foundation

struct CurrencyResult: Codable {
    var base: String
    var rates: [String: Double]
}
