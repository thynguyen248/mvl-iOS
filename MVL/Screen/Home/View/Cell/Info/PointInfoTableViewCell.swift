//
//  PointInfoTableViewCell.swift
//  MVL
//
//  Created by Thy Nguyen on 11/11/21.
//

import UIKit

struct PointInfoCellItem: CellDataSourceItem {
    let pointName: String
    let latitude: Double?
    let longitude: Double?
    let address: String?
    let aqi: Int?
    
    var coordinateDisplayText: String? {
        guard let latitude = latitude, let longitude = longitude else { return nil }
        return String(format: "Coordinate: %.2f; %.2f", latitude, longitude)
    }
    
    var addressDisplayText: String? {
        guard let address = address else { return nil }
        return "Address: \(address)"
    }
    
    var aqiDisplayText: String? {
        guard let aqi = aqi else { return nil }
        return "AQI: \(aqi)"
    }
}

final class PointInfoTableViewCell: UITableViewCell, ReusableView {
    @IBOutlet private weak var pointNameLabel: UILabel!
    @IBOutlet private weak var coordinateLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var airQualityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }
    
    private func setupView() {
        selectionStyle = .none
    }
    
    func config(cellItem: PointInfoCellItem) {
        coordinateLabel.isHidden = cellItem.coordinateDisplayText.isEmptyOrNil
        addressLabel.isHidden = cellItem.address.isEmptyOrNil
        airQualityLabel.isHidden = cellItem.aqiDisplayText.isEmptyOrNil
        pointNameLabel.text = cellItem.pointName
        coordinateLabel.text = cellItem.coordinateDisplayText
        addressLabel.text = cellItem.addressDisplayText
        airQualityLabel.text = cellItem.aqiDisplayText
    }
}
