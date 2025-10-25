//
//  SolutionCounter.swift
//  Sudokov
//
//  Created by Codex on 2025-09-04.
//

import Foundation

/// Fast solution counter using bitset candidates and MRV heuristic.
/// Counts solutions up to a given limit (default 2) for a 9x9 Sudoku grid.
struct SolutionCounter {
    private static let allMask: Int = 0x1FF // 9 bits set (digits 1..9)

    /// Counts number of solutions for the given grid up to `limit`.
    /// Grid should contain 0 for empty cells, 1-9 for filled.
    static func countSolutions(grid: TableMatrix, limit: Int = 2) -> Int {
        var rows = Array(repeating: 0, count: 9)
        var cols = Array(repeating: 0, count: 9)
        var boxes = Array(repeating: 0, count: 9)

        // Validate and initialize masks
        for r in 0..<9 {
            for c in 0..<9 {
                let v = grid[r][c]
                if v == 0 { continue }
                let bit = 1 << (v - 1)
                let b = (r / 3) * 3 + (c / 3)
                // If conflict, return 0 solutions
                if (rows[r] & bit) != 0 || (cols[c] & bit) != 0 || (boxes[b] & bit) != 0 {
                    return 0
                }
                rows[r] |= bit
                cols[c] |= bit
                boxes[b] |= bit
            }
        }

        var solutions = 0

        func dfs(_ grid: inout [[Int]]) {
            if solutions >= limit { return }

            // Find cell with minimum remaining values (MRV)
            var bestR = -1, bestC = -1
            var bestMask = 0
            var bestCount = 10

            for r in 0..<9 {
                for c in 0..<9 {
                    if grid[r][c] != 0 { continue }
                    let b = (r / 3) * 3 + (c / 3)
                    let used = rows[r] | cols[c] | boxes[b]
                    let mask = Self.allMask & ~used
                    if mask == 0 { return } // dead end
                    let cnt = mask.nonzeroBitCount
                    if cnt < bestCount {
                        bestCount = cnt
                        bestMask = mask
                        bestR = r
                        bestC = c
                        if cnt == 1 { break }
                    }
                }
                if bestCount == 1 { break }
            }

            if bestR == -1 {
                // No empties: one solution found
                solutions += 1
                return
            }

            let r = bestR, c = bestC
            let b = (r / 3) * 3 + (c / 3)
            var mask = bestMask

            while mask != 0 && solutions < limit {
                // take lowest set bit
                let bit = mask & -mask
                let v = bit.trailingZeroBitCount + 1 // convert bit -> value 1..9

                // place
                grid[r][c] = v
                rows[r] |= bit
                cols[c] |= bit
                boxes[b] |= bit

                dfs(&grid)

                // undo
                boxes[b] &= ~bit
                cols[c] &= ~bit
                rows[r] &= ~bit
                grid[r][c] = 0

                // clear lowest set bit
                mask &= mask - 1
            }
        }

        var mutable = grid
        dfs(&mutable)
        return solutions
    }
}
