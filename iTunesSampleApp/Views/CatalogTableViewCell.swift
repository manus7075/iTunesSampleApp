//
//  CatalogTableViewCell.swift
//  LightweightiTunesCatalog
//
//  Created by Manoj Telkuntla on 2020/04/14.
//  Copyright © 2020 Lightweight iTunes Catalog. All rights reserved.
//

import UIKit

final class CatalogTableViewCell: UITableViewCell {
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var subtitleLabel: UILabel!
  @IBOutlet private var genreLabel: UILabel!

  @IBOutlet  var favouriteButton: UIButton!
   var favouriteValueUpdated:((_ isEnabled:Bool) ->())?
  @IBOutlet  var artworkImage: UIImageView!

  func configure(with media: CatalogDetails) {
    titleLabel.text = media.trackName
    genreLabel.text = media.primaryGenreName
    subtitleLabel.text = String(media.trackViewUrl)
  }
    @IBAction func favouriteButtonTapped(_ sender: Any) {
        favouriteButton.isSelected = !favouriteButton.isSelected
        self.favouriteValueUpdated?(favouriteButton.isSelected)
        
    }
}
