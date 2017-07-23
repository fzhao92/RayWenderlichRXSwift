/*
 * Copyright (c) 2016-2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import XCTest
import Accounts

import RxSwift
import RxCocoa

@testable import Tweetie

class TwitterTestAPI: TwitterAPIProtocol {
  static func reset() {
    lastMethodCall = nil
    objects = PublishSubject<[JSONObject]>()
  }

  static var objects = PublishSubject<[JSONObject]>()
  static var lastMethodCall: String?

  static func timeline(of username: String) -> (ACAccount, TimelineCursor) -> Observable<[JSONObject]> {
    return { account, cursor in
      lastMethodCall = #function
      return objects.asObservable()
    }
  }

  static func timeline(of list: ListIdentifier) -> (ACAccount, TimelineCursor) -> Observable<[JSONObject]> {
    return { account, cursor in
      lastMethodCall = #function
      return objects.asObservable()
    }
  }

  static func members(of list: ListIdentifier) -> (ACAccount) -> Observable<[JSONObject]> {
    return { list in
      lastMethodCall = #function
      return objects.asObservable()
    }
  }
}
