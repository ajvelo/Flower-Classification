//
//  WikiRequest.swift
//  Flower Classification
//
//  Created by Andreas Velounias on 23/12/2017.
//  Copyright © 2017 Andreas Velounias. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SDWebImage
import ColorThiefSwift

class WikiRequest {
    
    weak var viewController: ViewController!
    
    init(viewController: ViewController) {
        
        self.viewController = viewController
    }
    
    func requestInfo(flowerName: String) {
        
        let wikipediaURl = "https://en.wikipedia.org/w/api.php"
        
        let parameters : [String:String] = ["format" : "json", "action" : "query", "prop" : "extracts|pageimages", "exintro" : "", "explaintext" : "", "titles" : flowerName, "redirects" : "1", "pithumbsize" : "500", "indexpageids" : ""]
        
        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                let flowerJSON : JSON = JSON(response.result.value!)
                
                let pageid = flowerJSON["query"]["pageids"][0].stringValue
                
                let flowerDescription = flowerJSON["query"]["pages"][pageid]["extract"].stringValue
                let flowerImageURL = flowerJSON["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
                
                let split = flowerDescription.split(separator: ".")
                
                let lastTwo = String(split.prefix(2).joined(separator: ["."]))

                self.viewController.label.text = lastTwo + "."
                
                
                self.viewController.imageView.sd_setImage(with: URL(string: flowerImageURL), completed: { (image, error,  cache, url) in
                    
                    if let currentImage = self.viewController.imageView.image {
                        
                        guard let dominantColor = ColorThief.getColor(from: currentImage) else {
                            fatalError("Can't get dominant color")
                        }
                        
                        
                        DispatchQueue.main.async {
                            self.viewController.navigationController?.navigationBar.isTranslucent = true
                            self.viewController.navigationController?.navigationBar.barTintColor = dominantColor.makeUIColor()
                            
                            
                        }
                    } else {
                        self.viewController.imageView.image = self.viewController.imageView.image
                        self.viewController.label.text = "Could not get information on flower from Wikipedia."
                    }
                    
                })
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.viewController.label.text = "Connection Issues"
                
                
                
            }
        }
    }
}
