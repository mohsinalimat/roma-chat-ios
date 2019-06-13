//
//  NotificationCenter.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-03-26.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import Foundation
import UIKit

struct NotificationName {
    
    init(){}
    
    static var shared = NotificationName()
    
    let timelines = NSNotification.Name(rawValue: "timelines_changed")
    let conversations = NSNotification.Name(rawValue: "conversations_changed")

    
    let mfcGreen = UIColor(red:0.13, green:0.58, blue:0.07, alpha:1.0)
    

}
