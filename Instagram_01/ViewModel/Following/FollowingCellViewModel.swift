//
//  FollowingCell.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/02/20.
//
import UIKit

struct FollowingCellViewModel {
    
    let user: User
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var username: String {
        return user.username
    }
    
    var fullname: String {
        return user.fullname
    }
    
    var followingStatusButtonTitle: String {
        return user.isFollowed ? "Following" : "Follow"
    }
    
    var backgroundColor: UIColor {
        return user.isFollowed ? .lightGray.withAlphaComponent(0.2) : .systemBlue.withAlphaComponent(0.8)
    }
    
    var textColor: UIColor {
        return user.isFollowed ? .black : .white
    }
//    var followButtonshouldHidden: Bool {
//        return user.isFollowed
//    }
//
    init(user: User) {
        self.user = user
    }
}
