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

import RxSwift
import RxCocoa
import RxRealm

import RealmSwift
import Reachability
import Unbox

class TimelineFetcher {

  private let timerDelay: TimeInterval = 30
  private let bag = DisposeBag()
  private let feedCursor = Variable<TimelineCursor>(.none)

  // MARK: input
  let paused = Variable<Bool>(false)

  // MARK: output
  let timeline: Observable<[Tweet]>
  // MARK: Init with list or user

  //provide list id to fetch list's tweets
  convenience init(account: Driver<TwitterAccount.AccountStatus>, list: ListIdentifier, apiType: TwitterAPIProtocol.Type) {
    self.init(account: account, jsonProvider: apiType.timeline(of: list))
  }

  //provide username to fetch user's tweets
  convenience init(account: Driver<TwitterAccount.AccountStatus>, username: String, apiType: TwitterAPIProtocol.Type) {
    self.init(account: account, jsonProvider: apiType.timeline(of: username))
  }

  private init(account: Driver<TwitterAccount.AccountStatus>, jsonProvider: @escaping (ACAccount, TimelineCursor) -> Observable<[JSONObject]>) {
    //
    // subscribe for the current twitter account
    //
    let currentAccount: Observable<ACAccount> = account
      .filter { account in
        switch account {
        case .authorized: return true
        default: return false
        }
      }
      .map { account -> ACAccount in
        switch account {
        case .authorized(let acaccount):
          return acaccount
        default: fatalError()
        }
      }
      .asObservable()

    //
    // timer that emits a reachable logged account
    //
    let reachableTimerWithAccount = Observable.combineLatest(
      Observable<Int>.timer(0, period: timerDelay, scheduler: MainScheduler.instance),
      Reachability.rx.reachable,
      currentAccount,
      paused.asObservable(),
      resultSelector: { _, reachable, account, paused in
        return (reachable && !paused) ? account : nil
    })
      .filter { $0 != nil }
      .map { $0! }

    let feedCursor = Variable<TimelineCursor>(.none)

    //
    // Re-fetch the timeline
    //

    timeline = Observable<[Tweet]>.never()

    //
    // Store the latest position through timeline
    //
  }

  static func currentCursor(lastCursor: TimelineCursor, tweets: [Tweet]) -> TimelineCursor {
    return tweets.reduce(lastCursor) { status, tweet in
      let max: Int64 = tweet.id < status.maxId ? tweet.id-1 : status.maxId
      let since: Int64 = tweet.id > status.sinceId ? tweet.id : status.sinceId
      return TimelineCursor(max: max, since: since)
    }
  }
}
