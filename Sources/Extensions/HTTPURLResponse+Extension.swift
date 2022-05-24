//
//  HTTPURLResponse+Extension.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 02.09.2021.
//

import Foundation

extension HTTPURLResponse {
  var contains2XXStatusCode: Bool { statusCode / 100 == 2 }
}
