//
//  ViewController.swift
//  SFW-Image
//
//  Created by Paulo Uchôa on 24/06/21.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    struct Filter {
        let filterName: String
        var filterEffectValue: Any?
        var filterEffectValueName: String?
        
        init(filterName: String, filterEffecValue: Any?, filterEffectValueName: String?) {
            self.filterName = filterName
            self.filterEffectValue = filterEffectValueName
            self.filterEffectValueName = filterEffectValueName
        }
    }

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var percentage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func applyFilterTo(image: UIImage) -> UIImage? {
         
     guard let cgImage = image.cgImage else {
             return nil
         }
     
     let ciImage = CIImage(cgImage: cgImage)
         
//        let context = CIContext()

         
     if let output  = sepiaFilter(ciImage, radius: 10){
             return  UIImage(ciImage: output)
         }
         
         return nil
     }

     override func didReceiveMemoryWarning() {
         super.didReceiveMemoryWarning()
     }
     
     
     func sepiaFilter(_ input: CIImage, radius: Double) -> CIImage?
     {
         let sepiaFilter = CIFilter(name:"CIGaussianBlur")
         sepiaFilter?.setValue(input, forKey: kCIInputImageKey)
         sepiaFilter?.setValue(radius, forKey: kCIInputRadiusKey)
         return sepiaFilter?.outputImage
     }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            
            let model = Nudity()
            let size = CGSize(width: 224, height: 224)
        
            
            guard let buffer = image.resize(to: size)?.pixelBuffer() else {
                fatalError("Scaling or converting to pixel buffer failed!")
            }

            guard let result = try? model.prediction(data: buffer) else {
                fatalError("Prediction failed!")
            }

            let confidence = result.prob["\(result.classLabel)"]! * 100.0
            let converted = String(format: "%.2f", confidence)
            
            if result.classLabel == "SFW" {
                imageView.image = image
            } else {
                let img = applyFilterTo(image: image)
                imageView.image = img
            }
            
            percentage.text = "\(result.classLabel) - \(converted) %"
            
            
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func tapFotoButton(_ sender: Any) {
        let vc = UIImagePickerController()
//        vc.sourceType = .camera
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
        
    }
    
}

