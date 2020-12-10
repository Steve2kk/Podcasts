//
//  String.swift
//  Podcasts
//
//  Created by Vsevolod Shelaiev on 19.10.2020.
//  Copyright © 2020 Vsevolod Shelaiev. All rights reserved.
//

import Foundation

extension String {
    func toSecureHTTPS() -> String {
        return self.contains("https") ? self :
            self.replacingOccurrences(of: "http", with: "https")
    }
}
