//
//  ViewController.swift
//  SeatGeek
//
//  Created by Sagar Tilekar on 09/11/21.
//

import UIKit

class ViewController: UIViewController {

    var viewModel: EventViewModel!
    var imageLoader: ImageLoader!

    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        return searchBar
    }()

    private var events: [EventCellViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchBar.placeholder = "Search Events"
        navigationItem.titleView = searchBar

        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.register(EventTableViewCell.nib, forCellReuseIdentifier: EventTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.estimatedRowHeight = UITableView.automaticDimension

        bindToVM()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.refreshControl?.beginRefreshing()
        viewModel.loadEvents()
    }

    @objc private func refresh(sender: UIRefreshControl) {
        tableView.refreshControl?.beginRefreshing()
        viewModel.loadEvents()
    }

    func bindToVM() {
        viewModel.events = { [weak self] events in
            DispatchQueue.main.async {
                self?.handleEventsResult(events)
            }
        }

        viewModel.loadError = { [weak self] error in
            DispatchQueue.main.async {
                self?.handleEventsResult([])
                self?.showError(error)
            }
        }
    }

    private func handleEventsResult(_ events: [EventCellViewModel]) {
        self.events = events
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.identifier, for: indexPath) as? EventTableViewCell else { return UITableViewCell() }
        cell.imageLoader = imageLoader
        cell.configure(with: events[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        showEventDetail(event: events[indexPath.row])
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? EventTableViewCell else { return }
        cell.loadImage()
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        viewModel.loadEvents()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.refreshControl?.beginRefreshing()
        viewModel.loadEvents(filter: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ViewController {
    func showEventDetail(event: EventCellViewModel) {
        let vc = EventDetailViewController()
        vc.viewModel = event
        vc.imageLoader = imageLoader
        show(vc, sender: self)
    }
}

extension UIViewController {
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error Occurred", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

class EventDetailViewController: UIViewController {
    var viewModel: EventCellViewModel!
    var imageLoader: ImageLoader!

    private var timestamp: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var location: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var eventImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 10.0
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let title = UILabel()
        title.sizeToFit()
        title.numberOfLines = 0
        title.text = viewModel.name

        navigationItem.titleView = title

        view.addSubview(eventImage)
        view.addSubview(timestamp)
        view.addSubview(location)

        eventImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25).isActive = true
        eventImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        eventImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
        eventImage.heightAnchor.constraint(equalToConstant: 250).isActive = true
        timestamp.topAnchor.constraint(equalTo: eventImage.bottomAnchor, constant: 20).isActive = true
        timestamp.leadingAnchor.constraint(equalTo: eventImage.leadingAnchor).isActive = true
        timestamp.trailingAnchor.constraint(equalTo: eventImage.trailingAnchor).isActive = true
        location.topAnchor.constraint(equalTo: timestamp.bottomAnchor, constant: 20).isActive = true
        location.leadingAnchor.constraint(equalTo: eventImage.leadingAnchor).isActive = true
        location.trailingAnchor.constraint(equalTo: eventImage.trailingAnchor).isActive = true

        timestamp.text = viewModel.timestamp
        location.text = viewModel.address
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }

    private func updateView() {
        if let imageUrlString = viewModel.imageUrlString,
            let imageUrl = NSURL(string: imageUrlString) {
            eventImage.image = imageLoader.placeholderImage
            imageLoader.load(url: imageUrl, item: Item(image: eventImage.image ?? UIImage(), url: imageUrl as URL)) { [weak self] item, image in
                if let img = image, img != item.image {
                    self?.eventImage.image = img
                }
            }
        } else {
            eventImage.image = imageLoader.placeholderImage
        }
    }
}
