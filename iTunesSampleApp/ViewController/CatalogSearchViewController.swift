//
//  CatalogSearchViewController.swift
//  LightweightiTunesCatalog
//
//  Created by Manoj Telkuntla on 2020/04/14.
//  Copyright © 2020 Lightweight iTunes Catalog. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
class CatalogSearchViewController: UIViewController  {
    @IBOutlet weak var tableView: UITableView!
    var cellIdentifier = "CatalogCell"
    let searchController = UISearchController(searchResultsController: nil)
    private var catalogList: [CatalogDetails]?
    var favouriteList: [CatalogDetails] = []
    let imageCache = NSCache<NSString, UIImage>()
    var isNavigate : Bool = false
    var searchText : String = ""
    private var kindList : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // add search Bar for TableView
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.barTintColor = UIColor.white
        self.extendedLayoutIncludesOpaqueBars = true
        // default service call
//        self.callApiRequest(search: "")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.searchBar.text = searchText
//        searchController.isActive = true
//        filterBasedonKind(for: searchText)
    }
    // search catalogList based text
    private func filterBasedonKind(for searchText: String) {
        if !isNavigate {
        self.callApiRequest(search: searchText)
        }
    }
    
    // call api request
    func callApiRequest(search:String) {
        searchText = search
        LTNetworkManager().fetchCatalogList(withSearch: search) { (catalogList) in
            self.catalogList = catalogList
            self.catalogList = self.removeDuplicateElements(posts: self.catalogList ?? [])
            self.kindList.removeAll()
            if search.count > 0 {
              for catalog in catalogList {
                  if !self.kindList.contains(catalog.kind) {
                    self.kindList.append(catalog.kind)
                  }
              }
            }
            if !(self.kindList.contains("favourite") ) && self.favouriteList.count > 0 {
                self.kindList.append("favourite")
            }
            self.kindList.sort()
            DispatchQueue.main.async{[weak self] in
              self?.tableView.reloadData()
            }
        }
    }
    func removeDuplicateElements(posts: [CatalogDetails]) -> [CatalogDetails] {
        var uniquePosts = [CatalogDetails]()
        for post in posts {
            if !uniquePosts.contains(where: {$0.id == post.id }) {
                print(post.id)
                uniquePosts.append(post)
            }
        }
        return uniquePosts
    }

}

extension CatalogSearchViewController: UITableViewDataSource {
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          if  searchController.searchBar.text != "" {
              let kind = kindList[section]
            if kind == "favourite" {
                return favouriteList.count
            }
              let fetchCatalogList = self.catalogList?.filter({$0.kind == kind })
              return fetchCatalogList?.count ?? 0
          }
          else {
            if favouriteList.count > 0
            {
                return self.favouriteList.count
            }
        }
          return catalogList?.count ?? 0
      }
    func numberOfSections(in tableView: UITableView) -> Int {
         if  searchController.searchBar.text != "" {
                 return kindList.count
               }
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if  searchController.searchBar.text != "" || favouriteList.count > 0 {
            return kindList[section]
            }
           return ""
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CatalogTableViewCell else {
             fatalError("Issue dequeuing \(cellIdentifier)")
           }
        if searchController.isActive && searchController.searchBar.text != "" || favouriteList.count > 0 {
            let kind = kindList[indexPath.section]
            var fetchCatalogList = self.catalogList?.filter({$0.kind == kind })

            if kind == "favourite" {
                fetchCatalogList = self.favouriteList
            }
            if fetchCatalogList?.count ?? 0 > 0  && indexPath.row < fetchCatalogList?.count ?? 0 {
                if let mediaDetails = fetchCatalogList?[indexPath.row] {
                    cell.configure(with: mediaDetails)
                    let isExistList = self.favouriteList.filter({$0.id == mediaDetails.id })
                    cell.favouriteButton.isSelected = isExistList.count > 0  ? true : false
                    if let cachedImage = imageCache.object(forKey: NSString(string: (mediaDetails.artworkUrl30))) {
                       cell.artworkImage.image = cachedImage
                   }
                   else {
                            cell.artworkImage.image = nil
                           DispatchQueue.global(qos: .background).async {
                               let url = URL(string:(mediaDetails.artworkUrl30))
                           let data = try? Data(contentsOf: url!)
                           let image: UIImage = UIImage(data: data!)!
                           DispatchQueue.main.async {
                                self.imageCache.setObject(image, forKey: NSString(string: mediaDetails.artworkUrl30))
                                cell.artworkImage.image = image
                               }
                        }
                    }
                    cell.favouriteValueUpdated = {[weak self](isEnabled:Bool) ->() in
                        if isEnabled {
                            self?.favouriteList.append(mediaDetails)
                        }
                        if !(self?.kindList.contains("favourite") ?? false) {
                            self?.kindList.append("favourite")
                            self?.kindList.sort()
                        }
                        DispatchQueue.main.async{[weak self] in
                          self?.tableView.reloadData()
                        }
                    }
                }
                        }
        }
        else {
            if let mediaDetails = catalogList?[indexPath.row] {
                cell.configure(with: mediaDetails)
            }
        }
           return cell
    }
    func playMovie(string:String) {
        guard let url = URL(string: string) else {
            return
        }
        if searchController.isActive{

            searchController.isActive = false

        }
        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
        let player = AVPlayer(url: url)

        // Create a new AVPlayerViewController and pass it a reference to the player.
        let controller = AVPlayerViewController()
        controller.player = player

        // Modally present the player and call the player's play() method when complete.
        present(controller, animated: true) {
            player.play()
        }
        isNavigate = false
    }


}

extension CatalogSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let kind = kindList[indexPath.section]
       var fetchCatalogList = self.catalogList?.filter({$0.kind == kind })

       if kind == "favourite" {
           fetchCatalogList = self.favouriteList
       }
       if fetchCatalogList?.count ?? 0 > 0  && indexPath.row < fetchCatalogList?.count ?? 0 {
           if let mediaDetails = fetchCatalogList?[indexPath.row] {
            isNavigate = true
            self.playMovie(string: mediaDetails.previewUrl)
            }
       }
    }
}

extension CatalogSearchViewController: UISearchResultsUpdating {
      func updateSearchResults(for searchController: UISearchController) {
        filterBasedonKind(for: searchController.searchBar.text ?? searchText)
      }

}

extension Array where Element: Equatable {
    func indexes(of element: Element) -> [Int] {
        return self.enumerated().filter({ element == $0.element }).map({ $0.offset })
    }
}
