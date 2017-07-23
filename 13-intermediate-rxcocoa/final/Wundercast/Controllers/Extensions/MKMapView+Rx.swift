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
import MapKit
import RxSwift
import RxCocoa

class RxMKMapViewDelegateProxy: DelegateProxy, MKMapViewDelegate, DelegateProxyType {
  class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
    let mapView: MKMapView = (object as? MKMapView)!
    return mapView.delegate
  }

  class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
    let mapView: MKMapView = (object as? MKMapView)!
    mapView.delegate = delegate as? MKMapViewDelegate
  }
}

extension Reactive where Base: MKMapView {
  public var delegate: DelegateProxy {
    return RxMKMapViewDelegateProxy.proxyForObject(base)
  }

  public func setDelegate(_ delegate: MKMapViewDelegate) -> Disposable {
    return RxMKMapViewDelegateProxy.installForwardDelegate(
      delegate,
      retainDelegate: false,
      onProxyForObject: self.base
    )
  }

  var overlays: UIBindingObserver<Base, [MKOverlay]> {
    return UIBindingObserver(UIElement: self.base) { mapView, overlays in
      mapView.removeOverlays(mapView.overlays)
      mapView.addOverlays(overlays)
    }
  }

  public var regionDidChangeAnimated: ControlEvent<Bool> {
    let source = delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
      .map { parameters in
        return (parameters[1] as? Bool) ?? false
      }
    return ControlEvent(events: source)
  }
}
