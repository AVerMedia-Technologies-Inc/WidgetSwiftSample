//
//  main.swift
//  ClockWidget_Swift
//
//  Created by ShihPing on 2021/10/25.
//

import Foundation
import SwiftUI

let args = Array(CommandLine.arguments.dropFirst())

let commandManager = CommandManager()
let webSocket = WebSocketController()
let customClock = Clock()
let responseHandle = ResponseHandle()
var pluginUUID: String = ""
var serverUrl: String = ""
var locale = Locale.taipei
var currentCity = City.Taipei
var currentClockType = ClockType.Digital

/// <#Description#>
/// command manager callback function
class ResponseHandle: CommandManagerDelegate {
    
    func connectSuccess() {
        DispatchQueue.main.async {
            register()
        }
    }
    
    func registerSuccess() {
        DispatchQueue.main.async {
            getSettingsFromCreatorCenter()
        }
    }
    
    func withoutSettings() {
        DispatchQueue.main.async {
            customClock.startDrawDigitalClock()
            updateSettings()
            sendToProperty()
        }
    }
    
    func getSettings(city: City, type: ClockType) {
        DispatchQueue.main.async {
            currentCity = city
            syncCityAndLocale(city: city)
            currentClockType = type
            switch type {
            case .Digital:
                customClock.startDrawDigitalClock()
            case .Analog:
                customClock.startDrawAnalogClock()
            }
            sendToProperty()
        }
    }
    
    func receiveResponse(data: String) {
    }
    
    func setLocale(city: City) {
        DispatchQueue.main.async {
            currentCity = city
            syncCityAndLocale(city: city)
            updateSettings()
        }
    }
    
    func setClockType(type: ClockType) {
        DispatchQueue.main.async {
            currentClockType = type
            switch type {
            case .Digital:
                customClock.stopDrawClock()
                customClock.startDrawDigitalClock()
            case .Analog:
                customClock.stopDrawClock()
                customClock.startDrawAnalogClock()
            }
            updateSettings()
            sendToProperty()
        }
    }
    
    func switchClockType() {
        if currentClockType == .Digital {
            setClockType(type: .Analog)
        } else if currentClockType == .Analog {
            setClockType(type: .Digital)
        }
    }
}

/// <#Description#>
/// draw clock: digital or analog
class Clock: NSObject {
    var timer: Timer? = nil
    func startDrawDigitalClock() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
            let date = Date()
            let timeText = DateFormatter.getTime(locale: locale).string(from: date)
            let clockImage = NSImage(size: NSSize(width: 300, height: 120)).addTextToImage(drawText: timeText)
            let imageBase64 = clockImage.base64String()
            let request = commandManager.setImage(img: imageBase64!)
            webSocket.send(data: request)
        }
    }
    
    func startDrawAnalogClock() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
            let clockImage = AnalogClock(locale: locale).body.renderAsImage()
            let imageBase64 = clockImage?.base64String()
            let request = commandManager.setImage(img: imageBase64!)
            webSocket.send(data: request)
        }
    }
    
    func stopDrawClock() {
        self.timer?.invalidate()
    }
}

/// <#Description#>
/// - Parameter city: the property value
/// sync locale and city
func syncCityAndLocale(city: City) {
    switch city {
    case .Taipei:
        locale = .taipei
    case .NewYork:
        locale = .new_york
    case .California:
        locale = .california
    }
}

/// <#Description#>
/// - Parameter port: provided by the Creator Central
func connect(port: String) {
    webSocket.delegate = commandManager
    serverUrl = "ws://127.0.0.1:\(port)/"
    webSocket.connect(urlString: serverUrl)
}

/// <#Description#>
/// register the plugin in Creator Central
func register() {
    let request = commandManager.sendRegisterRequest(uuid: pluginUUID)
    webSocket.send(data: request)
}

/// <#Description#>
/// get settings from Creator Central
func getSettingsFromCreatorCenter() {
    let request = commandManager.getSettings()
    webSocket.send(data: request)
}

/// <#Description#>
/// set settings to Creator Central
func updateSettings() {
    let request = commandManager.setSettings(city: currentCity.rawValue, type: currentClockType.rawValue)
    webSocket.send(data: request)
}

/// <#Description#>
/// init the property value
func sendToProperty() {
    var request = commandManager.sendToProperty(city: currentCity.rawValue)
    webSocket.send(data: request)
    
    request = commandManager.sendToProperty(type: currentClockType.rawValue)
    webSocket.send(data: request)
}

/// Main Function
do {
    if CommandLine.arguments.count < 2 {
        print("Miss arguments! Please input uuid and port.")
    } else {
        pluginUUID = args[0]
        commandManager.setUUID(uuid: pluginUUID)
        commandManager.delegate = responseHandle
        connect(port: args[1])
    }
    while RunLoop.main.run(mode: .default, before: .distantFuture) {
        
    }
}
