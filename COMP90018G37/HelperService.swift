//
//  HelperService.swift
//  COMP90018G37
//
//  Created by Jia Miao on 2018/9/26.
//  Copyright © 2018 Group_37. All rights reserved.
//
import Foundation
import FirebaseStorage
import FirebaseDatabase
class HelperService {
    static func uploadDataToServer(data: Data, ratio: CGFloat, caption: String, onSuccess: @escaping () -> Void) {
        uploadImageToFirebaseStorage(data: data) { (photoUrl) in
            self.sendDataToDatabase(photoUrl: photoUrl, ratio: ratio, caption: caption, onSuccess: onSuccess)
        }
    }

    
    static func uploadImageToFirebaseStorage(data: Data, onSuccess: @escaping (_ imageUrl: String) -> Void) {
        let photoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF).child("posts").child(photoIdString)
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            if let photoUrl = metadata?.downloadURL()?.absoluteString {
                onSuccess(photoUrl)
            }
            
        }
//        storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
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
    }
    
    static func sendDataToDatabase(photoUrl: String, ratio: CGFloat, caption: String, onSuccess: @escaping () -> Void) {
        let newPostId = Api.Post.REF_POSTS.childByAutoId().key
        let newPostReference = Api.Post.REF_POSTS.child(newPostId)
        
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        
        let currentUserId = currentUser.uid
        
        let words = caption.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                let newHashTagRef = Api.HashTag.REF_HASHTAG.child(word.lowercased())
                newHashTagRef.updateChildValues([newPostId: true])
            }
        }
        
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var dict = ["uid": currentUserId ,"photoUrl": photoUrl, "caption": caption, "likeCount": 0, "ratio": ratio, "timestamp": timestamp] as [String : Any]

        
        newPostReference.setValue(dict, withCompletionBlock: {
            (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            Api.Feed.REF_FEED.child(Api.User.CURRENT_USER!.uid).child(newPostId)
                .setValue(["timestamp": timestamp])
            Api.Follow.REF_FOLLOWERS.child(Api.User.CURRENT_USER!.uid).observeSingleEvent(of: .value, with: {
                snapshot in
                let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
                arraySnapshot.forEach({ (child) in
                        Api.Feed.REF_FEED.child(child.key).child(newPostId)
                            .setValue(["timestamp": timestamp])
                        let newNotificationId = Api.Notification.REF_NOTIFICATION.child(child.key).childByAutoId().key
                        let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(child.key).child(newNotificationId)
                        newNotificationReference.setValue(["from": Api.User.CURRENT_USER!.uid, "type": "feed", "objectId": newPostId, "timestamp": timestamp])
                    
                  
                })
            })
            let myPostRef = Api.MyPosts.REF_MYPOSTS.child(currentUserId).child(newPostId)
            myPostRef.setValue(["timestamp": timestamp], withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            ProgressHUD.showSuccess("Success")
            onSuccess()
        })
    }
}
