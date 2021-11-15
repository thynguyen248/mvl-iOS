//
//  Reusable.swift
//  MVL
//
//  Created by Thy Nguyen on 11/11/21.
//

import UIKit

protocol ReusableView: class {
    static var identifier: String { get }
    static var nib: UINib { get }
}

extension ReusableView where Self: UIView {
    static var identifier: String {
        return String(describing: self)
    }
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}
