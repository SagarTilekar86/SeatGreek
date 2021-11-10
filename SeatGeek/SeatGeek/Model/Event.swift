//
//  ViewController.swift
//  SeatGeek
//
//  Created by Sagar Tilekar on 09/11/21.
//

import Foundation
import Alamofire

// MARK: - Event
struct Event: Codable {
    let events: [EventElement]
}

// MARK: - EventElement
struct EventElement: Codable {
    let type: String
    let id: Int
    let datetimeUTC: String
    let venue: Venue
    let datetimeTbd: Bool
    let performers: [Performer]
    let shortTitle, visibleUntilUTC: String
    let title: String
    let eventDescription: String

    enum CodingKeys: String, CodingKey {
        case type, id
        case datetimeUTC = "datetime_utc"
        case venue
        case datetimeTbd = "datetime_tbd"
        case performers
        case shortTitle = "short_title"
        case visibleUntilUTC = "visible_until_utc"
        case title
        case eventDescription = "description"
    }
}

// MARK: - AccessMethod
struct AccessMethod: Codable {
    let method: String
    let createdAt: Date
    let employeeOnly: Bool

    enum CodingKeys: String, CodingKey {
        case method
        case createdAt = "created_at"
        case employeeOnly = "employee_only"
    }
}
// MARK: - Announcements
struct Announcements: Codable {
}

// MARK: - Performer
struct Performer: Codable {
    let type: String
    let name: String
    let image: String
    let id: Int

    enum CodingKeys: String, CodingKey {
        case type, name, image, id
    }
}

// MARK: - Location
struct Location: Codable {
    let lat, lon: Double
}

// MARK: - Venue
struct Venue: Codable {
    let state, name: String?
    let address: String?
    let country: String?
    let city: String?
}
