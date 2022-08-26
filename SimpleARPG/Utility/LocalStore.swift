//
//  LocalStore.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/25/22.
//

import ComposableArchitecture
import Foundation

struct LocalStore {
    struct Error: Swift.Error, Equatable {
        var description: String = ""
    }

    static func saveItem<T: Codable>(
        _ item: T,
        path: String,
        callback: @escaping (Result<Success, LocalStore.Error>) -> ()
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try RPGFileManager.save(item, to: .documents, as: path)
                DispatchQueue.main.async {
                    callback(.success(Success()))
                }
            } catch {
                DispatchQueue.main.async {
                    callback(.failure(Error(description: error.localizedDescription)))
                }
            }
        }
    }

    static func updateItems<T: Codable>(
        _ items: [T],
        path: String,
        callback: @escaping (Result<Success, LocalStore.Error>) -> ()
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try RPGFileManager.remove(path, from: .documents)
                try RPGFileManager.save(items, to: .documents, as: path)
                DispatchQueue.main.async {
                    callback(.success(Success()))
                }
            } catch {
                DispatchQueue.main.async {
                    callback(.failure(Error(description: error.localizedDescription)))
                }
            }
        }
    }

    static func appendItem<T: Codable>(
        _ item: T,
        path: String,
        callback: @escaping (Result<Success, LocalStore.Error>) -> ()
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if RPGFileManager.exists(path, in: .documents) {
                    try RPGFileManager.append(item, to: path, in: .documents)
                } else {
                    try RPGFileManager.save([item], to: .documents, as: path)
                }
                DispatchQueue.main.async {
                    callback(.success(Success()))
                }
            } catch {
                DispatchQueue.main.async {
                    callback(.failure(Error(description: error.localizedDescription)))
                }
            }
        }
    }

    static func loadItem<T: Codable>(
        path: String,
        callback: @escaping (Result<T?, LocalStore.Error>) -> ()
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if !RPGFileManager.exists(path, in: .documents) {
                    DispatchQueue.main.async {
                        callback(.success(nil))
                    }
                } else {
                    let data: T = try RPGFileManager.retrieve(path, from: .documents, as: T.self)
                    DispatchQueue.main.async {
                        callback(.success(data))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    callback(.failure(Error(description: error.localizedDescription)))
                }
            }
        }
    }

    static func loadItems<T: Codable>(
        path: String,
        callback: @escaping (Result<[T], LocalStore.Error>) -> ()
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if !RPGFileManager.exists(path, in: .documents) {
                    DispatchQueue.main.async {
                        callback(.failure(Error(description: "")))
                    }
                } else {
                    let data: [T] = try RPGFileManager.retrieve(path, from: .documents, as: [T].self)
                    DispatchQueue.main.async {
                        callback(.success(data))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    callback(.failure(Error(description: error.localizedDescription)))
                }
            }
        }
    }
}

struct LocalStoreClient {
    var saveGameState: (GameState) -> Effect<Success, LocalStore.Error>
    var loadGameState: () -> Effect<GameState?, LocalStore.Error>

    static internal let gameStatePath = "game.json"
}

extension LocalStoreClient {
    static var live = LocalStoreClient(saveGameState: { item in
        Effect.future { callback in
            LocalStore.saveItem(item, path: LocalStoreClient.gameStatePath, callback: callback)
        }
    }, loadGameState: {
        Effect.future { callback in
            LocalStore.loadItem(path: LocalStoreClient.gameStatePath, callback: callback)
        }
    })
}
