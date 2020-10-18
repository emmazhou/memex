//
//  Styles.swift
//  Memex
//
//  Created by Emma Zhou on 10/17/20.
//

import Foundation
import SwiftUI

class Styles {
    static var roundedShape = RoundedRectangle(cornerRadius: 10, style: .continuous)

    static var textFieldBackground = Color(UIColor.label.withAlphaComponent(0.05))
    static var textForeground = Color(UIColor.label.withAlphaComponent(0.85))

    static var salmon = Color(UIColor(red: 0.99, green: 0.42, blue: 0.5, alpha: 1))
    static var sky = Color(UIColor(red: 0.2, green: 0.6, blue: 0.84, alpha: 1))
    static var peri = Color(UIColor(red: 0.5, green: 0.46, blue: 0.87, alpha: 1))
    static var lavender = Color(UIColor(red: 0.58, green: 0.35, blue: 0.82, alpha: 1))
    static var magenta = Color(UIColor(red: 1, green: 0.28, blue: 0.72, alpha: 1))
    
    static let warmGradient = LinearGradient(
        gradient: Gradient(colors: [salmon, magenta]),
        startPoint: .leading, endPoint: .trailing
    )
    static let midGradient = LinearGradient(
        gradient: Gradient(colors: [lavender, peri]),
        startPoint: .leading, endPoint: .trailing
    )
    static let coolGradient = LinearGradient(
        gradient: Gradient(colors: [peri, sky]),
        startPoint: .leading, endPoint: .trailing
    )
}
