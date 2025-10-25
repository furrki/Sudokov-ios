#!/usr/bin/env swift

import Foundation

/// Dead Code Detection Script for Sudokov iOS Project
/// This script analyzes Swift files to find potentially unused code

struct DeadCodeDetector {
    let projectPath: String
    
    init(projectPath: String) {
        self.projectPath = projectPath
    }
    
    func analyze() {
        print("🔍 Analyzing project for dead code...")
        print("Project path: \(projectPath)")
        print("")
        
        let swiftFiles = findSwiftFiles()
        let allContent = swiftFiles.compactMap { readFile($0) }.joined(separator: "\n")
        
        print("📊 Analysis Results:")
        print("===================")
        
        analyzeUnusedClasses(in: swiftFiles, content: allContent)
        analyzeUnusedMethods(in: swiftFiles, content: allContent)
        analyzeCommentedCode(in: swiftFiles)
        analyzeUnusedImports(in: swiftFiles)
        
        print("\n✅ Analysis complete!")
    }
    
    private func findSwiftFiles() -> [String] {
        let fileManager = FileManager.default
        let projectURL = URL(fileURLWithPath: projectPath)
        
        guard let enumerator = fileManager.enumerator(at: projectURL, includingPropertiesForKeys: nil) else {
            print("❌ Could not access project directory")
            return []
        }
        
        var swiftFiles: [String] = []
        
        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension == "swift" && 
               !fileURL.path.contains("Pods/") && 
               !fileURL.path.contains(".build/") {
                swiftFiles.append(fileURL.path)
            }
        }
        
        print("Found \(swiftFiles.count) Swift files")
        return swiftFiles
    }
    
    private func readFile(_ path: String) -> String? {
        return try? String(contentsOfFile: path)
    }
    
    private func analyzeUnusedClasses(in files: [String], content: String) {
        print("\n🏗️  Potentially Unused Classes:")
        print("------------------------------")
        
        let classRegex = try! NSRegularExpression(pattern: "class\\s+(\\w+)", options: [])
        let structRegex = try! NSRegularExpression(pattern: "struct\\s+(\\w+)", options: [])
        
        var foundClasses: Set<String> = []
        
        for file in files {
            guard let fileContent = readFile(file) else { continue }
            
            // Find class declarations
            let classMatches = classRegex.matches(in: fileContent, options: [], range: NSRange(location: 0, length: fileContent.count))
            for match in classMatches {
                if let range = Range(match.range(at: 1), in: fileContent) {
                    let className = String(fileContent[range])
                    foundClasses.insert(className)
                }
            }
            
            // Find struct declarations
            let structMatches = structRegex.matches(in: fileContent, options: [], range: NSRange(location: 0, length: fileContent.count))
            for match in structMatches {
                if let range = Range(match.range(at: 1), in: fileContent) {
                    let structName = String(fileContent[range])
                    foundClasses.insert(structName)
                }
            }
        }
        
        // Check usage
        for className in foundClasses.sorted() {
            let usageCount = countOccurrences(of: className, in: content)
            if usageCount <= 2 { // Class declaration + possible init
                print("⚠️  \(className) - used \(usageCount) times (possibly unused)")
            }
        }
    }
    
    private func analyzeUnusedMethods(in files: [String], content: String) {
        print("\n⚙️  Potentially Unused Methods:")
        print("------------------------------")
        
        let methodRegex = try! NSRegularExpression(pattern: "func\\s+(\\w+)\\s*\\(", options: [])
        
        var foundMethods: Set<String> = []
        
        for file in files {
            guard let fileContent = readFile(file) else { continue }
            
            let matches = methodRegex.matches(in: fileContent, options: [], range: NSRange(location: 0, length: fileContent.count))
            for match in matches {
                if let range = Range(match.range(at: 1), in: fileContent) {
                    let methodName = String(fileContent[range])
                    // Skip common lifecycle and override methods
                    if !["init", "viewDidLoad", "viewWillAppear", "viewDidAppear", "deinit"].contains(methodName) {
                        foundMethods.insert(methodName)
                    }
                }
            }
        }
        
        // Check usage (excluding the declaration)
        for methodName in foundMethods.sorted() {
            let usageCount = countOccurrences(of: methodName, in: content)
            if usageCount <= 1 { // Just the declaration
                print("⚠️  \(methodName)() - used \(usageCount) times (possibly unused)")
            }
        }
    }
    
    private func analyzeCommentedCode(in files: [String]) {
        print("\n💬 Files with Commented Code:")
        print("-----------------------------")
        
        let commentedCodeRegex = try! NSRegularExpression(pattern: "^\\s*//\\s*(func|class|struct|var|let).*$", options: [.anchorsMatchLines])
        
        for file in files {
            guard let fileContent = readFile(file) else { continue }
            
            let matches = commentedCodeRegex.matches(in: fileContent, options: [], range: NSRange(location: 0, length: fileContent.count))
            if !matches.isEmpty {
                let fileName = URL(fileURLWithPath: file).lastPathComponent
                print("⚠️  \(fileName) - \(matches.count) commented code lines")
            }
        }
    }
    
    private func analyzeUnusedImports(in files: [String]) {
        print("\n📦 Potentially Unused Imports:")
        print("------------------------------")
        
        let importRegex = try! NSRegularExpression(pattern: "import\\s+(\\w+)", options: [])
        
        for file in files {
            guard let fileContent = readFile(file) else { continue }
            
            let matches = importRegex.matches(in: fileContent, options: [], range: NSRange(location: 0, length: fileContent.count))
            for match in matches {
                if let range = Range(match.range(at: 1), in: fileContent) {
                    let importName = String(fileContent[range])
                    
                    // Skip Foundation and UIKit as they're commonly used implicitly
                    if !["Foundation", "UIKit", "SwiftUI"].contains(importName) {
                        let usageCount = countOccurrences(of: importName, in: fileContent)
                        if usageCount <= 1 { // Just the import statement
                            let fileName = URL(fileURLWithPath: file).lastPathComponent
                            print("⚠️  \(fileName): import \(importName) (possibly unused)")
                        }
                    }
                }
            }
        }
    }
    
    private func countOccurrences(of string: String, in text: String) -> Int {
        return text.components(separatedBy: string).count - 1
    }
}

// MARK: - Main Execution

let arguments = CommandLine.arguments

if arguments.count < 2 {
    print("Usage: swift dead_code_detector.swift <project_path>")
    print("Example: swift dead_code_detector.swift /path/to/Sudokov-ios")
    exit(1)
}

let projectPath = arguments[1]
let detector = DeadCodeDetector(projectPath: projectPath)
detector.analyze()
