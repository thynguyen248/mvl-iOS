//
//  PointSetupTableViewCell.swift
//  MVL
//
//  Created by Thy Nguyen on 11/11/21.
//

import RxSwift
import RxCocoa

struct PointSetupCellItem: CellDataSourceItem {
    let pointId: String
    let pointName: String
    let latitude: Double?
    let longitude: Double?
    
    var info: String? {
        guard let latitude = latitude, let longitude = longitude else { return nil }
        return String(format: "%@: %.2f, %.2f", pointName, latitude, longitude)
    }
    
    var buttonTitle: String {
        return "Set \(pointName)"
    }
}

final class PointSetupTableViewCell: UITableViewCell, ReusableView {
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var setButton: UIButton!
    
    fileprivate let onSetupSubject = PublishSubject<String>()
    private(set) var disposeBag: DisposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }
    
    private func setupView() {
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func config(cellItem: PointSetupCellItem) {
        infoLabel.isHidden = cellItem.info.isEmptyOrNil
        infoLabel.text = cellItem.info
        setButton.setTitle(cellItem.buttonTitle, for: .normal)
        
        setButton.rx.tap
            .map { cellItem.pointId }
            .bind(to: onSetupSubject)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: PointSetupTableViewCell {
    var onSetup: ControlEvent<String> {
        return ControlEvent(events: base.onSetupSubject.asObservable())
    }
}
