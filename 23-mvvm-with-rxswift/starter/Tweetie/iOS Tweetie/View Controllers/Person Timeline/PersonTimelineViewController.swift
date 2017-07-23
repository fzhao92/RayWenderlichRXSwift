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

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Then

class PersonTimelineViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  private let bag = DisposeBag()
  private var viewModel: PersonTimelineViewModel!
  private var navigator: Navigator!

  typealias TweetSection = AnimatableSectionModel<String, Tweet>

  static func createWith(navigator: Navigator, storyboard: UIStoryboard, viewModel: PersonTimelineViewModel) -> PersonTimelineViewController {
    return storyboard.instantiateViewController(ofType: PersonTimelineViewController.self).then { vc in
      vc.navigator = navigator
      vc.viewModel = viewModel
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.estimatedRowHeight = 90
    tableView.rowHeight = UITableViewAutomaticDimension
    title = "Loading..."
    bindUI()
  }

  func bindUI() {
    //bind the title
    //configure an animated table data source
    //bind the tweets to the table view
  }

  private func crateTweetsDataSource() -> RxTableViewSectionedAnimatedDataSource<TweetSection> {
    let dataSource = RxTableViewSectionedAnimatedDataSource<TweetSection>()
    dataSource.configureCell = { dataSource, tableView, indexPath, tweet in
      return tableView.dequeueCell(ofType: TweetCellView.self).then { cell in
        cell.update(with: tweet)
      }
    }
    dataSource.titleForHeaderInSection = { (ds, section: Int) -> String in
      return ds[section].model
    }
    return dataSource
  }
}
