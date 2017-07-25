//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift



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
example(of: "ignoreElements") { 
  //1
  let strikes = PublishSubject<String>()
  
  let disposeBag = DisposeBag()
  
  //2
  strikes
    .ignoreElements()
    .subscribe { _ in
      print("You're out!")
    }
    .addDisposableTo(disposeBag)
  
  strikes.onNext("X")
  strikes.onNext("X")
  
  
  strikes.onCompleted()
  
}


example(of: "elementAt") {
  // 1
  let strikes = PublishSubject<String>()
  let disposeBag = DisposeBag()
  // 2
  strikes
    .elementAt(2)
    .subscribe(onNext: { _ in
      print("You're out!")
    })
    .addDisposableTo(disposeBag)
}

example(of: "filter") { 
  
  let disposeBag = DisposeBag()
  
  //1
  Observable.of(1, 2, 3, 4, 5, 6)
    // 2
    .filter({ (integer) -> Bool in
      integer % 2 == 0
    })
    //3
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
  
}

example(of: "skip") {
  
  let disposeBag = DisposeBag()
  // 1
  Observable.of("A", "B", "C", "D", "E", "F")
    // 2
    .skip(3)
    .subscribe(onNext: {
      print($0) })
    .addDisposableTo(disposeBag)
  
}

example(of: "skipWhile") {
  let disposeBag = DisposeBag()
  // 1
  Observable.of(2, 2, 3, 4, 4)
    // 2
    .skipWhile { integer in
      integer % 2 == 0
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}

example(of: "skipUntil") { 
  
  let disposeBag = DisposeBag()
  
  //1
  let subject = PublishSubject<String>()
  let trigger = PublishSubject<String>()
  
  //2
  subject
    .skipUntil(trigger)
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
  
  
  subject.onNext("A")
  subject.onNext("B")
  
  trigger.onNext("X")
  
  subject.onNext("C")
  
}


