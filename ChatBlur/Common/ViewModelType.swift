//
//  ViewModelType.swift
//  ChatBlur
//
//  Created by HappyDuck on 12/29/23.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
