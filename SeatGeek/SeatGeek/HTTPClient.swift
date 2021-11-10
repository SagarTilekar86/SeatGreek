//
//  ViewController.swift
//  SeatGeek
//
//  Created by Sagar Tilekar on 09/11/21.
//

import Foundation

class HTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func performRequest<T: Decodable>(url: URL, expectedData: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                      completion(.failure(URLError(.badServerResponse)))
                      return
                  }
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                print(error)
                completion(.failure(URLError(.cannotDecodeRawData)))
            }
        }.resume()
    }
}
