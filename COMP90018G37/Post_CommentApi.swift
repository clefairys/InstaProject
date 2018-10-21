//
//  Post_CommentApi.swift
//  COMP90018G37
//
//  Created by iMeigoo on 1/10/18.
//  Copyright © 2018 Group_37. All rights reserved.
//

import Foundation
import FirebaseDatabase
class Post_CommentApi {
    var REF_POST_COMMENTS = Database.database().reference().child("post-comments")
    
}
