//
//  AuthService.swift
//  stru
//
//  Created by Ti on 28/9/18.
//  Copyright © 2018 Group_37. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class AuthService
{
    static func signIn (email: String, password: String, onSucess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?)->Void)
    {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSucess()
            print("sign in successfully")
        })
    }
    
    static func signUp (username: String, email: String, password: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?)->Void)
    {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            let uid = user?.user.uid
            let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REFERENCE).child("profile_image").child(uid!)
            
            //            if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1)
            //            {
            storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil { return }
                storageRef.downloadURL(completion: { (url, error) in
                    if (error == nil) {
                        if let downloadUrl = url {
                            let profileImageUrl = downloadUrl.absoluteString
                            self.setUserInformation(profileImageUrl: profileImageUrl, username: username, email: email, uid: uid!, onSuccess: onSuccess)
                        }
                    } else {
                        print("download url error")
                        return
                    }
                })
            })
            //            }
        })
    }
    
    static func setUserInformation(profileImageUrl: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void){
        let ref = Database.database().reference()
        let userReference = ref.child("users")
        let newUserReference = userReference.child(uid)
        //                                let profileImgUrl = storageRef.child("images")
        newUserReference.setValue(["username": username, "email": email, "profileImageUrl": profileImageUrl])
        onSuccess()
    }
}
