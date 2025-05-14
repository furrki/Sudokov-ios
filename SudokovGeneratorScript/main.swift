//
//  main.swift
//  SudokovGeneratorScript
//
//  Created by Furkan Kaynar on 14.09.24.
//

import Foundation

let easyDepth = 45
let mediumDepth = 35
let hardDepth = 25

func writeToFile(name: String, levels: [Level]) {
    // documents directory
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
    let data = try? JSONEncoder().encode(levels)
    let dataString = data?.base64EncodedString()
    
    do {
        try dataString!.write(to: fileURL, atomically: false, encoding: .utf8)
        print("File saved to \(fileURL)")
    } catch {
        print("Error writing to file")
    }
}

func generateLevels(depth: Int, name: String) {
    var levels: [Level] = []
    var tableBuilder = TableBuilder()
    
    print("Generating \(name) Levels")
    for _ in 0...99 {
        tableBuilder = TableBuilder(depth: depth)
        let cellsToHide = tableBuilder.cellsToHide
        levels.append(Level(table: tableBuilder.tableState, cellsToHide: cellsToHide))
        print("Generated \(levels.count) levels")
    }
    
    writeToFile(name: "\(name).data", levels: levels)
}

//generateLevels(depth: easyDepth, name: "easy")
// generateLevels(depth: mediumDepth, name: "medium")
 generateLevels(depth: hardDepth, name: "hard")
