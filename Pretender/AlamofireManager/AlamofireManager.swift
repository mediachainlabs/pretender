//
// Created by Yusef Napora on 3/26/15.
// Copyright (c) 2015 Mine. All rights reserved.
//

import Foundation
import Alamofire

public struct RequestURLProtocolKeys {
  public static let Parameters = "parameters"
  public static let HTTPBody = "HTTPBody"
}


public class AlamofireManager : Alamofire.Manager {

  public override func request(method: Alamofire.Method, _ URLString: Alamofire.URLStringConvertible, parameters: [String: AnyObject]? = nil, encoding: ParameterEncoding = .URL) -> Request {

    let req = NSMutableURLRequest(URL: NSURL(string: URLString.URLString)!)
    req.HTTPMethod = method.rawValue

    if let params = parameters {
      NSURLProtocol.setProperty(params, forKey: RequestURLProtocolKeys.Parameters, inRequest: req)
    }
    return self.request(encoding.encode(req, parameters: parameters).0)
  }

  public override func request(URLRequest: URLRequestConvertible) -> Request {
    var req = URLRequest.URLRequest.mutableCopy() as! NSMutableURLRequest
    if let body = req.HTTPBody {
      NSURLProtocol.setProperty(body, forKey: RequestURLProtocolKeys.HTTPBody, inRequest: req)
    }

    return super.request(req)
  }
}

public extension NSURLRequest {
  var pretender_HTTPBody: NSData {
    let data = NSURLProtocol.propertyForKey(RequestURLProtocolKeys.HTTPBody, inRequest: self) as? NSData
    return data ?? NSData()
  }

  var pretender_parameters: [String:AnyObject] {
    let params = NSURLProtocol.propertyForKey(RequestURLProtocolKeys.Parameters, inRequest: self) as? [String:AnyObject]
    return params ?? [:]
  }
}

public extension NSMutableURLRequest {
  override var pretender_HTTPBody: NSData {
    get { return super.pretender_HTTPBody }
    set(val) { NSURLProtocol.setProperty(val, forKey: RequestURLProtocolKeys.HTTPBody, inRequest: self) }
  }

  override var pretender_parameters: [String:AnyObject] {
    get { return super.pretender_parameters }
    set(params) { NSURLProtocol.setProperty(params, forKey: RequestURLProtocolKeys.Parameters, inRequest: self) }
  }
}