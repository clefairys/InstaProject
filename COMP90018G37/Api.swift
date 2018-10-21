//
//  Api.swift
//  COMP90018G37
//
//  Created by Jia Miao on 2018/9/26.
//  Copyright © 2018年 Group_37. All rights reserved.
//
import Foundation
struct Api {
    static var User = UserApi()
    static var Post = PostApi()
    static var Comment = CommentApi()
    static var Post_Comment = Post_CommentApi()
    static var MyPosts = MyPostsApi()
    static var Follow = FollowApi()
    static var Feed = FeedApi()
    static var HashTag = HashTagApi()
    static var Notification = NotificationApi()
}

