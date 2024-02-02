//
//  AnimationHelper.swift
//  log
//
//  Created by 4 on 2023.12.31.
//

//import SwiftUI
//import UIKit

/*
 
 using the default animation instead
 
 this was the old code to get this to work:
 
.onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)) { notification in
    let animation = AnimationHelper.getKeyboardDownAnimation(from: notification)
    withAnimation(animation) {
        keyboardUp = false
    }

}
.onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)) { notification in
    let animation = AnimationHelper.getKeyboardUpAnimation(from: notification)
    withAnimation(animation) {
        keyboardUp = true
    }
}
 
*/
 
//
//class AnimationHelper {
////    static let main = AnimationHelper()
//    
//    static var keyboardUpAnimation: Animation? = nil
//    static var keyboardDownAnimation: Animation? = nil
//    
//    private static func getKeyboardAnimation(from notification: Notification) -> Animation {
//        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 2
//        let curveNumber: UInt = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0
//        let animationCurve = UIView.AnimationCurve(rawValue: Int(curveNumber)) ?? .easeOut
//        
//        let timing = UICubicTimingParameters(animationCurve: animationCurve)
//        if let springParams = timing.springTimingParameters,
//           let mass = springParams.value(forKey: "mass") as? Double,
//           let stiffness = springParams.value(forKey: "stiffness") as? Double,
//           let damping = springParams.value(forKey: "damping") as? Double {
//            return Animation.interpolatingSpring(mass: mass, stiffness: stiffness, damping: damping)
//        } else {
//            return Animation.easeOut(duration: duration) // this is the closest fallback
//        }
//    }
//    
//    static func getKeyboardDownAnimation(from notification: Notification) -> Animation {
//        let animation = getKeyboardAnimation(from: notification)
//        keyboardDownAnimation = animation
//        return animation
//    }
//    
//    static func getKeyboardUpAnimation(from notification: Notification) -> Animation {
//        let animation = getKeyboardAnimation(from: notification)
//        keyboardUpAnimation = animation
//        return animation
//    }
//}
