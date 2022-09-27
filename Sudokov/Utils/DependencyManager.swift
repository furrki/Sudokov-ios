//
//  DependencyManager.swift
//  Sudokov
//
//  Created by furrki on 24.07.2022.
//

import Foundation

enum DependencyManager {
    private static let path = URL(fileURLWithPath: NSTemporaryDirectory())
    private static let disk = DiskStorage(path: path)

    static let storage = CodableStorage(storage: disk)
    static let localLevelManager = LocalLevelManager()
    static let storageManager = StorageManager(storage: storage)
    static let analyticsManager = AnalyticsManager()
    static let tableBuilder = TableBuilder()
}
