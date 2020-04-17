//
//  APIResponse.swift
//  LightweightiTunesCatalog
//
//  Created by Manoj Telkuntla on 2020/04/14.
//  Copyright © 2020 Lightweight iTunes Catalog. All rights reserved.
//

import UIKit

struct CatalogListSummary: Codable {
  let resultCount: Int?
  let results: [CatalogDetails]?
}

struct CatalogDetails: Codable {
  let trackName: String
  let id: Int
  let artworkUrl30: String
  let trackViewUrl: String
  let primaryGenreName: String
  let kind: String
  let previewUrl: String

  enum CodingKeys: String, CodingKey {
    case trackName
    case id = "trackId"
    case artworkUrl30
    case trackViewUrl
    case primaryGenreName
    case kind
    case previewUrl

  }
  
  init(trackName: String,
       trackId: Int,
       artworkUrl30: String,
       trackViewUrl: String,
    primaryGenreName: String,
    kind: String,
    previewUrl:String
  ) {
    self.trackName = trackName
    self.id = trackId
    self.artworkUrl30 = artworkUrl30
    self.trackViewUrl = trackViewUrl
    self.primaryGenreName = primaryGenreName
    self.kind = kind
    self.previewUrl = previewUrl
  }
}
