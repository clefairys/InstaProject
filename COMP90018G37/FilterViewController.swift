//
//  FilterViewController.swift
//  COMP90018G37
//
//  Created by Jia Miao on 2018/9/23.
//  Copyright © 2018 Group_37. All rights reserved.
//
import UIKit
import CropViewController
protocol FilterViewControllerDelegate {
    func updatePhoto(image: UIImage)
}

class FilterViewController: UIViewController,CropViewControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterPhoto: UIImageView!
    var delegate: FilterViewControllerDelegate?
    var selectedImage: UIImage!
    var editedImage: UIImage?
    var contrastFilter: CIFilter!
    var brightnessFilter: CIFilter!
    var croppedRect = CGRect.zero
    var croppedAngle = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        filterPhoto.image = selectedImage
        filterPhoto.contentMode = .scaleAspectFill
        // Do any additional setup after loading the view.
    }
    @IBAction func cancelBtn_TouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func nextBtn_TouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.updatePhoto(image: self.filterPhoto.image!)
    }

    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
            
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    @IBAction func BrightSlider_ValueChange(_ sender: UISlider) {
        let context = CIContext(options: nil)
        let ciImage = CIImage(image: selectedImage)
        brightnessFilter = CIFilter(name: "CIColorControls");
        brightnessFilter.setValue(ciImage, forKey: "inputImage")
        brightnessFilter.setValue(NSNumber(value: sender.value), forKey: "inputBrightness")
        if let filteredImage = brightnessFilter.value(forKey: kCIOutputImageKey) as? CIImage {
            let cgimgresult = context.createCGImage(filteredImage, from: filteredImage.extent)
            let result = UIImage(cgImage: cgimgresult!)
            filterPhoto.image =  result
        }
    }
    
    @IBAction func ContrastSlider_ValueChange(_ sender: UISlider) {
        let context = CIContext(options: nil)
        let ciImage = CIImage(image: selectedImage)
        contrastFilter = CIFilter(name: "CIColorControls");
        contrastFilter.setValue(ciImage, forKey: "inputImage")
        contrastFilter.setValue(NSNumber(value: sender.value), forKey: "inputContrast")
        if let filteredImage = contrastFilter.value(forKey: kCIOutputImageKey) as? CIImage {
            let cgimgresult = context.createCGImage(filteredImage, from: filteredImage.extent)
            let result = UIImage(cgImage: cgimgresult!)
            filterPhoto.image =  result
        }
    }
    
    @IBAction func CropBtn_TouchUpInside(_ sender: Any) {
        let cropViewController = CropViewController(image: selectedImage)
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        selectedImage = image
        filterPhoto.image =  image
    }
    
    @IBAction func F1Btn(_ sender: Any) {
        let context = CIContext(options: nil)
        let ciImage = CIImage(image: selectedImage)
        let filter = CIFilter(name: "CISepiaTone")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        if let filteredImage = filter.value(forKey: kCIOutputImageKey) as? CIImage {
            let cgimgresult = context.createCGImage(filteredImage, from: filteredImage.extent)
            let result = UIImage(cgImage: cgimgresult!)
            filterPhoto.image =  result
        }
    }
    
    @IBAction func F2Btn(_ sender: Any) {
        let context = CIContext(options: nil)
        let ciImage = CIImage(image: selectedImage)
        let filter = CIFilter(name: "CIPhotoEffectFade")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        if let filteredImage = filter.value(forKey: kCIOutputImageKey) as? CIImage {
            let cgimgresult = context.createCGImage(filteredImage, from: filteredImage.extent)
            let result = UIImage(cgImage: cgimgresult!)
            filterPhoto.image =  result
        }
    }
    
    @IBAction func F3Btn(_ sender: Any) {
        let context = CIContext(options: nil)
        let ciImage = CIImage(image: selectedImage)
        let filter = CIFilter(name: "CIPhotoEffectNoir")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        if let filteredImage = filter.value(forKey: kCIOutputImageKey) as? CIImage {
            let cgimgresult = context.createCGImage(filteredImage, from: filteredImage.extent)
            let result = UIImage(cgImage: cgimgresult!)
            filterPhoto.image =  result
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

