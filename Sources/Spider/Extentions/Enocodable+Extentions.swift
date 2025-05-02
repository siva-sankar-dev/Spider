//
//  Enocodable+Extentions.swift
//  Spider
//
//  Created by Siva Sankar on 02/05/25.
//

import Foundation

public extension Encodable {
    func toData(using encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        try encoder.encode(self)
    }
    
    func toJSONString(using encoder: JSONEncoder = JSONEncoder()) throws -> String? {
        let data = try toData(using: encoder)
        return String(data: data, encoding: .utf8)
    }
}
