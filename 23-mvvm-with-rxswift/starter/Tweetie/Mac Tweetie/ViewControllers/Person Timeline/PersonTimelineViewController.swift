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
import RxSwift
import RxCocoa
import Then

class PersonTimelineViewController: NSViewController {

  @IBOutlet var tableView: NSTableView!

  private let bag = DisposeBag()
  fileprivate var viewModel: PersonTimelineViewModel!
  fileprivate var navigator: Navigator!

  fileprivate var tweets = [Tweet]()

  static func createWith(navigator: Navigator, storyboard: NSStoryboard, viewModel: PersonTimelineViewModel) -> PersonTimelineViewController {
    return storyboard.instantiateViewController(ofType: PersonTimelineViewController.self).then { vc in
      vc.navigator = navigator
      vc.viewModel = viewModel
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    NSApp.windows.first?.title = "Loading timeline..."
    bindUI()
  }

  func bindUI() {
    //bind the window title
    //reload the table when tweets come in
  }
}

extension PersonTimelineViewController: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return tweets.count
  }

  func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    return 56.0
  }
}

extension PersonTimelineViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let tweet = tweets[row]
    return tableView.dequeueCell(ofType: TweetCellView.self).then { cell in
      cell.update(with: tweet)
    }
  }
}
