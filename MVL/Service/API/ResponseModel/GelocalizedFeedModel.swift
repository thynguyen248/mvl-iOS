//
//  GelocalizedFeedModel.swift
//  MVL
//
//  Created by Thy Nguyen on 11/11/21.
//

import Foundation

struct FeedResponseModel: Decodable {
    let data: GelocalizedFeedModel?
}

struct GelocalizedFeedModel: Decodable {
    let aqi: Int?
}

