//
//  Request.swift
//  MVL
//
//  Created by Thy Nguyen on 11/11/21.
//

import Moya

enum Request {
    case getAddress(request: GetAddressRequestModel)
    case getFeed(request: GetFeedRequestModel)
}

extension Request: TargetType {
    var baseURL: URL {
        switch self {
        case .getAddress:
            return URL(string: "https://api.bigdatacloud.net")!
        case .getFeed:
            return URL(string: "https://api.waqi.info")!
        }
    }
    
    var path: String {
        switch self {
        case .getAddress:
            return "/data/reverse-geocode-client"
        case .getFeed(let request):
            return "/feed/\(request.geo)/"
        }
    }
    
    var method: Method {
        switch self {
        case .getAddress, .getFeed:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getAddress(let request):
            return .requestParameters(parameters: request.dictionary ?? [:], encoding: URLEncoding.default)
        case .getFeed(let request):
            return .requestParameters(parameters: request.dictionary ?? [:], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
