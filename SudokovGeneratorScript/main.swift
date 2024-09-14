//
//  main.swift
//  SudokovGeneratorScript
//
//  Created by Furkan Kaynar on 14.09.24.
//

import Foundation

let easyDepth = 45
let mediumDepth = 35
let hardDepth = 26

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

var levels: [Level] = []
var tableBuilder = TableBuilder()

print("Generating levels")
for _ in 0...99 {
    tableBuilder = TableBuilder(depth: easyDepth)
    let cellsToHide = tableBuilder.cellsToHide
    levels.append(Level(table: tableBuilder.tableState, cellsToHide: cellsToHide))
}

writeToFile(name: "easy.data", levels: levels)

levels = []
