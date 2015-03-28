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

  
  static func path(baseURL: NSURL)(path:String)(request: NSURLRequest) -> Bool {
    let testURL = baseURL.URLByAppendingPathComponent(path)
    if let reqPath = (request.URL.path as NSString?) {
      return reqPath == testURL.path!
    }
    return false
  }

}


internal func test(testArray: [(NSURLRequest -> Bool)]) -> OHHTTPStubsTestBlock {
  return {request in
    testArray.reduce(true) { accum, test in accum && test(request) }
  }
}


internal func test(tests: (NSURLRequest -> Bool)...) -> OHHTTPStubsTestBlock {
  return test(tests)
}

internal func stubResponse(responder: ResponseBlock) -> OHHTTPStubsResponseBlock {
  return { request in
    let response = responder(request)
    return OHHTTPStubsResponse(data: response.data, statusCode: response.statusCode, headers: response.headers)
  }
}