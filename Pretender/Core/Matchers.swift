//
// Created by Yusef Napora on 3/27/15.
// Copyright (c) 2015 Mine. All rights reserved.
//

import Foundation
import OHHTTPStubs

internal struct Match {
  static func scheme(url: NSURL)(request: NSURLRequest) -> Bool {
    if let scheme = url.scheme {
      if let reqScheme = (request.URL.scheme as NSString?) {
        return reqScheme == scheme
      }
    }
    return false
  }

  static func host(url: NSURL)(request: NSURLRequest) -> Bool {
    if let host = url.host {
      if let reqHost = (request.URL.host as NSString?) {
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
    let pathParams = pathParameters(requestURL: request.URL, stubURL: stubURL)
    return pathParams != nil
  }

}


// Accepts two String arrays of path segments for a
// request URL and a stub URL which may contain :params
// returns an optional dictionary of parameter names to values
// If the stub URL is not a match for the request URL, return nil
internal func pathParameters(#requestURL: NSURL, #stubURL: NSURL) -> [String:String]? {
  if requestURL.pathComponents == nil || stubURL.pathComponents == nil {
    return nil
  }
  let requestPathSegments = requestURL.pathComponents! as [String]
  let stubPathSegments = stubURL.pathComponents! as [String]
  if requestPathSegments.count != stubPathSegments.count { return nil }

  var params = [String:String]()

  for (reqSeg, stubSeg) in Zip2(requestPathSegments, stubPathSegments) {
    if stubSeg.hasPrefix(":") && countElements(stubSeg) > 1 {
      let paramName = stubSeg[advance(stubSeg.startIndex,1) ..< stubSeg.endIndex]
      params[paramName] = reqSeg
    } else if stubSeg != reqSeg {
      return nil
    }
  }
  return params
}


internal func test(testArray: [(NSURLRequest -> Bool)]) -> OHHTTPStubsTestBlock {
  return {request in
    testArray.reduce(true) { accum, test in accum && test(request) }
  }
}


internal func test(tests: (NSURLRequest -> Bool)...) -> OHHTTPStubsTestBlock {
  return test(tests)
}

