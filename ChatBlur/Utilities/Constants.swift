//
//  Constants.swift
//  ChatBlur
//
//  Created by HappyDuck on 12/29/23.
//

import Foundation

enum LoginViewConstants {
    static let email = String(localized: "Email")
    static let password = String(localized: "Password")
    static let kakao = String(localized: "KakaoTalk")
    static let findPassword = String(localized: "Find password")
    static let or = String(localized: "or")
    static let login = String(localized: "Login")
    static let signup = String(localized: "Sign Up")
    static let createNewAccount = String(localized: "Don't have an account yet?")
    static let confirm = String(localized: "Confirm")
}

enum SignupConstants {
    static let username = String(localized: "Username")
    static let email = String(localized: "Email")
    static let password = String(localized: "Password")
    static let passwordCheck = String(localized: "Confirm password")
    static let signup = String(localized: "Sign Up")
    static let usernameRegex = "^[A-Za-z0-9]+$"
    static let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    static let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$"
    static let invalidUsername = String(localized: "Username should be less than 12 characters.")
    static let invalidEmail = String(localized: "Invalid email format.")
    static let invalidPassword = String(localized: "Password should include letters, numbers, and symbols.")
    static let passwordMissmatch = String(localized: "Password missmatch")
    static let errorTitle = String(localized: "Error")
    static let errorMsg = String(localized: "Error occurred. ")
    static let confirm = String(localized: "Confirm")
}

enum FriendsViewConstants {
    static let addFriend = String(localized: "Add Friend")
    static let add = String(localized: "Add")
    static let inputEmail = String(localized: "Add a friend with email.")
}
