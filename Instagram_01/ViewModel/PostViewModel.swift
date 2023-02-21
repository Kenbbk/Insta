//
//  PostViewModel.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/01/31.
//

import UIKit

struct PostViewModel {
    var post: Post
    
    var imageUrl: URL? { return URL(string: post.imageUrl) }
    
    var caption: String { return post.caption }
    
    var likes: Int { return post.likes }
    
    var userProfileImageUrl: URL? { return URL(string: post.ownerImageUrl)}
    
    var likeButtonTintcolor : UIColor {
        return post.didLike ? .red : .black
    }
    
    var likeButtonImage: UIImage? {
        return post.didLike ? UIImage(named: "like_selected") : UIImage(named: "like_unselected")
    }
    
    var likesLabelText: String {
        if post.likes != 1 {
            return "\(post.likes) likes"
        } else {
            return "\(post.likes) like"
        }
    }
    
    var timestampString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        
        let formattedString = formatter.string(from: post.timestamp.dateValue(), to: Date()) ?? ""
        return "\(formattedString) ago"
    }
    
    var username: String { return post.ownerUsername}
    init(post: Post) {
        self.post = post
    }
}
