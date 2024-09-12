//
//  HTTPRequestProgress.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 26.04.2022.
//

public struct HTTPRequestProgress: Sendable {
  public let ready: Int64
  public let total: Int64
}
