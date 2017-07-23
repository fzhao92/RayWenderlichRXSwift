//: Please build the scheme 'RxSwiftPlayground' first
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

import RxSwift

example(of: "Challenge 1 - solution using zip") {
  
  let source = Observable.of(1, 3, 5, 7, 9)
  
  let scanObservable = source.scan(0, accumulator: +)
  
  let observable = Observable.zip(source, scanObservable) { value, runningTotal in
    (value, runningTotal)
  }
  observable.subscribe(onNext: { tuple in
    print("Value = \(tuple.0)   Running total = \(tuple.1)")
  })
  
}

example(of: "Challenge 1 - solution using just scan and a tuple") {

  let source = Observable.of(1, 3, 5, 7, 9)
  
  let observable = source.scan((0,0)) { acc, current in
    return (current, acc.1 + current)
  }
  observable.subscribe(onNext: { tuple in
    print("Value = \(tuple.0)   Running total = \(tuple.1)")
  })

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
