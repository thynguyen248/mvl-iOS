//
//  HomeViewModel.swift
//  MVL
//
//  Created by Thy Nguyen on 11/11/21.
//

import RxSwift
import RxCocoa
import RxDataSources
import CoreLocation

enum ViewType {
    case setup(sections: [PointSectionViewModel])
    case info(sections: [PointSectionViewModel])
    case map(point: PointHolder, searchedPointSections: [SearchedLocationSectionModel])
}

final class PointHolder {
    var pointId: String
    var pointName: String
    var latitude: Double?
    var longitude: Double?
    var address: String?
    var aqi: Int?
    var timestamp: Double?
    
    init(pointName: String, pointId: String = UUID().uuidString) {
        self.pointId = pointId
        self.pointName = pointName
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let latitude = latitude, let longitude = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func reset() {
        latitude = nil
        longitude = nil
        address = nil
        aqi = nil
    }
}

final class HomeViewModel: ViewModelType {
    private let pointNames = ["point A", "point B"]
    private var points: [PointHolder]
    private var searchedPoints: [PointHolder] = []
    private var editingPoint: PointHolder?
    private let viewType = BehaviorRelay<ViewType>(value: .setup(sections: []))
    private let disposeBag = DisposeBag()
    
    private let useCase: UseCase
    
    init(useCase: UseCase = MainUseCase()) {
        self.useCase = useCase
        points = pointNames.map { PointHolder(pointName: $0) }
        loadSearchedPoints()
        generateViewType().bind(to: viewType).disposed(by: disposeBag)
    }
    
    // MARK: - Public methods
    func transform(input: Input) -> Output {
        // Show map on setting point
        input.setPoint
            .flatMap({ [weak self] pointId -> Observable<ViewType> in
                guard let point = self?.points.first(where: { $0.pointId == pointId }) else { return .empty() }
                self?.editingPoint = point
                return self?.generateViewType(point: point) ?? .empty()
            })
            .bind(to: viewType)
            .disposed(by: disposeBag)
        
        // Show searched point on map
        input.setSearchedPoint
            .flatMap { [weak self] coordinate -> Observable<ViewType> in
                guard let editingPoint = self?.editingPoint else { return .empty() }
                editingPoint.latitude = coordinate.latitude
                editingPoint.longitude = coordinate.longitude
                return self?.generateViewType(point: editingPoint) ?? .empty()
            }
            .bind(to: viewType)
            .disposed(by: disposeBag)
        
        // Show list after selecting point on map
        input.editPoint
            .do(onNext: { [weak self] coordinate in
                guard let edittingPoint = self?.editingPoint else { return }
                edittingPoint.latitude = coordinate.latitude
                edittingPoint.longitude = coordinate.longitude
                self?.loadInfo(point: edittingPoint)
                self?.savePoint(edittingPoint)
            })
            .flatMap({ [weak self] point -> Observable<ViewType> in
                return self?.generateViewType() ?? .empty()
            })
            .bind(to: viewType)
            .disposed(by: disposeBag)
        
        // Clear all points
        input.clearPoints
            .flatMap({ [weak self] point -> Observable<ViewType> in
                self?.points.forEach { $0.reset() }
                return self?.generateViewType() ?? .empty()
            })
            .bind(to: viewType)
            .disposed(by: disposeBag)
        
        // Back to original screen after viewing info
        input.backToRoot
            .flatMap({ [weak self] point -> Observable<ViewType> in
                return self?.generateViewType(isRoot: true) ?? .empty()
            })
            .bind(to: viewType)
            .disposed(by: disposeBag)
        
        return Output(viewType: viewType.asDriver())
    }
    
    // MARK: - Private methods
    private func loadSearchedPoints() {
        useCase.getSearchedPoints().subscribe(onSuccess: { [weak self] points in
            self?.searchedPoints = points
        }).disposed(by: disposeBag)
    }
    
