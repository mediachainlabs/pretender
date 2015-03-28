//
// Created by Yusef Napora on 3/27/15.
// Copyright (c) 2015 Mine. All rights reserved.
//

import Foundation

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
