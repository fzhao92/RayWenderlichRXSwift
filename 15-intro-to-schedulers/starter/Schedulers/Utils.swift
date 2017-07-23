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

import Foundation
import RxSwift

let start = Date()

fileprivate func getThreadName() -> String {
  if Thread.current.isMainThread {
    return "Main Thread"
  } else if let name = Thread.current.name {
    if name == "" {
      return "Anonymous Thread"
    }
    return name
  } else {
    return "Unknown Thread"
  }
}

fileprivate func secondsElapsed() -> String {
  return String(format: "%02i", Int(Date().timeIntervalSince(start).rounded()))
}

extension ObservableType {
  func dump() -> RxSwift.Observable<Self.E> {
    return self.do(onNext: { element in
      let threadName = getThreadName()
      print("\(secondsElapsed())s | [D] \(element) received on \(threadName)")
    })
  }
  
  func dumpingSubscription() -> Disposable {
    return self.subscribe(onNext: { element in
      let threadName = getThreadName()
      print("\(secondsElapsed())s | [S] \(element) received on \(threadName)")
    })
  }
}