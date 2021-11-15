//
//  CellDataSourceItem.swift
//  MVL
//
//  Created by Thy Nguyen on 11/11/21.
//

import RxSwift

protocol CellDataSourceItem {
    var type: String { get }
}

extension CellDataSourceItem {
    var type: String { return "" }
}
