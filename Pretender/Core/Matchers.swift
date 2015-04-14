//
// Created by Yusef Napora on 3/27/15.
// Copyright (c) 2015 Mine. All rights reserved.
//

import Foundation
import OHHTTPStubs

internal struct Match {
  static func scheme(url: NSURL)(request: NSURLRequest) -> Bool {
    if let scheme = url.scheme {
      if let reqScheme = (request.URL?.scheme as NSString?) {
        return reqScheme == scheme
      }
    }
    return false
  }

  static func host(url: NSURL)(request: NSURLRequest) -> Bool {
    if let host = url.host {
      if let reqHost = (request.URL?.host as NSString?) {
        let equal = reqHost == host
        return reqHost == host
      }
    }
    return false
  }

  static func method(method: String)(request: NSURLRequest) -> Bool {
    if let reqMethod = (request.HTTPMethod as NSString?) {
      let equal = reqMethod == method.uppercaseString
      return equal
    }
    return false
  }


  static func path(stubURL: NSURL)(request: NSURLRequest) -> Bool {
    let matchResult = matchParameterizedPath(requestURL: request.URL, stubURL: stubURL)
    switch matchResult {
    case .Match: return true
    case .NoMatch: return false
    }
  }

}


enum PathMatchResult {
  case Match([String:AnyObject])
  case NoMatch
}

// Accepts two String arrays of path segments for a
// request URL and a stub URL which may contain :params
// returns a PathMatchResult indicating whether the paths
// of the request URLs match, including the parsed path
// parameters, if any
internal func matchParameterizedPath(#requestURL: NSURL?, #stubURL: NSURL) -> PathMatchResult {
  if requestURL?.pathComponents == nil || stubURL.pathComponents == nil {
    return .NoMatch
  }
  let requestPathSegments = requestURL!.pathComponents! as! [String]
  let stubPathSegments = stubURL.pathComponents! as! [String]
  if requestPathSegments.count != stubPathSegments.count { return .NoMatch }

  var params: [String:AnyObject] = [:]

  for (reqSeg, stubSeg) in Zip2(requestPathSegments, stubPathSegments) {
    if stubSeg.hasPrefix(":") && count(stubSeg) > 1 {
      let paramName = stubSeg[advance(stubSeg.startIndex,1) ..< stubSeg.endIndex]
      let value = reqSeg
      if let intValue = value.toInt() {
        params[paramName] = intValue
      } else {
        params[paramName] = value
      }
    } else if stubSeg != reqSeg {
      return .NoMatch
    }
  }
  return .Match(params)
}


internal func test(testArray: [(NSURLRequest -> Bool)]) -> OHHTTPStubsTestBlock {
  return {request in
    testArray.reduce(true) { accum, test in accum && test(request) }
  }
}


internal func test(tests: (NSURLRequest -> Bool)...) -> OHHTTPStubsTestBlock {
  return test(tests)
}

