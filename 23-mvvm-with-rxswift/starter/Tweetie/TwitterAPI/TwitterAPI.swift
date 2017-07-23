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
import Social
import RxSwift
import RxCocoa

typealias JSONObject = [String: Any]
typealias ListIdentifier = (username: String, slug: String)

protocol TwitterAPIProtocol {
  static func timeline(of username: String) -> (ACAccount, TimelineCursor) -> Observable<[JSONObject]>
  static func timeline(of list: ListIdentifier) -> (ACAccount, TimelineCursor) -> Observable<[JSONObject]>
  static func members(of list: ListIdentifier) -> (ACAccount) -> Observable<[JSONObject]>
}

struct TwitterAPI: TwitterAPIProtocol {

  // MARK: - API Addresses
  fileprivate enum Address: String {
    case timeline = "statuses/user_timeline.json"
    case listFeed = "lists/statuses.json"
    case listMembers = "lists/members.json"

    private var baseURL: String { return "https://api.twitter.com/1.1/" }
    var url: URL {
      return URL(string: baseURL.appending(rawValue))!
    }
  }

  // MARK: - API errors
  enum Errors: Error {
    case requestFailed
    case badResponse
    case httpError(Int)
  }

  // MARK: - API Endpoint Requests
  static func timeline(of username: String) -> (ACAccount, TimelineCursor) -> Observable<[JSONObject]> {
    return { account, cursor in
      return request(account, address: TwitterAPI.Address.timeline, parameters: ["screen_name": username, "contributor_details": "false", "count": "100", "include_rts": "true"])
    }
  }

  static func timeline(of list: ListIdentifier) -> (ACAccount, TimelineCursor) -> Observable<[JSONObject]> {
    return { account, cursor in
      var params = ["owner_screen_name": list.username, "slug": list.slug]
      if cursor != TimelineCursor.none {
        params["max_id"]   = String(cursor.maxId)
        params["since_id"] = String(cursor.sinceId)
      }
      return request(
        account, address: TwitterAPI.Address.listFeed,
        parameters: params)
    }
  }

  static func members(of list: ListIdentifier) -> (ACAccount) -> Observable<[JSONObject]> {
    return { account in
      let params = ["owner_screen_name": list.username,
                    "slug": list.slug,
                    "skip_status": "1",
                    "include_entities": "false",
                    "count": "100"]
      let response: Observable<JSONObject> = request(
        account, address: TwitterAPI.Address.listMembers,
        parameters: params)

      return response
        .map { result in
          guard let users = result["users"] as? [JSONObject] else {return []}
          return users
      }
    }
  }

  // MARK: - generic request to send an SLRequest
  static private func request<T: Any>(_ account: ACAccount, address: Address, parameters: [String: String] = [:]) -> Observable<T> {
    return Observable.create { observer in

      guard let request = SLRequest(
        forServiceType: SLServiceTypeTwitter,
        requestMethod: .GET,
        url: address.url,
        parameters: parameters
        ) else {
          observer.onError(Errors.requestFailed)
          return Disposables.create()
      }

      request.account = account

      request.perform {data, response, error in
        if let error = error {
          observer.onError(error)
        }
        if let response = response, response.statusCode >= 400 && response.statusCode < 600 {
          observer.onError(Errors.httpError(response.statusCode))
        }
        if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? T, let result = json {
          observer.onNext(result)
        }
        observer.onCompleted()
      }

      return Disposables.create()
    }
  }
}
