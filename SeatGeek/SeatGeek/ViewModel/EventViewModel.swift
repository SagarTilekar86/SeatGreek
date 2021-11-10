//
//  EventViewModel.swift
//  SeatGeek
//
//  Created by Sagar Tilekar on 30/10/21.
//

import Foundation
import UIKit

class Item: Hashable {
    var image: UIImage!
    let url: URL!
    let identifier = UUID()

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    init(image: UIImage, url: URL) {
        self.image = image
        self.url = url
    }
}

class ImageLoader {
    var placeholderImage = UIImage(systemName: "rectangle")!
    private let cachedImages = NSCache<NSURL, UIImage>()
    private var loadingResponses = [NSURL: [(Item, UIImage?) -> Swift.Void]]()
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func image(url: NSURL) -> UIImage? {
        return cachedImages.object(forKey: url)
    }

    final func load(url: NSURL, item: Item, completion: @escaping (Item, UIImage?) -> Swift.Void) {
        if let cachedImage = image(url: url) {
            DispatchQueue.main.async {
                completion(item, cachedImage)
            }
            return
        }

        if loadingResponses[url] != nil {
            loadingResponses[url]?.append(completion)
            return
        } else {
            loadingResponses[url] = [completion]
        }

        let task = session.dataTask(with: url as URL) { [weak self] (data, response, error) in
            guard let responseData = data,
                    let image = UIImage(data: responseData),
                  let completions = self?.loadingResponses[url],
                    error == nil else {
                DispatchQueue.main.async {
                    completion(item, nil)
                }
                return
            }

            self?.cachedImages.setObject(image, forKey: url, cost: responseData.count)

            for completion in completions {
                DispatchQueue.main.async {
                    completion(item, image)
                }
                return
            }
        }

        task.resume()
    }

}


struct EventCellViewModel {
    let name: String
    let address: String
    let timestamp: String
    let imageUrlString: String?

    init(event: EventElement) {
        self.imageUrlString = event.performers.first?.image
        self.name = event.title
        self.address = (event.venue.city ?? "") + ", " + (event.venue.state ?? "")
        self.timestamp = event.datetimeUTC.toDate.toString(format: "E, d MMM yyyy h:mm a")
    }
}

extension String {
    var toDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.date(from: self) ?? Date()
    }
}

extension Date {
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

class EventViewModel {
    private let client: HTTPClient
    var loadError: ((String) -> Void)?
    var events: (([EventCellViewModel]) -> Void)?

    init(client: HTTPClient) {
        self.client = client
    }

    func loadEvents(filter: String? = nil) {
        do {
            let url: URL
            if let filter = filter, !filter.isEmpty {
                url = try URLGenerator.getEvents(filter: filter)
            } else {
                url = try URLGenerator.getAllEvents()
            }
            client.performRequest(url: url, expectedData: Event.self) { result in
                switch result {
                case let .success(eventData):
                    self.events?(eventData.events.map { EventCellViewModel(event: $0) })
                case let .failure(error):
                    self.loadError?(error.localizedDescription)
                }
            }
        } catch {
            self.loadError?(error.localizedDescription)
        }
    }

}
