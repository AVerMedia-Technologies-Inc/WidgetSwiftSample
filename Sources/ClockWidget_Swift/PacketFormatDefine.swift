//
//  PacketFormatDefine.swift
//  ClockWidget_Swift
//
//  Created by ShihPing on 2021/10/14.
//

import Foundation

//MARK:- JSON packet format
struct CommandPacket {
    let jsonrpc: String?
    let method: String?
    let params: Parameters?
    let result: String?
    let id: Int?
    
    struct Parameters: Codable {
        let id: String?
        let payload: Payload?
        let language: String?
    }
    
    struct Payload: Codable {
        let image: String?
        let action: String?
        let city: String?
        let type: String?
    }
    
    enum RootKeys: String, CodingKey {
        case jsonrpc, method, params, result, id
    }
    
    enum ParamsKeys: String, CodingKey {
        case id, payload, language
    }
    
    enum PayloadKeys: String, CodingKey {
        case image, action, city, type
    }
}

extension CommandPacket: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        print(container.allKeys)
        jsonrpc = try? container.decode(String.self, forKey: .jsonrpc)
        method = try? container.decode(String.self, forKey: .method)
        params = try? container.decodeIfPresent(Parameters.self, forKey: .params)
        result = try? container.decode(String.self, forKey: .result)
        id = try? container.decode(Int.self, forKey: .id)
    }
}

extension CommandPacket: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encode(method, forKey: .method)
        try container.encodeIfPresent(params, forKey: .params)
        try container.encode(id, forKey: .id)
    }
}
