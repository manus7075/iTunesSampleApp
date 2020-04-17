//
//  LTNetworkManager.swift
//  LightweightiTunesCatalog
//
//  Created by Manoj Telkuntla on 2020/04/14.
//  Copyright © 2020 Lightweight iTunes Catalog. All rights reserved.
//

import Foundation

final class LTNetworkManager {

    var catalogList: [CatalogDetails] = []
    private let domainUrlString = "https://itunes.apple.com"
    private let defaultText = "jack+johnson"
    func fetchCatalogList(withSearch search:String,completionHandler: @escaping ([CatalogDetails]) -> Void) {
    //        let searchText = search.count == 0 ? defaultText : search
        let searchEncode = search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let url = URL(string: domainUrlString + "/search?term=\(searchEncode)")!

        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
          if let error = error {
            print("Error with fetching films: \(error)")
            return
          }

            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    print("Error with the response, unexpected status code: \(String(describing: response))")
            return
          }
           if let data = data,
             let filmSummary = try? JSONDecoder().decode(CatalogListSummary.self, from: data) {
             completionHandler(filmSummary.results ?? [])
           }
        })
        task.resume()
      }

}
