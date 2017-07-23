//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift

example(of: "Variable") {

  enum UserSession {

    case loggedIn, loggedOut
  }

  enum LoginError: Error {

    case invalidCredentials
  }

  let disposeBag = DisposeBag()

  // Create userSession Variable of type UserSession with initial value of .loggedOut
  let userSession = Variable(UserSession.loggedOut)

  // Subscribe to receive next events from userSession
  userSession.asObservable()
    .subscribe(onNext: {
      print("userSession changed:", $0)
    })
    .disposed(by: disposeBag)

  func logInWith(username: String, password: String, completion: (Error?) -> Void) {
    guard username == "johnny@appleseed.com",
      password == "appleseed"
      else {
        completion(LoginError.invalidCredentials)
        return
    }

    // Update userSession
    userSession.value = .loggedIn
  }

  func logOut() {
    // Update userSession
    userSession.value = .loggedOut
  }

  func performActionRequiringLoggedInUser(_ action: () -> Void) {
    // Ensure that userSession is loggedIn and then execute action()
    guard userSession.value == .loggedIn else {
      print("You can't do that!")
      return
    }

    action()
  }

  for i in 1...2 {
    let password = i % 2 == 0 ? "appleseed" : "password"

    logInWith(username: "johnny@appleseed.com", password: password) { error in
      guard error == nil else {
        print(error!)
        return
      }

      print("User logged in.")
    }

    performActionRequiringLoggedInUser {
      print("Successfully did something only a logged in user can do.")
    }
  }
}

/*:
 Copyright (c) 2014-2016 Razeware LLC

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */
