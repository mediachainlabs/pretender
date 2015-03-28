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


public typealias ResponseBlock = NSURLRequest -> PretendResponse
public typealias RequestParams = [String: AnyObject]



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
          } } } }
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