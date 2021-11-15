//
//  Optional+nilOrEmpty.swift
//  MVL
//
//  Created by Thy Nguyen on 11/12/21.
//

import UIKit

extension Optional where Wrapped: Collection {
    var isEmptyOrNil: Bool {
        return self?.isEmpty ?? true
    }
}
