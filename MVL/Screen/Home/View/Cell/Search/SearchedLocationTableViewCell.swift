//
//  SearchedLocationTableViewCell.swift
//  MVL
//
//  Created by Thy Nguyen on 11/13/21.
//

import RxDataSources

struct SearchedLocationCellItem: CellDataSourceItem, IdentifiableType, Equatable {
    let latitude: Double?
    let longitude: Double?
    let timestamp: Double?
    
    var identity: String {
        return "\(latitude ?? 0.0)\(longitude ?? 0.0)\(timestamp ?? 0.0)"
    }
    
    var coordinateInfo: String? {
        guard let latitude = latitude, let longitude = longitude else { return nil }
        return String(format: "%.2f; %.2f", latitude, longitude)
    }
    
    var dateInfo: String? {
        guard let timestamp = timestamp else { return nil }
        let date = Date(timeIntervalSince1970: timestamp)
        return date.commonDateTimeString()
    }
}

final class SearchedLocationTableViewCell: UITableViewCell, ReusableView {
    @IBOutlet private weak var coordinateLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(cellItem: SearchedLocationCellItem) {
        coordinateLabel.isHidden = cellItem.coordinateInfo.isEmptyOrNil
        dateLabel.isHidden = cellItem.dateInfo.isEmptyOrNil
        coordinateLabel.text = cellItem.coordinateInfo
        dateLabel.text = cellItem.dateInfo
    }
}
