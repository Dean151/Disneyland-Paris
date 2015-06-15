//
//  RestaurantsViewController.swift
//  Disneyland-Paris
//
//  Created by Thomas Durand on 15/06/2015.
//  Copyright (c) 2015 Dean. All rights reserved.
//

import UIKit
import SwiftyJSON

final class RestaurantsViewController: PoiViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func manualRefresh(sender: AnyObject?) {
        if poiDict.isEmpty {
            // In this case, we need to get poi first
            self.getRestaurants() {
                self.refreshControl.endRefreshing()
            }
        } else {
            // We just need to get variable data
            self.getOpeningTimes() {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func getRestaurants(completion: () -> Void) {
        DataManager.getUrlWithSuccess(url: restaurantsURL, success: { (attractions, error) -> Void in
            if let e = error {
                self.loadingError()
            } else if let attractionsList = attractions {
                let json = JSON(data: attractionsList)
                
                for (index: String, subJson: JSON) in json {
                    if let identifier = subJson["idbio"].string,
                        name = subJson["title"].string,
                        desc = subJson["description"].string,
                        long = subJson["coord_x"].double,
                        lat = subJson["coord_y"].double {
                            let att = Restaurant(id: identifier, name: name, description: desc, latitude: lat, longitude: long)
                            self.poiDict.updateValue(att, forKey: identifier)
                            self.poiIndexes.append(identifier)
                    }
                }
                self.sort(beginEndUpdate: false)
                println("Success to get restaurants")
                self.getOpeningTimes() {
                    completion()
                }
            } else {
                self.loadingError()
            }
        })
    }
    
    func getOpeningTimes(completion: () -> Void) {
        DataManager.getUrlWithSuccess(url: ouvertureURL, success: { (waitTimes, error) -> Void in
            if let e = error {
                self.loadingError()
            } else if let waitTimesList = waitTimes {
                let json = JSON(data: waitTimesList)
                
                for (index: String, subJson: JSON) in json {
                    if let identifier = subJson["idbio"].string,
                        poi = self.poiDict[identifier] as? Restaurant,
                        opening = subJson["opening"].string,
                        closing = subJson["closing"].string,
                        open = subJson["open"].int {
                            poi.update(open: open, opening: opening, closing: closing)
                    }
                }
                self.sort(beginEndUpdate: true)
                println("Success to get opening times")
                completion()
            } else {
                self.loadingError()
            }
        })
    }
}
