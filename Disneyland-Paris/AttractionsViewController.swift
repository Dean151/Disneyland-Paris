//
//  AttractionsViewController.swift
//  Disneyland-Paris
//
//  Created by Thomas Durand on 15/06/2015.
//  Copyright (c) 2015 Dean. All rights reserved.
//

import UIKit
import SwiftyJSON

final class AttractionsViewController: PoiViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func manualRefresh(sender: AnyObject?) {
        if poiDict.isEmpty {
            // In this case, we need to get poi first
            self.getAttractions() {
                self.refreshControl.endRefreshing()
            }
        } else {
            // We just need to get variable data
            self.getWaitTimes() {
                self.refreshControl.endRefreshing()
            }
        }
    }

    
    func getAttractions(completion: () -> Void) {
        DataManager.getUrlWithSuccess(url: attractionsURL, success: { (attractions, error) -> Void in
            if let e = error {
                self.loadingError()
            } else if let attractionsList = attractions {
                let json = JSON(data: attractionsList)
                
                for (index: String, subJson: JSON) in json {
                    if let identifier = subJson["idbio"].string {
                        if let name = subJson["title"].string {
                            if let desc = subJson["description"].string {
                                if let long = subJson["coord_x"].double {
                                    if let lat = subJson["coord_y"].double {
                                        let att = Attraction(id: identifier, name: name, description: desc, latitude: lat, longitude: long)
                                        self.poiDict.updateValue(att, forKey: identifier)
                                        self.poiIndexes.append(identifier)
                                    }
                                }
                            }
                        }
                    }
                }
                self.sort(beginEndUpdate: false)
                println("Success to get attractions")
                self.getWaitTimes() {
                    completion()
                }
            } else {
                self.loadingError()
            }
        })
    }
    
    func getWaitTimes(completion: () -> Void) {
        DataManager.getUrlWithSuccess(url: waitTimesURL, success: { (waitTimes, error) -> Void in
            if let e = error {
                self.loadingError()
            } else if let waitTimesList = waitTimes {
                let json = JSON(data: waitTimesList)
                
                for (index: String, subJson: JSON) in json {
                    if let identifier = subJson["idbio"].string {
                        if let poi = self.poiDict[identifier] as? Attraction {
                            if let opening = subJson["opening"].string {
                                if let closing = subJson["closing"].string {
                                    if let open = subJson["open"].int {
                                        if let waitTime = subJson["waittime"].int {
                                            poi.update(open: open, opening: opening, closing: closing)
                                            poi.waittime = waitTime
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                self.sort(beginEndUpdate: true)
                println("Success to get waittimes")
                completion()
            } else {
                self.loadingError()
            }
        })
    }
}