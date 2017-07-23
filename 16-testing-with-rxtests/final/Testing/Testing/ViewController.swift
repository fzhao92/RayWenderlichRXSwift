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

import UIKit
import RxSwift
import RxCocoa

class ViewController : UIViewController {

  @IBOutlet weak var hexTextField: UITextField!
  @IBOutlet weak var rgbTextField: UITextField!
  @IBOutlet weak var colorNameTextField: UITextField!

  @IBOutlet var textFields: [UITextField]!

  @IBOutlet weak var zeroButton: UIButton!
  @IBOutlet var buttons: [UIButton]!

  let disposeBag = DisposeBag()
  let viewModel = ViewModel()

  let backgroundColor = PublishSubject<UIColor>()

  override func viewDidLoad() {
    super.viewDidLoad()

    configureUI()

    guard let textField = self.hexTextField else { return }

    textField.rx.text.orEmpty
      .bind(to: viewModel.hexString)
      .disposed(by: disposeBag)

    for button in buttons {
      button.rx.tap
        .bind {
          var shouldUpdate = false

          switch button.titleLabel!.text! {
          case "⊗":
            textField.text = "#"
            shouldUpdate = true
          case "←" where textField.text!.characters.count > 1:
            textField.text = String(textField.text!.characters.dropLast())
            shouldUpdate = true
          case "←":
            break
          case _ where textField.text!.characters.count < 7:
            textField.text!.append(button.titleLabel!.text!)
            shouldUpdate = true
          default:
            break
          }

          if shouldUpdate {
            textField.sendActions(for: .valueChanged)
          }
        }
        .addDisposableTo(self.disposeBag)
    }

    viewModel.color
      .drive(onNext: { [unowned self] color in
        UIView.animate(withDuration: 0.2) {
          self.view.backgroundColor = color
        }
      })
      .disposed(by: disposeBag)

    viewModel.rgb
      .map { "\($0.0), \($0.1), \($0.2)" }
      .drive(rgbTextField.rx.text)
      .disposed(by: disposeBag)

    viewModel.colorName
      .drive(colorNameTextField.rx.text)
      .disposed(by: disposeBag)
  }

  func configureUI() {
    textFields.forEach {
      $0.layer.shadowOpacity = 1.0
      $0.layer.shadowRadius = 0.0
      $0.layer.shadowColor = UIColor.lightGray.cgColor
      $0.layer.shadowOffset = CGSize(width: -1, height: -1)
    }
  }
}
