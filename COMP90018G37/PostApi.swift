//
//  PostApi.swift
//  COMP90018G37
//
//  Created by Ti on 29/9/18.
//  Copyright © 2018 Group_37. All rights reserved.
//

import Foundation
import FirebaseDatabase
class PostApi {
    var REF_POSTS = Database.database().reference().child("posts")
    func observePosts(completion: @escaping (Post) -> Void) {
        REF_POSTS.observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let newPost = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                completion(newPost)
            }
        }
    }
    
    func observePost(withId id: String, completion: @escaping (Post) -> Void) {
        REF_POSTS.child(id).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                completion(post)
            }
        })
    }
    
    func observeLikeCount(withPostId id: String, completion: @escaping (Int, UInt) -> Void) {
        var likeHandler: UInt!
        likeHandler = REF_POSTS.child(id).observe(.childChanged, with: {
            snapshot in
            if let value = snapshot.value as? Int {
              //  Database.database().reference().removeObserver(withHandle: ref)
                completion(value, likeHandler)
            }
        })
        
    }
    
    func observeTopPosts(completion: @escaping (Post) -> Void) {
        REF_POSTS.queryOrdered(byChild: "likeCount").observeSingleEvent(of: .value, with: {
            snapshot in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach({ (child) in
                if let dict = child.value as? [String: Any] {
                    let post = Post.transformPostPhoto(dict: dict, key: child.key)
                    completion(post)
                }
            })
        })
    }
    
    func removeObserveLikeCount(id: String, likeHandler: UInt) {
        Api.Post.REF_POSTS.child(id).removeObserver(withHandle: likeHandler)
    }
    
    
    func incrementLikes(postId: String, onSucess: @escaping (Post) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let postRef = Api.Post.REF_POSTS.child(postId)
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = Api.User.CURRENT_USER?.uid {
                var likes: Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    likeCount += 1
                    likes[uid] = true
                }
                post["likeCount"] = likeCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot!.key)
                onSucess(post)
            }
        }
    }
    
    func report(_ post: Post, message: String) {
        guard let postId = post.id, let postUid = post.uid, let photoUrl = post.photoUrl else { return }
        var videoUrl = ""
        if let video_url = post.videoUrl {
            videoUrl = video_url
        }
        let reportDict = ["postId": postId,
                          "postUid": postUid,
                          "photoUrl": photoUrl,
                          "videoUrl": videoUrl]
        let reportRef = Database.database().reference().child("reportPosts")
        reportRef.child(postId).updateChildValues(reportDict)
        let reporterInformation = [Api.User.CURRENT_USER!.uid: message]
        reportRef.child(postId).child("reporterInformation").updateChildValues(reporterInformation)
        
        let reportCountRef = reportRef.child(postId).child("report_count")
        reportCountRef.runTransactionBlock { (mutableData) -> TransactionResult in
            let currentCount = mutableData.value as? Int ?? 0
            mutableData.value = currentCount + 1
            return TransactionResult.success(withValue: mutableData)
        }
    }
    
}
