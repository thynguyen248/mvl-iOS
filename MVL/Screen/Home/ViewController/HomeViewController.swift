//
//  HomeViewController.swift
//  MVL
//
//  Created by Thy Nguyen on 11/10/21.
//

import RxSwift
import RxCocoa
import RxDataSources
import GoogleMaps

final class HomeViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var infoContainerView: UIView!
    @IBOutlet private weak var mapContainerView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchedLocationTableView: UITableView!
    @IBOutlet private weak var mapView: GMSMapView!
    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var setButton: UIButton!
    @IBOutlet private weak var searchedLocationTableViewHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    private var viewModel: HomeViewModel! = HomeViewModel()
    private var sections = BehaviorRelay<[PointSectionViewModel]>(value: [])
    private var searchedLocationSections = BehaviorRelay<[SearchedLocationSectionModel]>(value: [])
    private let marker = GMSMarker()
    fileprivate let setPointSuject = PublishSubject<String>()
    fileprivate let editPointSuject = PublishSubject<CLLocationCoordinate2D>()
    fileprivate let clearPointsSubject = PublishSubject<Void>()
    fileprivate let backToRootSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bindViewModel()
    }
    
    private func setup() {
        setupTableView()
        setupMapView()
    }
    
    private func setupTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 130
        tableView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        tableView.register(cellType: PointSetupTableViewCell.self)
        tableView.register(cellType: PointInfoTableViewCell.self)
        searchedLocationTableView.rowHeight = 50.0
        searchedLocationTableView.register(cellType: SearchedLocationTableViewCell.self)
    }
    
    private func setupMapView() {
        locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        mapView.delegate = self
        marker.icon = GMSMarker.markerImage(with: UIColor.magenta)
        marker.map = mapView
    }
    
    private func bindViewModel() {
        let setSearchedPoint =  searchedLocationTableView.rx
            .modelSelected(SearchedLocationCellItem.self)
            .compactMap { searchedItem -> CLLocationCoordinate2D? in
                guard let lat = searchedItem.latitude, let long = searchedItem.longitude else { return nil }
                return CLLocationCoordinate2D(latitude: lat, longitude: long)
            }
        let input = HomeViewModel.Input(setPoint: setPointSuject.asObservable(),
                                        setSearchedPoint: setSearchedPoint,
                                        editPoint: editPointSuject.asObservable(),
                                        clearPoints: clearPointsSubject.asObservable(),
                                        backToRoot: backToRootSubject.asObservable())
        let output = viewModel.transform(input: input)
        
        output.viewType.drive(onNext: { [weak self] viewType in
            self?.updateUI(viewType: viewType)
        }).disposed(by: disposeBag)
        
        // TableView datasource
        let dataSource = RxTableViewSectionedReloadDataSource<PointSectionViewModel>(configureCell: { [weak self] _, tableView, indexPath, item in
            switch item {
            case .pointSetup(let cellItem):
                let cell = tableView.dequeueReusableCell(for: indexPath) as PointSetupTableViewCell
                cell.config(cellItem: cellItem)
                if let setPointSuject = self?.setPointSuject {
                    cell.rx.onSetup.bind(to: setPointSuject).disposed(by: cell.disposeBag)
                }
                return cell
            case .pointInfo(let cellItem):
                let cell = tableView.dequeueReusableCell(for: indexPath) as PointInfoTableViewCell
                cell.config(cellItem: cellItem)
                return cell
            }
        })
        sections.asDriver().drive(tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        // Searched location tableview datasource
        let searchedLocationDatasource = RxTableViewSectionedAnimatedDataSource<SearchedLocationSectionModel>(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(for: indexPath) as SearchedLocationTableViewCell
            cell.config(cellItem: item)
            return cell
        })
        searchedLocationSections.asDriver().drive(searchedLocationTableView.rx.items(dataSource: searchedLocationDatasource)).disposed(by: disposeBag)
        
        // Actions
        setButton.rx.tap
            .compactMap({ [weak self] () -> CLLocationCoordinate2D? in
                guard let lat = self?.marker.position.latitude, let long = self?.marker.position.longitude else { return nil }
                return CLLocationCoordinate2D(latitude: lat, longitude: long)
            })
            .bind(to: editPointSuject)
            .disposed(by: disposeBag)
        
        clearButton.rx.tap
            .withLatestFrom(output.viewType)
            .subscribe(onNext: { [weak self] viewType in
                guard let self = self else { return }
                switch viewType {
                case .setup:
                    self.clearPointsSubject.onNext(())
                case .info:
                    self.backToRootSubject.onNext(())
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUI(viewType: ViewType) {
        switch viewType {
        case .setup(let sections):
            mapContainerView.isHidden = true
            infoContainerView.isHidden = false
            self.sections.accept(sections)
            clearButton.setTitle("CLEAR", for: .normal)
        case .info(let sections):
            mapContainerView.isHidden = true
            infoContainerView.isHidden = false
            self.sections.accept(sections)
            clearButton.setTitle("BACK", for: .normal)
        case .map(let point, let seachedPointSections):
            mapContainerView.isHidden = false
            infoContainerView.isHidden = true
            updateMarker(coordinate: point.coordinate)
            searchedLocationSections.accept(seachedPointSections)
            searchedLocationTableViewHeight.constant = CGFloat(min(3, seachedPointSections.first?.items.count ?? 0)) * searchedLocationTableView.rowHeight
        }
    }
    
    private func updateMarker(coordinate: CLLocationCoordinate2D?) {
        guard let coordinate = (coordinate ?? locationManager.location?.coordinate) else { return }
        marker.position = coordinate
        let camera = GMSCameraPosition(
            target: coordinate,
            zoom: 15,
            bearing: 0,
            viewingAngle: 0)
        mapView.camera = camera
    }
}

// MARK: - CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        locationManager.requestLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        updateMarker(coordinate: location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// MARK: - GMSMapViewDelegate
extension HomeViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        marker.position = CLLocationCoordinate2D(latitude: position.target.latitude, longitude: position.target.longitude)
    }
}
