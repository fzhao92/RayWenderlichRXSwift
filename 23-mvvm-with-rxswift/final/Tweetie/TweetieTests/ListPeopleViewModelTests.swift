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

import XCTest
import Accounts
import RxSwift
import RxCocoa
import Unbox

@testable import Tweetie

class ListPeopleViewModelTests: XCTestCase {

  private func createViewModel(_ account: Driver<TwitterAccount.AccountStatus>) -> ListPeopleViewModel {
    return ListPeopleViewModel(
      account: account,
      list: TestData.listId,
      apiType: TwitterTestAPI.self)
  }

  func test_whenInitialized_storesInitParams() {
    let accountSubject = PublishSubject<TwitterAccount.AccountStatus>()
    let viewModel = createViewModel(accountSubject.asDriver(onErrorJustReturn: .unavailable))

    XCTAssertNotNil(viewModel.account)
    XCTAssertEqual(viewModel.list.username+viewModel.list.slug, TestData.listId.username+TestData.listId.slug)
    XCTAssertNotNil(viewModel.apiType)
  }

  func test_whenAccountAvailable_thenFetchesPeople() {
    let asyncExpect = expectation(description: "fullfill test")

    TwitterTestAPI.reset()

    let accountSubject = PublishSubject<TwitterAccount.AccountStatus>()
    let viewModel = createViewModel(accountSubject.asDriver(onErrorJustReturn: .unavailable))

    _ = viewModel.people.asObservable()
      .filter { $0 != nil }
      .subscribe(onNext: { _ in
        asyncExpect.fulfill()
      })

    XCTAssertNil(viewModel.people.value, "people is not nil by default")

    accountSubject.onNext(.authorized(TestData.account))

    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
      TwitterTestAPI.objects.onNext([TestData.personJSON])
      TwitterTestAPI.objects.onCompleted()
    })

    waitForExpectations(timeout: 1.0, handler: { error in
      XCTAssertNil(error, "error: \(error!.localizedDescription)")
      XCTAssertNotNil(viewModel.people.value, "people is nil")
      let person = TestData.personUserObject
      XCTAssertEqual(viewModel.people.value!.first!.id, person.id)
      XCTAssertEqual(TwitterTestAPI.lastMethodCall, "members(of:)")
    })
  }
}
