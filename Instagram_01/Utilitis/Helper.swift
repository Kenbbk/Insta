//
//  Helper.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/02/24.
//

import UIKit

struct Helper {
    
    static func getController(nav: UINavigationController?, user: User) {
        guard let controllers = nav?.viewControllers else { return }
        for controller in controllers {
            if let controller = controller as? FollowerController {
                controller.FollowerUpdate(user: user)
                
            }
        }
    }
}
