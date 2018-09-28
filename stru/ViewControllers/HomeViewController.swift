//
//  HomeViewController.swift
//  stru
//
//  Created by clefairy on 2018/9/22.
//  Copyright © 2018年 Group_37. All rights reserved.
//

import UIKit
import FirebaseAuth
class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func logout_TouchUp(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let storyboard = UIStoryboard(name: "Start", bundle: nil)
        let signInViewCtrl = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        self.present(signInViewCtrl, animated:true, completion: nil)

    }
}
