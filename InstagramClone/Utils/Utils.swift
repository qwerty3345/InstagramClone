//
//  Utils.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/11/08.
//

import UIKit

/// 두 Date 객체 사이의 시간을 계산 해 "일➡시➡분➡초" 순으로 큰 값 기준으로 리턴
func getTimePassedString(_ from: Date, and to: Date) -> String {
    let dateComponents = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: from, to: to)
    
    if dateComponents.day != 0 {
        return "\(dateComponents.day ?? 0)일"
    }

    if dateComponents.hour != 0 {
        return "\(dateComponents.hour ?? 0)시간"
    }
    
    if dateComponents.minute != 0 {
        return "\(dateComponents.minute ?? 0)분"
    }

    return "\(dateComponents.second ?? 0)초"
}
