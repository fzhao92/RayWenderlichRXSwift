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
import Accounts
import Unbox
@testable import Tweetie

class TestData {
  static let account = ACAccount()
  static let listId: ListIdentifier = (username:"user" , slug: "slug")

  static let personJSON: [String: Any] = [
    "id": 1,
    "name": "Name",
    "screen_name": "ScreeName",
    "description": "Description",
    "url": "url",
    "profile_image_url_https": "profile_image_url_https",
    ]

  static var personUserObject: User {
    return (try! unbox(dictionary: personJSON))
  }

  static let tweetJSON: [String: Any] = [
    "id": 1,
    "text": "Text",
    "user": [
      "name": "Name",
      "profile_image_url_https": "Url"
    ],
    "created": "2011-11-11T20:00:00GMT"
  ]

  static var tweetsJSON: [[String: Any]] {
    return (1...3).map {
      var dict = tweetJSON
      dict["id"] = $0
      return dict
    }
  }

  static var tweets: [Tweet] {
    return try! unbox(dictionaries: tweetsJSON, allowInvalidElements: true) as [Tweet]
  }
}
