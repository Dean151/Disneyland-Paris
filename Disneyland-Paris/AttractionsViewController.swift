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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.title = NSLocalizedString("Attractions", comment: "")
    }
    
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
            if let _ = error {
                self.loadingError()
            } else if let attractionsList = attractions {
                let json = JSON(data: attractionsList)
                
                for (_, subJson): (String, JSON) in json {
                    if let identifier = subJson["idbio"].string,
                        name = subJson["title"].string,
                        cat = subJson["categorie"].int,
                        desc = subJson["description"].string,
                        long = subJson["coord_x"].double,
                        lat = subJson["coord_y"].double {
                            let att = Attraction(id: identifier, name: name, categorie: cat, description: desc, latitude: lat, longitude: long)
                            self.poiDict.updateValue(att, forKey: identifier)
                            self.poiIndexes.append(identifier)
                    }
                }
                self.sort(beginEndUpdate: false)
                print("Success to get attractions")
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
            if let _ = error {
                self.loadingError()
            } else if let waitTimesList = waitTimes {
                let json = JSON(data: waitTimesList)
                
                for (_, subJson): (String, JSON) in json {
                    if let identifier = subJson["idbio"].string,
                        poi = self.poiDict[identifier] as? Attraction,
                        opening = subJson["opening"].string,
                        closing = subJson["closing"].string,
                        open = subJson["open"].int,
                        waitTime = subJson["waittime"].int {
                            poi.update(open: open, opening: opening, closing: closing)
                            poi.waittime = waitTime
                    }
                }
                self.sort(beginEndUpdate: true)
                print("Success to get waittimes")
                completion()
            } else {
                self.loadingError()
            }
        })
    }
}
