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

struct TwitterAccount {
  // logged or not
  enum AccountStatus {
    case unavailable
    case authorized(ACAccount)
  }

  enum Errors: Error {
    case unableToAccessAccountType
  }

  // MARK: - Properties
  private let accountStore = ACAccountStore()

  // MARK: - Getting the current twitter account
  var `default`: Driver<AccountStatus> {
    return Observable.create({ observer in
      guard let type = self.accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter) else {
        observer.onError(Errors.unableToAccessAccountType)
        return Disposables.create()
      }

      // emit on any change
      let notifications = NotificationCenter.default.rx.notification(Notification.Name.ACAccountStoreDidChange)
        .map { _ in self.account(in: self.accountStore, for: type)}
        .subscribe(observer)

      self.accountStore.requestAccessToAccounts(with: type, options: nil, completion: { success, error in
        if success {
          observer.onNext(self.account(in: self.accountStore, for: type))
        } else if let error = error {
          observer.onError(error)
        }
      })

      return Disposables.create {
        notifications.dispose()
      }
    })
      .asDriver(onErrorJustReturn: .unavailable)
  }

  private func account(in accountStore: ACAccountStore, for type: ACAccountType) -> AccountStatus {
    guard let currentAccount = accountStore.accounts(with: type)?.first as? ACAccount else {
      return AccountStatus.unavailable
    }
    return AccountStatus.authorized(currentAccount)
  }
}
