//
//  ViewController.swift
//  SeatGeek
//
//  Created by Sagar Tilekar on 09/11/21.
//

import Foundation

struct URLGenerator {
    private static var baseUrlString = "https://api.seatgeek.com/2/events"
    private static var authParameters: [URLQueryItem] = [
        URLQueryItem(name: "client_id", value: "MjQxMzY1NTZ8MTYzNTM0MDY2OS42NDQzOTYz"),
        URLQueryItem(name: "client_secret", value: "e9845027175976326e2a44438a1cf0331bfe8925ed9ee32265e93386218337fe")
    ]

    static func getAllEvents() throws -> URL {
        guard var urlComponents = URLComponents(string: baseUrlString) else {
            throw URLError(.badURL)
        }
        urlComponents.queryItems = authParameters
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        return url
    }

    static func getEvents(filter query: String) throws -> URL {
        guard let urlQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              var urlComponents = URLComponents(string: baseUrlString) else {
            throw URLError(.badURL)
        }
        urlComponents.queryItems = authParameters
        urlComponents.queryItems?.append(URLQueryItem(name: "q", value: urlQuery))
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        return url
    }
}
