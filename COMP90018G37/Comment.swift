//
//  Comment.swift
//  COMP90018G37
//
//  Created by iMeigoo on 3/10/18.
//  Copyright © 2018 Group_37. All rights reserved.
//

import Foundation
class Comment {
    var commentText: String?
    var uid: String?
}

extension Comment {
    static func transformComment(dict: [String: Any]) -> Comment {
        let comment = Comment()
        comment.commentText = dict["commentText"] as? String
        comment.uid = dict["uid"] as? String
        return comment
    }
}
