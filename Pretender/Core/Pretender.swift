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


private func logStub(stub: OHHTTPStubsDescriptor, request: NSURLRequest) {
  if let url = request.URL?.absoluteString {
    println("request for \(url) replaced with \(stub.name)")
  }
}

public class PretendServer {
  private struct Static {
    static var TeardownOnDeinit = true
  }

  public class var TeardownOnDeinit: Bool {
    get { return Static.TeardownOnDeinit }
    set(v) { Static.TeardownOnDeinit = v }
  }

  public let baseURL: NSURL
  var stubs: [OHHTTPStubsDescriptor] = []

  public init(baseURL: URLStringConvertible, setupClosure: (PretendServer -> ())? = nil) {
    self.baseURL = NSURL(string: baseURL.URLString)!
    if let setupClosure = setupClosure {
      setupClosure(self)
    }
  }

  deinit {
    if PretendServer.TeardownOnDeinit {
      teardown()
    }
  }

  public func teardown() {
    for stub in stubs {
      OHHTTPStubs.removeStub(stub)
    }
    stubs = []
  }

  public func logAllStubs() {
    OHHTTPStubs.onStubActivation { [weak self] request, stub in
      if let this = self {
        if this.containsStub(stub) {
          logStub(stub, request)
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

  public func put(path: String, response: ResponseBlock) {
    stubRequest("PUT", path: path, response: response)
  }

  public func patch(path: String, response: ResponseBlock) {
    stubRequest("PATCH", path: path, response: response)
  }

  public func delete(path: String, response: ResponseBlock) {
    stubRequest("DELETE", path: path, response: response)
  }

  public func head(path: String, response: ResponseBlock) {
    stubRequest("HEAD", path: path, response: response)
  }
}