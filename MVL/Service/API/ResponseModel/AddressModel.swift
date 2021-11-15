//
//  AddressModel.swift
//  MVL
//
//  Created by Thy Nguyen on 11/11/21.
//

import Foundation

struct AddressResponseModel: Codable {
    let localityInfo: LocalityInfoModel?
}

struct LocalityInfoModel: Codable {
    let administrative: [AddressModel]?
}

struct AddressModel: Codable {
    let order: Int?
    let name: String?
}
