//
// Created by Yusef Napora on 3/26/15.
// Copyright (c) 2015 Mine. All rights reserved.
//

import Foundation
import Alamofire

let kParametersKey = "parameters"
let kBodyKey = "HTTPBody"

public class AlamofireManager : Alamofire.Manager {

  public override func request(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String: AnyObject]? = nil, encoding: ParameterEncoding = .URL) -> Request {

    let req = NSMutableURLRequest(URL: NSURL(string: URLString.URLString)!)
    req.HTTPMethod = method.rawValue

    if let params = parameters {
      NSURLProtocol.setProperty(params, forKey: kParametersKey, inRequest: req)
    }
    return self.request(encoding.encode(req, parameters: parameters).0)
  }

  public override func request(URLRequest: URLRequestConvertible) -> Request {
    var req = URLRequest.URLRequest.mutableCopy() as NSMutableURLRequest
    if let body = req.HTTPBody {
      NSURLProtocol.setProperty(body, forKey: kBodyKey, inRequest: req)
    }

    return super.request(req)
  }
}

public extension NSURLRequest {
  var pretender_HTTPBody: NSData? {
    return NSURLProtocol.propertyForKey(kBodyKey, inRequest: self) as NSData?
  }

  var pretender_parameters: [String:AnyObject]? {
    return NSURLProtocol.propertyForKey(kParametersKey, inRequest: self) as [String:AnyObject]?
  }
}