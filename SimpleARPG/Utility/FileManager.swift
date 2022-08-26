//
//  FileManager.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/25/22.
//

import Foundation

extension RPGFileManager {
    static func clear(_ directory: Directory) throws {
        do {
            let url = try createURL(for: nil, in: directory)
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for fileUrl in contents {
                try? FileManager.default.removeItem(at: fileUrl)
            }
        } catch {
            throw error
        }
    }

    static func remove(_ path: String, from directory: Directory) throws {
        do {
            let url = try getExistingFileURL(for: path, in: directory)
            try FileManager.default.removeItem(at: url)
        } catch {
            throw error
        }
    }

    static func exists(_ path: String, in directory: Directory) -> Bool {
        if let _ = try? getExistingFileURL(for: path, in: directory) {
            return true
        }
        return false
    }

    static func save<T: Encodable>(_ value: T, to directory: Directory, as path: String, encoder: JSONEncoder = JSONEncoder()) throws {
        if path.hasSuffix("/") {
            throw createInvalidFileNameForStructsError()
        }
        do {
            let url = try createURL(for: path, in: directory)
            let data = try encoder.encode(value)
            try createSubfoldersBeforeCreatingFile(at: url)
            try data.write(to: url, options: .atomic)
        } catch {
            throw error
        }
    }

    static func append<T: Codable>(_ value: T, to path: String, in directory: Directory, decoder: JSONDecoder = JSONDecoder(), encoder: JSONEncoder = JSONEncoder()) throws {
        if path.hasSuffix("/") {
            throw createInvalidFileNameForStructsError()
        }
        do {
            if let url = try? getExistingFileURL(for: path, in: directory) {
                let oldData = try Data(contentsOf: url)
                if !(oldData.count > 0) {
                    try save([value], to: directory, as: path, encoder: encoder)
                } else {
                    let new: [T]
                    if let old = try? decoder.decode(T.self, from: oldData) {
                        new = [old, value]
                    } else if var old = try? decoder.decode([T].self, from: oldData) {
                        old.append(value)
                        new = old
                    } else {
                        throw createDeserializationErrorForAppendingStructToInvalidType(url: url, type: value)
                    }
                    let newData = try encoder.encode(new)
                    try newData.write(to: url, options: .atomic)
                }
            } else {
                try save([value], to: directory, as: path, encoder: encoder)
            }
        } catch {
            throw error
        }
    }

    static func retrieve<T: Decodable>(_ path: String, from directory: Directory, as type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        if path.hasSuffix("/") {
            throw createInvalidFileNameForStructsError()
        }
        do {
            let url = try getExistingFileURL(for: path, in: directory)
            let data = try Data(contentsOf: url)
            let value = try decoder.decode(type, from: data)
            return value
        } catch {
            throw error
        }
    }

    static func getExistingFileURL(for path: String?, in directory: Directory) throws -> URL {
        do {
            let url = try createURL(for: path, in: directory)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
            throw createError(
                .noFileFound,
                description: "Could not find an existing file or folder at \(url.path).",
                failureReason: "There is no existing file or folder at \(url.path)",
                recoverySuggestion: "Check if a file or folder exists before trying to commit an operation on it."
            )
        } catch {
            throw error
        }
    }

    static func createSubfoldersBeforeCreatingFile(at url: URL) throws {
        do {
            let subfolderUrl = url.deletingLastPathComponent()
            var subfolderExists = false
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: subfolderUrl.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    subfolderExists = true
                }
            }
            if !subfolderExists {
                try FileManager.default.createDirectory(at: subfolderUrl, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            throw error
        }
    }

    fileprivate static func createInvalidFileNameForStructsError() -> Error {
        RPGFileManager.createError(
            .invalidFileName,
            description: "Cannot save/retrieve the Codable struct without a valid file name. Unlike how arrays of UIImages or Data are stored, Codable structs are not saved as multiple files in a folder, but rather as one JSON file. If you already successfully saved Codable struct(s) to your folder name, try retrieving it as a file named 'Folder' instead of as a folder 'Folder/'",
            failureReason: "Disk does not save structs or arrays of structs as multiple files to a folder like it does UIImages or Data.",
            recoverySuggestion: "Save your struct or array of structs as one file that encapsulates all the data (i.e. \"multiple-messages.json\")")
    }

