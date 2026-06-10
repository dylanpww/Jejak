//
//  Config.swift
//  journal cam
//
//  Created by Dylan on 07/06/26.
//

import Foundation

enum Config {
    static func value(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let value = dict[key] as? String
        else {
            fatalError("Config.plist missing key: \(key)")
        }
        return value
    }
}
