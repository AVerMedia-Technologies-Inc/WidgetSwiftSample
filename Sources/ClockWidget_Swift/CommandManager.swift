//
//  CommandManager.swift
//  ClockWidget_Swift
//
//  Created by ShihPing on 2021/10/14.
//

import Foundation

enum Language: String {
    case zh_tw
    case en_us
    case ja_jp
    case ko_kr
}

enum City: String {
    case Taipei = "taipei"
    case NewYork = "new_york"
    case California = "california"
}

enum ClockType: String {
    case Analog = "analog"
    case Digital = "digital"
}

enum HandshakeStep {
    case None
    case PropertyConnected
    case RegisterResponse
    case HandshakeComplete
}

protocol CommandManagerDelegate {
    func connectSuccess()
    func registerSuccess()
    func withoutSettings()
    func getSettings(city: City, type: ClockType)
    func receiveResponse(data: String)
    func setLocale(city: City)
    func setClockType(type: ClockType)
    func switchClockType()
}

class CommandManager: NSObject {
    var widgetUUID: String?
    var delegate: CommandManagerDelegate?
    var packetID:Int = 0
    var handshakeStep = HandshakeStep.None
    
    /// <#Description#>
    /// - Parameter uuid: provided by the Creator Central, the widget id
    func setUUID(uuid: String) {
        widgetUUID = uuid
    }
    
    func setDelegate(obj: CommandManagerDelegate) {
        delegate = obj
    }
    
    private func getPacketID() -> Int {
        packetID = packetID + 1
        return packetID
    }
    
    /// <#Description#>
    /// - Parameter uuid: provided by the Creator Central, the widget id
    /// - Returns: Json
    /// request = {
    ///     "jsonrpc": "2.0",
    ///     "method": "ax.register.widget",
    ///     "params": {
    ///         "id": "<uuid>"
    ///     },
    ///     "id": 0 # must be 0
    /// };
    ///
    /// result = {
    ///     "jsonrpc": "2.0",
    ///     "result": "ax.register.widget",
    ///     "id": 0
    /// }
    func sendRegisterRequest(uuid: String) -> Data {
        let encoder: JSONEncoder = JSONEncoder()
        let content = CommandPacket(jsonrpc: "2.0", method: "ax.register.widget", params: CommandPacket.Parameters(id: uuid, payload: nil, language: nil), result: nil, id: 0)
        let encoded = try! encoder.encode(content)
        return encoded
    }
    
    /// <#Description#>
    /// - Parameter language: language (zh_tw, en_us, ja_jp, ko_kr)
    /// - Returns: Json
    /// event = {
    ///     "jsonrpc": "2.0",
    ///     "method": "ax.set.current.language",
    ///     "params": {
    ///         "language": "en_us"
    ///     }
    /// }
    func setLanguage(language: Language) -> Data {
        let encoder: JSONEncoder = JSONEncoder()
        let content = CommandPacket(jsonrpc: "2.0", method: "ax.set.current.language", params: CommandPacket.Parameters(id: nil, payload: nil, language: language.rawValue), result: nil, id: getPacketID())
        let encoded = try! encoder.encode(content)
        return encoded
    }
    
