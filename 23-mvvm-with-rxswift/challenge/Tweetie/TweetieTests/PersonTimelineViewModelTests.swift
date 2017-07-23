//
//  PersonTimelineViewModelTests.swift
//  Tweetie
//
//  Created by Marin Todorov on 12/5/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import XCTest
import Accounts
import RxSwift
import RxCocoa
import Unbox
import RealmSwift

@testable import Tweetie

class PersonTimelineViewModelTests: XCTestCase {

  private func createViewModel(_ account: Driver<TwitterAccount.AccountStatus>) -> PersonTimelineViewModel {
    return PersonTimelineViewModel(
      account: account,
      username: TestData.listId.username,
      apiType: TwitterTestAPI.self)
  }

  func test_whenInitialized_storesInitParams() {
    let accountSubject = PublishSubject<TwitterAccount.AccountStatus>()
    let viewModel = createViewModel(accountSubject.asDriver(onErrorJustReturn: .unavailable))

    XCTAssertNotNil(viewModel.account)
    XCTAssertEqual(viewModel.username, TestData.listId.username)
  }

  func test_whenInitialized_bindsTweets() {
    let asyncExpect = expectation(description: "fullfill test")

    TwitterTestAPI.reset()

    let accountSubject = PublishSubject<TwitterAccount.AccountStatus>()
    let viewModel = createViewModel(accountSubject.asDriver(onErrorJustReturn: .unavailable))

    let allTweets = TestData.tweetsJSON

    var values = [Tweet]()
    let subscription = viewModel.tweets
      .filter { $0.count == allTweets.count }
      .drive(onNext: {
        values = $0
        asyncExpect.fulfill()
      })

    accountSubject.onNext(.authorized(TestData.account))

    // why does it need to happen later?
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
      TwitterTestAPI.objects.onNext(allTweets)
      TwitterTestAPI.objects.onCompleted()
    })

    waitForExpectations(timeout: 2.0, handler: { error in
      XCTAssertNil(error, "error: \(error!.localizedDescription)")
      XCTAssertTrue(values.count == 3)
      XCTAssertEqual(values[0].id, 1)
      XCTAssertEqual(values[1].id, 2)
      XCTAssertEqual(values[2].id, 3)
      XCTAssertEqual(TwitterTestAPI.lastMethodCall, "timeline(of:)")
      subscription.dispose()
    })
  }
}
