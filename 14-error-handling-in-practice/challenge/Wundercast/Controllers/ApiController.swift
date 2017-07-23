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
import RxCocoa
import SwiftyJSON
import MapKit

class ApiController {

  /// The shared instance
  static var shared = ApiController()

  /// The api key to communicate with openweathermap.org
  /// Create you own on https://home.openweathermap.org/users/sign_up
  let apiKey = BehaviorSubject(value: "[YOUR KEY]")

  /// API base URL
  let baseURL = URL(string: "http://api.openweathermap.org/data/2.5")!

  init() {
    Logging.URLRequests = { request in
      return true
    }
  }

  enum ApiError: Error {
    case cityNotFound
    case serverFailure
    case invalidKey
  }

  //MARK: - Api Calls

  func currentWeather(city: String) -> Observable<Weather> {
    return buildRequest(pathComponent: "weather", params: [("q", city)]).map() { json in
      return Weather(
        cityName: json["name"].string ?? "Unknown",
        temperature: json["main"]["temp"].int ?? -1000,
        humidity: json["main"]["humidity"].int  ?? 0,
        icon: iconNameToChar(icon: json["weather"][0]["icon"].string ?? "e"),
        lat: json["coord"]["lat"].double ?? 0,
        lon: json["coord"]["lon"].double ?? 0
      )
    }
  }

  func currentWeather(lat: Double, lon: Double) -> Observable<Weather> {
    return buildRequest(pathComponent: "weather", params: [("lat", "\(lat)"), ("lon", "\(lon)")]).map() { json in
      return Weather(
        cityName: json["name"].string ?? "Unknown",
        temperature: json["main"]["temp"].int ?? -1000,
        humidity: json["main"]["humidity"].int  ?? 0,
        icon: iconNameToChar(icon: json["weather"][0]["icon"].string ?? "e"),
        lat: json["coord"]["lat"].double ?? 0,
        lon: json["coord"]["lon"].double ?? 0
      )
    }
  }

  //MARK: - Private Methods

  /**
   * Private method to build a request with RxCocoa
   */
  private func buildRequest(method: String = "GET", pathComponent: String, params: [(String, String)]) -> Observable<JSON> {

    let request: Observable<URLRequest> = Observable.create() { observer in
      let url = self.baseURL.appendingPathComponent(pathComponent)
      var request = URLRequest(url: url)
      let keyQueryItem = URLQueryItem(name: "appid", value: try? self.apiKey.value())
      let unitsQueryItem = URLQueryItem(name: "units", value: "metric")
      let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!

      if method == "GET" {
        var queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
        queryItems.append(keyQueryItem)
        queryItems.append(unitsQueryItem)
        urlComponents.queryItems = queryItems
      } else {
        urlComponents.queryItems = [keyQueryItem, unitsQueryItem]

        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        request.httpBody = jsonData
      }

      request.url = urlComponents.url!
      request.httpMethod = method

      request.setValue("application/json", forHTTPHeaderField: "Content-Type")

      observer.onNext(request)
      observer.onCompleted()

      return Disposables.create()
    }

    let session = URLSession.shared
    return request.flatMap() { request in
      return session.rx.response(request: request).map() { response, data in
        if 200 ..< 300 ~= response.statusCode {
          return JSON(data: data)
        } else if response.statusCode == 401 {
          throw ApiError.invalidKey
        } else if 400 ..< 500 ~= response.statusCode {
          throw ApiError.cityNotFound
        } else {
          throw ApiError.serverFailure
        }
      }
    }
  }

  struct Weather {
    let cityName: String
    let temperature: Int
    let humidity: Int
    let icon: String
    let lat: Double
    let lon: Double

    static let empty = Weather(
      cityName: "Unknown",
      temperature: -1000,
      humidity: 0,
      icon: iconNameToChar(icon: "e"),
      lat: 0,
      lon: 0
    )

    var coordinate: CLLocationCoordinate2D {
      return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

  }

}

/**
 * Maps an icon information from the API to a local char
 * Source: http://openweathermap.org/weather-conditions
 */
func iconNameToChar(icon: String) -> String {
  switch icon {
  case "01d":
    return "\u{f11b}"
  case "01n":
    return "\u{f110}"
  case "02d":
    return "\u{f112}"
  case "02n":
    return "\u{f104}"
  case "03d", "03n":
    return "\u{f111}"
  case "04d", "04n":
    return "\u{f111}"
  case "09d", "09n":
    return "\u{f116}"
  case "10d", "10n":
    return "\u{f113}"
  case "11d", "11n":
    return "\u{f10d}"
  case "13d", "13n":
    return "\u{f119}"
  case "50d", "50n":
    return "\u{f10e}"
  default:
    return "E"
  }
}