    fileprivate static func createDeserializationErrorForAppendingStructToInvalidType<T>(url: URL, type: T) -> Error {
        RPGFileManager.createError(
            .deserialization,
            description: "Could not deserialize the existing data at \(url.path) to a valid type to append to.",
            failureReason: "JSONDecoder could not decode type \(T.self) from the data existing at the file location.",
            recoverySuggestion: "Ensure that you only append data structure(s) with the same type as the data existing at the file location.")
    }
}

class RPGFileManager {
    fileprivate init() { }

    internal enum Directory: Equatable {
        case documents

        public var pathDescription: String {
            switch self {
            case .documents: return "<Application_Home>/Documents"
            }
        }
    }

    private enum ErrorCode: Int {
        case noFileFound = 0
        case serialization = 1
        case deserialization = 2
        case invalidFileName = 3
        case couldNotAccessTemporaryDirectory = 4
        case couldNotAccessUserDomainMask = 5
        case couldNotAccessSharedContainer = 6
    }

    private static func createURL(for path: String?, in directory: Directory) throws -> URL {
        let filePrefix = "file://"
        var validPath: String? = nil
        if let path = path {
            do {
                validPath = try getValidFilePath(from: path)
            } catch {
                throw error
            }
        }
        var searchPathDirectory: FileManager.SearchPathDirectory
        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        }
        if var url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            if let validPath = validPath {
                url = url.appendingPathComponent(validPath, isDirectory: false)
            }
            if url.absoluteString.lowercased().prefix(filePrefix.count) != filePrefix {
                let fixedUrlString = filePrefix + url.absoluteString
                url = URL(string: fixedUrlString)!
            }
            return url
        } else {
            throw createError(
                .couldNotAccessUserDomainMask,
                description: "Could not create URL for \(directory.pathDescription)/\(validPath ?? "")",
                failureReason: "Could not get access to the file system's user domain mask.",
                recoverySuggestion: "Use a different directory."
            )
        }
    }

    private static func getValidFilePath(from originalString: String) throws -> String {
        var invalidCharacters = CharacterSet(charactersIn: ":")
        invalidCharacters.formUnion(.newlines)
        invalidCharacters.formUnion(.illegalCharacters)
        invalidCharacters.formUnion(.controlCharacters)
        let pathWithoutIllegalCharacters = originalString
            .components(separatedBy: invalidCharacters)
            .joined(separator: "")
        let validFileName = removeSlashesAtBeginning(of: pathWithoutIllegalCharacters)
        guard validFileName.count > 0  && validFileName != "." else {
            throw createError(
                .invalidFileName,
                description: "\(originalString) is an invalid file name.",
                failureReason: "Cannot write/read a file with the name \(originalString) on disk.",
                recoverySuggestion: "Use another file name with alphanumeric characters."
            )
        }
        return validFileName
    }

    private static func removeSlashesAtBeginning(of string: String) -> String {
        var string = string
        if string.prefix(1) == "/" {
            string.remove(at: string.startIndex)
        }
        if string.prefix(1) == "/" {
            string = removeSlashesAtBeginning(of: string)
        }
        return string
    }

    private static let errorDomain = "DiskErrorDomain"

    private static func createError(_ errorCode: ErrorCode, description: String?, failureReason: String?, recoverySuggestion: String?) -> Error {
        let errorInfo: [String: Any] = [NSLocalizedDescriptionKey : description ?? "",
                                        NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion ?? "",
                                        NSLocalizedFailureReasonErrorKey: failureReason ?? ""]
        return NSError(domain: errorDomain, code: errorCode.rawValue, userInfo: errorInfo) as Error
    }
}