    private func loadInfo(point: PointHolder) {
        useCase.getAddress(request: GetAddressRequestModel(latitude: point.latitude, longitude: point.longitude))
            .asObservable()
            .flatMap { [weak self] addresses -> Observable<ViewType> in
                guard let self = self, let addresses = addresses else { return .empty() }
                let address = addresses
                    .sorted(by: { ($0.order ?? 0) < ($1.order ?? 0) })
                    .suffix(2)
                    .compactMap { $0.name }
                    .joined(separator: ", ")
                point.address = address
                return self.generateViewType()
            }
            .bind(to: viewType)
            .disposed(by: disposeBag)
        
        useCase.getFeed(request: GetFeedRequestModel(latitude: point.coordinate?.latitude ?? 0.0, longitude: point.coordinate?.longitude ?? 0.0))
            .asObservable()
            .flatMap { [weak self] feed -> Observable<ViewType> in
                guard let self = self else { return .empty() }
                point.aqi = feed?.aqi
                return self.generateViewType()
            }
            .bind(to: viewType)
            .disposed(by: disposeBag)
    }
    
    private func savePoint(_ point: PointHolder) {
        let newSearchedPoint = PointHolder(pointName: point.pointName, pointId: point.pointId)
        newSearchedPoint.latitude = point.latitude
        newSearchedPoint.longitude = point.longitude
        newSearchedPoint.timestamp = Date().timeIntervalSince1970
        // Display searched point to list
        searchedPoints.insert(newSearchedPoint, at: 0)
        // Save to cache
        useCase.savePoint(point: newSearchedPoint).subscribe(onSuccess: { () in
            print("save point successfully")
        }).disposed(by: disposeBag)
    }
    
    private func getSearchedPoints() {
        useCase.getSearchedPoints().subscribe(onSuccess: { [weak self] points in
            self?.searchedPoints = points
        }).disposed(by: disposeBag)
    }
    
    private func generateViewType(isRoot: Bool = false, point: PointHolder? = nil) -> Observable<ViewType> {
        return Observable.create({ [weak self] observer -> Disposable in
            guard let self = self else { return Disposables.create() }
            if let point = point {
                let items = self.searchedPoints.map { SearchedLocationCellItem(latitude: $0.latitude, longitude: $0.longitude, timestamp: $0.timestamp) }
                let section = SearchedLocationSectionModel(model: "", items: items)
                observer.onNext(.map(point: point, searchedPointSections: [section]))
            } else if self.points.contains(where: { $0.coordinate == nil }) || isRoot {
                let cellVMs = self.points.map {
                    PointSetupCellItem(pointId: $0.pointId,
                                       pointName: $0.pointName,
                                       latitude: $0.coordinate?.latitude,
                                       longitude: $0.coordinate?.longitude)
                }
                let rows = cellVMs.map { PointRowViewModel.pointSetup(cellViewModel: $0) }
                observer.onNext(.setup(sections: [PointSectionViewModel.pointSection(items: rows)]))
            } else {
                let cellVMs = self.points.map {
                    PointInfoCellItem(pointName: $0.pointName,
                                      latitude: $0.coordinate?.latitude,
                                      longitude: $0.coordinate?.longitude,
                                      address: $0.address,
                                      aqi: $0.aqi) }
                let rows = cellVMs.map { PointRowViewModel.pointInfo(cellViewModel: $0) }
                observer.onNext(.info(sections: [PointSectionViewModel.pointSection(items: rows)]))
            }
            return Disposables.create()
        })
    }
}

extension HomeViewModel {
    struct Input {
        let setPoint: Observable<String>
        let setSearchedPoint: Observable<CLLocationCoordinate2D>
        let editPoint: Observable<CLLocationCoordinate2D>
        let clearPoints: Observable<Void>
        let backToRoot: Observable<Void>
    }
    
    struct Output {
        let viewType: Driver<ViewType>
    }
}

// MARK: - Point Row & section VM
enum PointRowViewModel {
    case pointSetup(cellViewModel: PointSetupCellItem)
    case pointInfo(cellViewModel: PointInfoCellItem)
}

enum PointSectionViewModel: SectionModelType {
    typealias Item = PointRowViewModel
    
    case pointSection(items: [Item])
    
    init(original: PointSectionViewModel, items: [Item]) {
        switch original {
        case .pointSection:
            self = .pointSection(items: items)
        }
    }
    
    var items: [Item] {
        switch self {
        case .pointSection(let items):
            return items
        }
    }
}

// MARK: - Searched location Row & section VM
typealias SearchedLocationSectionModel = AnimatableSectionModel<String, SearchedLocationCellItem>
