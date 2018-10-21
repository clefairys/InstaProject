//
//  CameraViewController.swift
//  COMP90018G37
//
//  Created by clefairy on 2018/9/22.
//  Copyright © 2018年 Group_37. All rights reserved.
//

import UIKit
import AVFoundation
import ImagePicker
import UIKit
import FirebaseDatabase
import FirebaseStorage
import CropViewController
import FirebaseAuth
class CameraViewController: UIViewController,CropViewControllerDelegate {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var removeButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIButton!
    var selectedImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.showActionSheet))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handlePost()
    }
    
    func handlePost() {
        if selectedImage != nil {
           self.shareButton.isEnabled = true
           self.removeButton.isEnabled = true
            self.shareButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
           self.shareButton.isEnabled = false
            self.removeButton.isEnabled = false
            self.shareButton.backgroundColor = .lightGray

        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func handleSelectPhoto(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image", "public.movie"]
        present(pickerController,animated: true,completion: nil)
    }
    @objc func showActionSheet() {
        
        let actionSheet = UIAlertController(title: "PHOTO SOURCE", message: nil, preferredStyle: .actionSheet)
        
        //photo source - camera
        actionSheet.addAction(UIAlertAction(title: "CAMERA", style: .default, handler: { alertAction in
            self.showImagePickerForSourceType(.camera)
        }))
        
        //photo source - photo library
        actionSheet.addAction(UIAlertAction(title: "PHOTO LIBRARY", style: .default, handler: { alertAction in
            self.showImagePickerForSourceType(.photoLibrary)
        }))
        
        //cancel button
        actionSheet.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler:nil))
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    func showImagePickerForSourceType(_ sourceType: UIImagePickerControllerSourceType) {
        
        DispatchQueue.main.async(execute: {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            //imagePickerController.modalPresentationStyle = .currentContext
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            //imagePicker.showsCameraControls=true
            self.present(imagePicker, animated: true, completion: nil)
        })
        
    }
    @IBAction func shareButton_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show("Waiting...", interaction: false)
        if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
            let ratio = profileImg.size.width / profileImg.size.height
            HelperService.uploadDataToServer(data: imageData, ratio: ratio, caption: captionTextView.text!, onSuccess: {
                self.clean()
                self.tabBarController?.selectedIndex = 0
            })
            
        } else {
            ProgressHUD.showError("Image can't be empty")
        }
//        let photoid = NSUUID().uuidString
//        let storageRef = Storage.storage().reference(forURL: "gs://comp90018project-a1b36.appspot.com").child("post_images").child(photoid)
//
//        print("shdow1")
//        if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1)
//        {
//            print("shdow2")
//            storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
//                guard let metadata = metadata else {
//                    return
//                }
//
//                storageRef.downloadURL { (url, error) in
//                    guard let downloadURL = url
//                        else {return}
//                    print("shdow3")
//                    self.sendtoDB(postURL: downloadURL.absoluteString)
//                    print("shdow4")
//                }
//
//            })
//        }
    }
    func sendtoDB(postURL:String){
        let ref = Database.database().reference()
        let postReference = ref.child("posts")
        let newPostId=postReference.childByAutoId().key
        let newPostReference = postReference.child(newPostId)
        guard let currentUser = Auth.auth().currentUser else{
            return
        }
        
        
        let currentUserId = currentUser.uid
    newPostReference.setValue(["uid":currentUserId,"postURL":postURL,"caption":captionTextView.text!])
        self.captionTextView.text=""
        self.photo.image=UIImage(named: "default-placeholder")
        self.selectedImage=nil
        self.tabBarController?.selectedIndex=0
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard let image = images.first else {
            dismiss(animated: true, completion: nil)
            return
        }
        selectedImage = image
        photo.image = image
        dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "filter_segue", sender: nil)
        })
    }
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("cancel")
    }
    
    @IBAction func remove_TouchUpInside(_ sender: Any) {
        clean()
        handlePost()
    }
    
    func clean() {
        self.captionTextView.text = ""
        self.photo.image = UIImage(named: "placeholder-photo")
        self.selectedImage = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filter_segue" {
            let filterVC = segue.destination as! FilterViewController
            filterVC.selectedImage = self.selectedImage
            filterVC.delegate = self as! FilterViewControllerDelegate
        }
    }
    
}
extension CameraViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image
            photo.image = image
            dismiss(animated: true, completion: {
                self.performSegue(withIdentifier: "filter_segue", sender: nil)
            })
        }
    }
}
extension CameraViewController: FilterViewControllerDelegate {
    func updatePhoto(image: UIImage) {
        self.photo.image = image
        self.selectedImage = image
    }
}
