//
//  UseCase.swift
//  MVL
//
//  Created by Thy Nguyen on 11/11/21.
//

import RxSwift

protocol UseCase: class {
    func getAddress(request: GetAddressRequestModel) -> Single<[AddressModel]?>
    func getFeed(request: GetFeedRequestModel) -> Single<GelocalizedFeedModel?>
    func savePoint(point: PointHolder) -> Single<Void>
    func getSearchedPoints() -> Single<[PointHolder]>
    
}

final class MainUseCase: UseCase {
    private let service: Service
    private let dbService: DatabaseService
    
    init(service: Service = MainService(), dbService: DatabaseService = MainDatabaseService()) {
        self.service = service
        self.dbService = dbService
    }
    
    func getAddress(request: GetAddressRequestModel) -> Single<[AddressModel]?> {
        return service.getAddress(request: request)
    }
    
    func getFeed(request: GetFeedRequestModel) -> Single<GelocalizedFeedModel?> {
        return service.getFeed(request: request)
    }
    
    func savePoint(point: PointHolder) -> Single<Void> {
        return dbService.savePoint(point: point)
    }
    
    func getSearchedPoints() -> Single<[PointHolder]> {
        return dbService.getSearchedPoints()
    }
}
