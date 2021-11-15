//
//  Date+format.swift
//  MVL
//
//  Created by Thy Nguyen on 11/13/21.
//

import Foundation

extension Date {
    func commonDateTimeString() -> String {
        let formater = DateFormatter()
        formater.dateFormat = "dd/MM/yyyy, HH:mm:ss"
        return formater.string(from: self)
    }
}
