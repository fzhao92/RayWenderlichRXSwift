//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift

example(of: "PublishSubject") {

  let disposeBag = DisposeBag()

  let dealtHand = PublishSubject<[(String, Int)]>()

  func deal(_ cardCount: UInt) {
    var deck = cards
    var cardsRemaining: UInt32 = 52
    var hand = [(String, Int)]()

    for _ in 0..<cardCount {
      let randomIndex = Int(arc4random_uniform(cardsRemaining))
      hand.append(deck[randomIndex])
      deck.remove(at: randomIndex)
      cardsRemaining -= 1
    }

    // Add code to update dealtHand here
    if points(for: hand) > 21 {
      dealtHand.onError(HandError.busted)
    } else {
      dealtHand.onNext(hand)
    }
  }

  // Add subscription to handSubject here
  dealtHand
    .subscribe(
      onNext: {
        print(cardString(for: $0), "for", points(for: $0), "points")
    },
      onError: {
        print(String(describing: $0).capitalized)
    })
    .disposed(by: disposeBag)

  deal(3)
}

/*:
 Copyright (c) 2014-2016 Razeware LLC

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */
