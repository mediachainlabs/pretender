//
//  URLStringConvertible.swift
//  Pretender
//
//  Created by Yusef Napora on 3/27/15.
//  Copyright (c) 2015 Mine. All rights reserved.
//

import Foundation

// Blatantly stolen from Alamofire.swift
// Included here to avoid the 'Core' of Pretender from depending on Alamofire

/**
Types adopting the `URLStringConvertible` protocol can be used to construct URL strings, which are then used to construct URL requests.
*/
public protocol URLStringConvertible {
  /// The URL string.
  var URLString: String { get }
}

extension String: URLStringConvertible {
  public var URLString: String {
    return self
  }
}

extension NSURL: URLStringConvertible {
  public var URLString: String {
    return absoluteString!
  }
}

extension NSURLComponents: URLStringConvertible {
  public var URLString: String {
    return URL!.URLString
  }
}

extension NSURLRequest: URLStringConvertible {
  public var URLString: String {
    return URL.URLString
  }
}