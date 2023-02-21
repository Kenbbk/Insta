//
//  FollowerCellViewModel.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/02/09.
//

import UIKit

struct FollowerCellViewModel {
    
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
    
    var followButtonshouldHidden: Bool {
        return user.isFollowed
    }
    
    var followButtonTitle: NSAttributedString {
        var trueText = NSMutableAttributedString(string: "·", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight(30))])
        trueText.append(NSAttributedString(string: " Following", attributes: [.font: UIFont.boldSystemFont(ofSize: 15), .foregroundColor: UIColor.black.withAlphaComponent(0.8)]))
        var falseText = NSMutableAttributedString(string: "·", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight(30))])
        falseText.append(NSAttributedString(string: " Follow", attributes: [.font: UIFont.boldSystemFont(ofSize: 15), .foregroundColor: UIColor.systemBlue.withAlphaComponent(0.8)]))
        
        return user.followingStatusToggled ? trueText : falseText
    }
    
    init(user: User) {
        self.user = user
    }
}
