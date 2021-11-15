//
//  GetFeedRequestModel.swift
//  MVL
//
//  Created by Thy Nguyen on 11/11/21.
//

import Foundation

struct GetFeedRequestModel: Encodable {
    let geo: String
    let token: String
    
    enum CodingKeys: String, CodingKey {
        case token
    }
}

extension GetFeedRequestModel {
    init(latitude: Double, longitude: Double) {
        geo = String(format: "geo:%.1f;%.1f", latitude, longitude)
        token = Constant.aqiAPIKey
    }
}
