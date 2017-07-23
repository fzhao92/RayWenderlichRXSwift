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
import Cocoa
import RxCocoa

class Navigator {
  lazy private var defaultStoryboard = NSStoryboard(name: "Main", bundle: nil)

  // MARK: - segues list
  enum Segue {
    case listTimeline(Driver<TwitterAccount.AccountStatus>, ListIdentifier)
    case listPeople(Driver<TwitterAccount.AccountStatus>, ListIdentifier)
    case personTimeline(Driver<TwitterAccount.AccountStatus>, username: String)
  }

  // MARK: - invoke a single segue
  func show(segue: Segue, sender: NSViewController) {
    switch segue {
    case .listTimeline(let account, let list):
      //show the combined timeline for the list
      let vm = ListTimelineViewModel(account: account, list: list)
      if let replaceableSender = (sender.parent as? NSSplitViewController)?.childViewControllers.last {
        show(target: ListTimelineViewController.createWith(navigator: self, storyboard: sender.storyboard ?? defaultStoryboard, viewModel: vm), sender: replaceableSender)
      } else {
        show(target: ListTimelineViewController.createWith(navigator: self, storyboard: sender.storyboard ?? defaultStoryboard, viewModel: vm), sender: sender)
      }
      
    case .listPeople(let account, let list):
      //show the list of user accounts in the list
      let vm = ListPeopleViewModel(account: account, list: list)
      show(target: ListPeopleViewController.createWith(navigator: self, storyboard: sender.storyboard ?? defaultStoryboard, viewModel: vm), sender: sender)

    case .personTimeline(let account, username: let username):
      //show a given user timeline
      if let replaceableSender = (sender.parent as? NSSplitViewController)?.childViewControllers.last {
        let vm = PersonTimelineViewModel(account: account, username: username)
        show(target: PersonTimelineViewController.createWith(navigator: self, storyboard: sender.storyboard ?? defaultStoryboard, viewModel: vm), sender: replaceableSender)
      }

    }
  }

  private func show(target: NSViewController, sender: NSViewController) {
    if let split = sender as? NSSplitViewController {
      split.addChildViewController(target)
    }

    if let split = sender.parent as? NSSplitViewController,
      let index = split.childViewControllers.index(of: sender) {
      split.childViewControllers.replaceSubrange(index...index, with: [target])
    }
  }
}
