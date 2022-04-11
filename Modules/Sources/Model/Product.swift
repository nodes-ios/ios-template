//
//  File.swift
//
//
//  Created by Jakob Mygind on 19/11/2021.
//

import Foundation
import Tagged

public enum UnitCodeTag {}
public typealias UnitCode = Tagged<UnitCodeTag, String>

public struct Product: Equatable, Identifiable, Decodable {

    public enum ServingTemperature: String, Equatable, Decodable {
        case warm, cold
    }
    public typealias ID = Tagged<Self, Int>

    public var id: Product.ID
    public var name: String
    public var `description`: String
    public var price: Double
    public var netContentValue: String
    public var netContentMeasurementUnitCode: UnitCode
    public var thumbnailImageUrls: [URL]
    public var standardImageUrls: [URL]
    public var servingTemperature: ServingTemperature?
}

public struct LineItem: Equatable, Decodable, Identifiable {

    public var id: Product.ID {
        product.id
    }

    public var product: Product
    public var quantity: Int
}
