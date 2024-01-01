//
//  SignupViewModelTest.swift
//  ChatBlurTests
//
//  Created by HappyDuck on 12/31/23.
//

import XCTest
@testable import ChatBlur

final class SignupViewModelTest: XCTestCase {

    var vm: SignupViewModel!
    
    override func setUpWithError() throws {
        vm = SignupViewModel()
    }

    override func tearDownWithError() throws {
        vm = nil
    }
    
    func test_EmailValidate_ShouldAssertTrue() throws {
        let validEmail = "test@email.com"
        XCTAssertTrue(vm.validateEmail(validEmail))
    }

    func test_EmailValidate_ShouldAssertFalse() throws {
        let invalidEmail = "test@email"
        XCTAssertFalse(vm.validateEmail(invalidEmail))
    }
    
    func test_UsernameValidate_ShouldAssertTrue() throws {
        let validUsername = "validUser1"
        XCTAssertTrue(vm.validateUsername(validUsername))
    }

    func test_UsernameValidate_ShouldAssertFalse() throws {
        let invalidUsername = "aldjkfasdfasdfasdf"
        XCTAssertFalse(vm.validateUsername(invalidUsername))
    }
    
    func test_PasswordValidate_ShouldAssertTrue() throws {
        let validPassword = "Dkssud!45"
        XCTAssertTrue(vm.validatePassword(validPassword))
    }

    func test_PasswordValidate_ShouldAssertFalse() throws {
        let invalidPassword = "Dkssudwifjdk"
        XCTAssertFalse(vm.validatePassword(invalidPassword))
    }
}
