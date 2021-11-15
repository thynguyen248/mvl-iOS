//
//  GetAddressRequestModel.swift
//  MVL
//
//  Created by Thy Nguyen on 11/11/21.
//

import CoreLocation

struct GetAddressRequestModel: Encodable {
    let latitude: Double?
    let longitude: Double?
}
