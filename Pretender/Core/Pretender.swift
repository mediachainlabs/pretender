//
//  Pretender.swift
//  Mine
//
//  Created by Yusef Napora on 3/26/15.
//  Copyright (c) 2015 Mine. All rights reserved.
//

import Foundation
import OHHTTPStubs
import SwiftyJSON

public class PretendResponse {
  let data: NSData
  let statusCode: Int32
  let headers: [String:AnyObject]

  public init(data: NSData, statusCode: Int = 200, headers: [String:AnyObject] = [:]) {
    self.data = data
    self.statusCode = Int32(statusCode)
    self.headers = headers
  }

  public convenience init(string: String, statusCode: Int = 200, headers: [String:AnyObject] = [:]) {
    let data = string.dataUsingEncoding(NSUTF8StringEncoding)
    assert(data != nil, "Can't get UTF8 data from string \(string)")
    self.init(data: data!, statusCode: statusCode, headers: headers)
  }

  public convenience init(json: JSON, statusCode: Int = 200, headers: [String:AnyObject] = [:]) {
    let data = json.rawData()
    assert(data != nil, "Can't get raw data for pretend JSON response")
    self.init(data: data!, statusCode: statusCode, headers: headers)
  }
}

public class FixtureResponse: PretendResponse {
  private struct Static {
    static var bundleClass: AnyClass?
  }

  public class var bundleClass: AnyClass? {
    get { return Static.bundleClass }
    set(c) { Static.bundleClass = c }
  }

  public init(_ file: String, inBundleForClass bundleClass:AnyClass? = nil, statusCode: Int = 200, headers: [String:AnyObject] = [:]) {
    let actualBundleClass: AnyClass? = bundleClass ?? FixtureResponse.bundleClass
    assert(actualBundleClass != nil, "Can't determine which bundle to load fixtures from.  Either use `inBundleForClass:` param, or set FixtureResponse.bundleClass before use.")
    let bundle = NSBundle(forClass: actualBundleClass!)

    var fileExtension:String?
    if file.pathExtension == "" { fileExtension = "json" }

    let url = bundle.URLForResource(file, withExtension: fileExtension)
    assert(url != nil, "Unable to find fixture file \(file) in bundle: \(bundle)")
    let data = NSData(contentsOfURL: url!)
    assert(data != nil, "Unable to read data from fixture file at \(url!) in bundle: \(bundle)")
    super.init(data: data!, statusCode: statusCode, headers: headers)
  }

}


public typealias ResponseBlock = NSURLRequest -> PretendResponse

public typealias RequestParams = [String: AnyObject]

struct Match {
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

  static func path(baseURL: NSURL)(path:String)(request: NSURLRequest) -> Bool {
    let testURL = baseURL.URLByAppendingPathComponent(path)
    if let reqPath = (request.URL.path as NSString?) {
      return reqPath == testURL.path!
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
}


private func test(testArray: [(NSURLRequest -> Bool)]) -> OHHTTPStubsTestBlock {
  return {request in
    testArray.reduce(true) { accum, test in accum && test(request) }
  }
}


private func test(tests: (NSURLRequest -> Bool)...) -> OHHTTPStubsTestBlock {
  return test(tests)
}

private func stubResponse(responder: ResponseBlock) -> OHHTTPStubsResponseBlock {
  return { request in
    let response = responder(request)
    return OHHTTPStubsResponse(data: response.data, statusCode: response.statusCode, headers: response.headers)
  }
}

public class PretendServer {
  public class ServerSetup {
    let baseURL: NSURL
    var stubs: [OHHTTPStubsDescriptor] = []

    let baseMatchers: [(NSURLRequest -> Bool)]
    let pathMatcher: (String -> (NSURLRequest -> Bool))

    public init(baseURL: NSURL) {
      self.baseURL = baseURL
      baseMatchers = [Match.scheme(baseURL), Match.host(baseURL)]
      pathMatcher = Match.path(baseURL)
    }

    public func get(path: String, response: ResponseBlock) {
      let matchers = baseMatchers + [Match.method("GET"), pathMatcher(path)]
      let responseBlock = stubResponse(response)
      let stub = OHHTTPStubs.stubRequestsPassingTest(test(matchers), withStubResponse:responseBlock)
      stub.name = "GET stub for \"\(path)\""
      stubs.append(stub)
    }

    public func post(path: String, response: ResponseBlock) {
      let matchers = baseMatchers + [ Match.method("POST"), pathMatcher(path)]
      let responseBlock = stubResponse(response)
      var stub = OHHTTPStubs.stubRequestsPassingTest(test(matchers), withStubResponse: responseBlock)
      stub.name = "POST stub for \"\(path)\""
      stubs.append(stub)
    }
  }

  public let baseURL: NSURL
  var stubs: [OHHTTPStubsDescriptor] = []

  public init(baseURL: URLStringConvertible, setupClosure: (ServerSetup -> ())? = nil) {
    self.baseURL = NSURL(string: baseURL.URLString)!
    if let setupClosure = setupClosure {
      var server = ServerSetup(baseURL: self.baseURL)
      setupClosure(server)
      self.stubs = server.stubs
    }
  }

  deinit {
    teardown()
  }

  public func teardown() {
    for stub in stubs {
      OHHTTPStubs.removeStub(stub)
    }
    stubs = []
  }

  public func logAllStubs() {
    OHHTTPStubs.onStubActivation { [weak self] request, stub in
      if let s = self {
        if s.containsStub(stub) {
          if let url = request.URL.absoluteString {
            println("request for \(url) replaced with \(stub.name)")
          }
        }
      }
    }
  }

  private func containsStub(stub: OHHTTPStubsDescriptor) -> Bool {
    for s in stubs {
      if s.isEqual(stub) {
        return true
      }
    }
    return false
  }

}