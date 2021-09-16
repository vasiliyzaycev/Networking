//
//  Tracker.swift
//  NetworkServiceDemo
//
//  Created by Vasiliy Zaytsev on 31.08.2021.
//

import Foundation

struct Tracker: TrackerProtocol {
    func track(_ event: String) {
        print(event)
    }
}
