//
//  ViewController.swift
//  Flower Classification
//
//  Created by Andreas Velounias on 23/12/2017.
//  Copyright © 2017 Andreas Velounias. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var label: UILabel!
    var wikiRequest: WikiRequest!
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func libraryTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Loading CoreML model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            if error != nil {
                print(error!)
            }
            
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Casting failed")
            }
            
            if let firstResult = results.first {
                
                if firstResult.confidence > 0.2 {
                    
                    self.navigationItem.title = firstResult.identifier.capitalized
                    
                    self.wikiRequest.requestInfo(flowerName: firstResult.identifier)
                }
                    
                else {
                    
                    self.navigationItem.title = "No Idea!"
                }
                
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = pickedImage
            
            guard let ciImage = CIImage(image: pickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            
            detect(image: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        wikiRequest = WikiRequest(viewController: self)

    }
}

