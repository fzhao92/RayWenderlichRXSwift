/*
 * Copyright (c) 2014-2016 Razeware LLC
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

import XCTest
import RxSwift
import RxBlocking
import Nimble
import RxNimble
import OHHTTPStubs
import SwiftyJSON

@testable import iGif

class iGifTests: XCTestCase {
  
  let obj = ["array":["foo","bar"], "foo":"bar"] as [String : Any]
  let request = URLRequest(url: URL(string: "http://raywenderlich.com")!)
  let errorRequest = URLRequest(url: URL(string: "http://rw.com")!)
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    stub(condition: isHost("raywenderlich.com")) { _ in
      return OHHTTPStubsResponse(jsonObject: self.obj, statusCode: 200, headers: nil)
    }
    stub(condition: isHost("rw.com")) { _ in
      return OHHTTPStubsResponse(error: RxURLSessionError.unknown)
    }
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
    OHHTTPStubs.removeAllStubs()
  }
  
  
}

extension BlockingObservable {
  func firstOrNil() -> E? {
    do {
      return try first()
    } catch {
      return nil
    }
  }
}
