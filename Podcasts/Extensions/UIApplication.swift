//
//  UIApplication.swift
//  Podcasts
//
//  Created by Vsevolod Shelaiev on 15.11.2020.
//  Copyright © 2020 Vsevolod Shelaiev. All rights reserved.
//

import UIKit
extension UIApplication{
    static func mainTabBarController() -> MainTabBarController? {
        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}

