//
//  ViewController.swift
//  SeatGeek
//
//  Created by Sagar Tilekar on 09/11/21.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var cellImage: UIImageView!

    private var imageUrl: NSURL?
    var imageLoader: ImageLoader!

    override func awakeFromNib() {
        super.awakeFromNib()
        cellImage.clipsToBounds = true
        cellImage.layer.cornerRadius = 8.0
    }

    func loadImage() {
        if let imageUrl = imageUrl {
            cellImage.image = imageLoader.placeholderImage
            imageLoader.load(url: imageUrl, item: Item(image: cellImage.image ?? UIImage(), url: imageUrl as URL)) { [weak self] item, image in
                if let img = image, img != item.image {
                    self?.cellImage.image = img
                }
            }
        } else {
            cellImage.image = imageLoader.placeholderImage
        }
    }

    static var identifier: String {
        String(describing: self)
    }

    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle(for: self))
    }

    func configure(with viewModel: EventCellViewModel) {
        if let url = viewModel.imageUrlString {
            imageUrl = NSURL(string: url)
        }
        name.text = viewModel.name
        address.text = viewModel.address
        timestamp.text = viewModel.timestamp
    }
}
