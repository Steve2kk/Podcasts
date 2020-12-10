//
//  CMTime.swift
//  Podcasts
//
//  Created by Vsevolod Shelaiev on 31.10.2020.
//  Copyright © 2020 Vsevolod Shelaiev. All rights reserved.
//

import AVKit

extension CMTime {
    
    func toDisplayStringTime() -> String {
        if CMTimeGetSeconds(self).isNaN {
            return "--:--"
        }
        let totalSeconds = Int(CMTimeGetSeconds(self))
        print("Total seconds:",totalSeconds)
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        let timeFormatString = String(format: "%02d:%02d", minutes, seconds)
        return timeFormatString
    }
}
