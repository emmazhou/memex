//
//  Memex.swift
//  Memex
//
//  Created by Emma Zhou on 10/11/20.
//

import Foundation

typealias MemexMessage = (
    time: Date,
    text: String,
    comment: String?
)

class Memex: NSObject, ObservableObject {
    static let shared = Memex()
    
    @Published var messages: [MemexMessage] = []

    var fileHandle: FileHandle?
    var dateFormatter: DateFormatter?

    override init() {
        super.init()

        dateFormatter = DateFormatter()
        dateFormatter!.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter!.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!

        let documentsUrl = NSURL(fileURLWithPath: documentsPath)
        if let pathComponent = documentsUrl.appendingPathComponent("memex.txt") {

            // create file if it doesn't exist
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: filePath) {
                FileManager.default.createFile(
                    atPath: filePath,
                    contents: nil,
                    attributes: nil)
            }
            fileHandle = FileHandle(forWritingAtPath: filePath)
            fileHandle?.seekToEndOfFile()
            
            // initialize messages with contents of file
            do {
                let fileContents = try String(contentsOf: pathComponent, encoding: .utf8)
                for line in fileContents.split(separator: "\n") {
                    let trimmed = strip(String(line))
                    if trimmed != "" {
                        let (text, comment) = extractComment(trimmed)
                        let (message, date) = extractDate(text)
                        messages.append(MemexMessage(
                            time: date,
                            text: message,
                            comment: comment
                        ))
                    }
                }
            } catch {
                print("Error reading from file")
            }
        }
    }
    
    func addMessage(message: String) {
        let (text, comment) = extractComment(message)
        if text == "" {
            return
        }

        let date = Date()

        messages.append(
            MemexMessage(
                time: date,
                text: text,
                comment: comment
            )
        )
        
        var line = "\(text) on \(dateFormatter!.string(from: date))"
        if (comment != nil) {
            line.append(" # \(comment!)")
        }
        line.append("\n")
        
        fileHandle?.write(line.data(using: .utf8)!)
    }
    
    func extractComment(_ message: String) -> (String, String?) {
        var text = message
        var comment: String? = nil
        
        var components = text.components(separatedBy: "#")
        if components.count > 1 {
            comment = strip(components.removeLast())
            text = components.joined(separator: "#")
        }
        text = strip(text)
        
        return (text, comment)
    }
    
    func extractDate(_ text: String) -> (String, Date) {
        var components = text.components(separatedBy: " on ")
        let dateString = components.removeLast()
        let date = dateFormatter!.date(from: dateString)!
        
        return (components.joined(separator: " on "), date)
    }
    
    func strip(_ text: String) -> String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func dateFromDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func timeFromDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

}
