//
//  Service.swift
//  MVL
//
//  Created by Thy Nguyen on 11/11/21.
//

import RxSwift
import Moya

protocol Service: class {
    func getAddress(request: GetAddressRequestModel) -> Single<[AddressModel]?>
    func getFeed(request: GetFeedRequestModel) -> Single<GelocalizedFeedModel?>
}

final class MainService: Service {
    private let provider: MoyaProvider<Request>
    init(provider: MoyaProvider<Request> = MoyaProvider<Request>()) {
        self.provider = provider
    }
    
    func getAddress(request: GetAddressRequestModel) -> Single<[AddressModel]?> {
        return Single<[AddressModel]?>.create(subscribe: { [weak self] single -> Disposable in
            guard let self = self else { return Disposables.create() }
            return self.provider.rx.request(.getAddress(request: request))
                .subscribe(onSuccess: { response in
                    let decoder = JSONDecoder()
                    do {
                        let addressResponse: AddressResponseModel? = try decoder.decode(AddressResponseModel.self, from: response.data)
                        let addresses = addressResponse?.localityInfo?.administrative
                        single(.success(addresses))
                    } catch {
                        single(.failure(error))
                    }
                }, onFailure: { error in
                    single(.failure(error))
                })
        }).subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    func getFeed(request: GetFeedRequestModel) -> Single<GelocalizedFeedModel?> {
        return Single<GelocalizedFeedModel?>.create(subscribe: { [weak self] single -> Disposable in
            guard let self = self else { return Disposables.create() }
            return self.provider.rx.request(.getFeed(request: request))
                .subscribe(onSuccess: { response in
                    let decoder = JSONDecoder()
                    do {
                        let feedResponse: FeedResponseModel = try decoder.decode(FeedResponseModel.self, from: response.data)
                        single(.success(feedResponse.data))
                    } catch {
                        single(.failure(error))
                    }
                }, onFailure: { error in
                    single(.failure(error))
                })
        }).subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }
}
