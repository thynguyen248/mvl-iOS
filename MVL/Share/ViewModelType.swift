//
//  ViewModelType.swift
//  MVL
//
//  Created by Thy Nguyen on 11/11/21.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