    /// <#Description#>
    /// - Returns: Json
    /// request = {
    ///     "jsonrpc": "2.0",
    ///     "method": "ax.get.payload",
    ///     "params": {
    ///        "id": "<uuid>"
    ///    }
    /// }
    func getSettings() -> Data {
        let encoder: JSONEncoder = JSONEncoder()
        let content = CommandPacket(jsonrpc: "2.0", method: "ax.get.payload", params: CommandPacket.Parameters(id: widgetUUID!, payload: nil, language: nil), result: nil, id: getPacketID())
        let encoded = try! encoder.encode(content)
        return encoded
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - city: city name
    ///   - type: digital or analog
    /// - Returns: Json
    /// request = {
    ///     "jsonrpc": "2.0",
    ///     "method": "ax.set.payload",
    ///     "params": {
    ///         "id": "<uuid>",
    ///         "payload": {
    ///             "city": "taipei"
    ///             "type": "digital"
    ///         }
    ///     }
    /// }
    func setSettings(city: String, type: String) -> Data {
        let encoder: JSONEncoder = JSONEncoder()
        let content = CommandPacket(jsonrpc: "2.0", method: "ax.set.payload", params: CommandPacket.Parameters(id: widgetUUID!, payload: CommandPacket.Payload(image: nil, action: nil, city: city, type: type), language: nil), result: nil, id: getPacketID())
        let encoded = try! encoder.encode(content)
        return encoded
    }
    
    /// <#Description#>
    /// - Parameter img: base64 string
    /// - Returns: Json
    /// request = {
    ///     "jsonrpc": "2.0",
    ///     "method": "ax.set.image",
    ///     "params": {
    ///         "id": "<uuid>",
    ///         "payload": {
    ///             "image": <base64>
    ///         }
    ///     }
    /// }
    func setImage(img: String) -> Data {
        let encoder: JSONEncoder = JSONEncoder()
        let content = CommandPacket(jsonrpc: "2.0", method: "ax.set.image", params: CommandPacket.Parameters(id: widgetUUID, payload: CommandPacket.Payload(image: img, action: nil, city: nil, type: nil), language: nil), result: nil, id: getPacketID())
        let encoded = try! encoder.encode(content)
        return encoded
    }
    
    /// <#Description#>
    /// - Parameter city: city name
    /// - Returns: Json
    /// request = {
    ///     "jsonrpc": "2.0",
    ///     "method": "ax.send.to.property",
    ///     "params": {
    ///         "id": "<uuid>",
    ///         "payload": {
    ///             "action": "send_city_val",
    ///             "city": "taipei"
    ///         }
    ///     }
    /// }
    func sendToProperty(city: String) -> Data {
        let encoder: JSONEncoder = JSONEncoder()
        let content = CommandPacket(jsonrpc: "2.0", method: "ax.send.to.property", params: CommandPacket.Parameters(id: widgetUUID, payload: CommandPacket.Payload(image: nil, action: "send_city_val", city: city, type: nil), language: nil), result: nil, id: getPacketID())
        let encoded = try! encoder.encode(content)
        return encoded
    }
    
    /// <#Description#>
    /// - Parameter type: clock type (digital or analog)
    /// - Returns: Json
    /// request = {
    ///     "jsonrpc": "2.0",
    ///     "method": "ax.send.to.property",
    ///     "params": {
    ///         "id": "<uuid>",
    ///         "payload": {
    ///             "action": "send_type_val",
    ///             "type": "digital"
    ///         }
    ///     }
    /// }
    func sendToProperty(type: String) -> Data {
        let encoder: JSONEncoder = JSONEncoder()
        let content = CommandPacket(jsonrpc: "2.0", method: "ax.send.to.property", params: CommandPacket.Parameters(id: widgetUUID, payload: CommandPacket.Payload(image: nil, action: "send_type_val", city: nil, type: type), language: nil), result: nil, id: getPacketID())
        let encoded = try! encoder.encode(content)
        return encoded
    }
    
    /// <#Description#>
    /// - Parameter data: data from the Creator Central
    /// Property Connected: The widget should wait until the property is connected before sending a command.
    /// notification = {
    ///     "jsonrpc": "2.0",
    ///     "method": "ax.property.connected",
    ///     "params": {
    ///         "id": "<uuid>"
    ///     },
    ///     "id": 0 # must be 0
    /// };
    func parse(data: Data) {
        let stringTest = String(data: data, encoding: .utf8)
        delegate?.receiveResponse(data: stringTest!)
        let decoder: JSONDecoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(CommandPacket.self, from: data)
            
            if decoded.result == "ax.register.widget" {
                if handshakeStep == .None {
                    handshakeStep = .RegisterResponse
                } else if handshakeStep == .PropertyConnected {
                    handshakeStep = .HandshakeComplete
                    delegate?.registerSuccess()
                }
                return
            }
            
            if decoded.method == "ax.property.connected" {
                if handshakeStep == .None {
                    handshakeStep = .PropertyConnected
                } else if handshakeStep == .RegisterResponse {
                    handshakeStep = .HandshakeComplete
                    delegate?.registerSuccess()
                }
                return
            }
            
            if decoded.method == "ax.send.to.widget" {
                let action = decoded.params?.payload?.action
                if action == "set_type_val" {
                    let type = decoded.params?.payload?.type
                    delegate?.setClockType(type: ClockType(rawValue: type!) ?? .Digital)
                } else if action == "set_city_val" {
                    let city = decoded.params?.payload?.city
                    delegate?.setLocale(city: City(rawValue: city!) ?? .Taipei)
                }
            } else if decoded.method == "ax.update.payload" {
                let type = decoded.params?.payload?.type
                let city = decoded.params?.payload?.city
                if type==nil || city==nil {
                    delegate?.withoutSettings()
                } else {
                    delegate?.getSettings(city: City(rawValue: city!)!, type: ClockType(rawValue: type!)!)
                }
            } else if decoded.method == "ax.widget.triggered" {
                delegate?.switchClockType()
            }
        } catch {
            print(error)
        }
    }
    
    func parse(string: String) {
        let data = string.data(using: .utf8)!
        parse(data: data)
    }
}

extension CommandManager: WebSocketControllerDelegate {
    func parseJsonError(string: String) {
        delegate?.receiveResponse(data: "parse error: [\(string)]")
    }
    
    func connectSuccess() {
        delegate?.connectSuccess()
    }
    
    func disconnect() {
    }
    
    func receive(string: String) {
        parse(string: string)
    }
    
    func receive(data: Data) {
        parse(data: data)
    }
}
