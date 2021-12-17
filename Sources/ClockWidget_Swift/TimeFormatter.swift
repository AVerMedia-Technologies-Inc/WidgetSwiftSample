//
//  TimeFormatter.swift
//  ClockWidget_Swift
//
//  Created by ShihPing on 2021/10/25.
//
import Foundation

enum Locale: String {
    case taipei = "GMT+08"
    case new_york = "EDT"
    case california = "PDT"
}

extension DateFormatter {
    /// <#Description#>
    /// - Parameter locale: Locale
    /// - Returns: DateFormatter
    static func getTime(locale: Locale) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: locale.rawValue)
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }
}
