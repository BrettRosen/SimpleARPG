//
//  Codable+Extensions.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/26/22.
//

import BetterCodable
import Foundation


/// This wrapper is similar to `DefaultCodable` in that it will decode the property to a default value
/// defined by the strategy but will also ignore encoding this property
@propertyWrapper
public struct CodableIgnored<Default: DefaultCodableStrategy>: Codable where Default.DefaultValue: Decodable {
    public var wrappedValue: Default.DefaultValue

    public init(wrappedValue: Default.DefaultValue) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        self.wrappedValue = Default.defaultValue
    }

    public func encode(to encoder: Encoder) throws {
        // Do nothing
    }
}

extension CodableIgnored: Equatable where Default.DefaultValue: Equatable { }

extension KeyedDecodingContainer {
    func decode<P>(_: CodableIgnored<P>.Type, forKey key: Key) throws -> CodableIgnored<P> {
        CodableIgnored(wrappedValue: P.defaultValue)
    }
}

extension KeyedEncodingContainer {
    public mutating func encode<T>(
        _ value: CodableIgnored<T>,
        forKey key: KeyedEncodingContainer<K>.Key) throws
    {
        // Do nothing
    }
}
