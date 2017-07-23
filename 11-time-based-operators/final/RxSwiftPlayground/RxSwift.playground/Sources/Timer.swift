import Foundation

public extension DispatchSource {
  public class func timer(interval: Double, queue: DispatchQueue, handler: @escaping () -> Void) -> DispatchSourceTimer {
    let source = DispatchSource.makeTimerSource(queue: queue)
    source.setEventHandler(handler: handler)
    source.scheduleRepeating(deadline: .now(), interval: interval, leeway: .nanoseconds(0))
    source.resume()
    return source
  }
}
