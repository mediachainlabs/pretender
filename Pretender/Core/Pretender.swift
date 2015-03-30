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


//public typealias ResponseBlock = (request: NSURLRequest, params: RequestParams) -> PretendResponse
public typealias ResponseBlock = (request: NSURLRequest, params: RequestParams) -> PretendResponse

public typealias RequestParams = [String: AnyObject]


public class PretendServer {
  public class ServerSetup {
    let baseURL: NSURL
    var stubs: [OHHTTPStubsDescriptor] = []

    public init(baseURL: NSURL) {
      self.baseURL = baseURL
    }

    private func stubRequest(method: String, path: String, response: ResponseBlock) {
      let stubURL = baseURL.URLByAppendingPathComponent(path)
      let testFn = test(Match.scheme(baseURL), Match.host(baseURL), Match.method(method), Match.path(stubURL))
      let responseBlock = stubResponse(response, stubURL: stubURL)

      let stub = OHHTTPStubs.stubRequestsPassingTest(testFn, withStubResponse:responseBlock)
      stub.name = "Stub for \(method): \"\(path)\""
      stubs.append(stub)
    }

    public func get(path: String, response: ResponseBlock) {
      stubRequest("GET", path: path, response: response)
    }

    public func post(path: String, response: ResponseBlock) {
      stubRequest("POST", path: path, response: response)
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
          if let url = request.URL?.absoluteString {
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