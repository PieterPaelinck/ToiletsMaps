//
//  Address.swift
//  ToiletMaps
//
//  Created by Pieter Paelinck on 28/12/2019.
//  Copyright © 2019 Pieter Paelinck. All rights reserved.
//

import Foundation

struct Address : Codable {
    let address : String
    
    enum CodingKeys : String, CodingKey {
        case address = "display_name"
    }
    
    init(from decoder : Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.address = try valueContainer.decode(String.self, forKey: CodingKeys.address)
    }
}
