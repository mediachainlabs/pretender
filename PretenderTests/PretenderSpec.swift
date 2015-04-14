//
// Created by Yusef Napora on 3/26/15.
// Copyright (c) 2015 Mine. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Alamofire
import Pretender


class PretenderSpec : QuickSpec {
  override func spec() {
    describe("Pretender") {
      let baseURL = "http://pretend.stub"
      var pretender: PretendServer!
      let manager = Alamofire.Manager(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
      
      describe("Stubs in setup block") {
        beforeEach {
          pretender = PretendServer(baseURL: baseURL) { server in
            server.get("thing1") { _ in PretendResponse(string: "Hello from thing1")}
            server.post("thing2") { _ in PretendResponse(string: "Nice thing2 you posted there") }
            server.get("nothing") { _ in PretendResponse(string: "Nothing to see here", statusCode: 404)}
          }
        }

        it("should stub GET requests for a given path") {
          var responseStr: String?
          manager.request(.GET, baseURL + "/thing1")
            .responseString({ (request, response, str, error) in responseStr = str })

          expect(responseStr).toEventually(equal("Hello from thing1"))
        }

        it("should stub POST requests for a given path") {
          var responseStr: String?
          manager.request(.POST, baseURL + "/thing2")
            .responseString({ (request, response, str, error) in responseStr = str })
          expect(responseStr).toEventually(equal("Nice thing2 you posted there"))
        }

        it("should return the provided status code") {
          var code: Int?
          manager.request(.GET, baseURL + "/nothing")
            .response { (request, response, str, error) in code = response?.statusCode }
          expect(code).toEventually(equal(404))
        }
      }

      describe("Request parameters") {
        beforeEach {
          pretender = PretendServer(baseURL: baseURL) { server in
            server.get("things/:id/colors") { request, params in
              let id: AnyObject = params["id"]!
              return PretendResponse(string: "This thing has an id of \(id)")
            }
            server.get("people/:id/roles/:role") { request, params in
              let (id: AnyObject!, role) = (params["id"]!, params["role"]! as! String)
              return PretendResponse(string: "Person #\(id) loves being a \(role)")
            }
            server.get("params-please") { request, params in
              PretendResponse(string: "Thanks for sending me these great parameters: \(params)")
            }
          }
        }
        
        it("should treat path segments beginning with ':' as wildcards") {
          var responseStr: String?
          manager.request(.GET, baseURL + "/things/100/colors")
            .responseString({ (request, response, str, error) in responseStr = str })
          expect(responseStr).toEventuallyNot(beNil())
        }
        
        it("should provide the values of parameterized path segments") {
          var responseStr: String?
          manager.request(.GET, baseURL + "/people/10/roles/walletinspector")
            .responseString({ (request, response, str, error) in responseStr = str })
          expect(responseStr).toEventually(equal("Person #10 loves being a walletinspector"))
        }
        
        it("should parse integers from parameterized path segments") {
          var intParam: Int?
          let p = PretendServer(baseURL: baseURL) { server in
            server.get("/ints/:int") { request, params in
              intParam = params["int"] as? Int
              return PretendResponse(string: "")
            }
          }
          manager.request(.GET, baseURL + "/ints/42")
          expect(intParam).toEventually(equal(42))
        }
        
        it("should return request parameters if they're associated with the request using NSURLProtocol") {
          var request = NSMutableURLRequest(URL: NSURL(string: baseURL + "/params-please")!)
          let params = ["ice": 9]
          NSURLProtocol.setProperty(params, forKey: RequestURLProtocolKeys.Parameters, inRequest: request)
          var responseStr: String?
          manager.request(request)
            .responseString({(request, response, str, error) in responseStr = str })
          expect(responseStr).toEventually(contain("ice"))
        }
        
      }
      
      describe("FixtureResponse") {
        describe ("Bundle class") {
          it ("should allow you to globally set the class for the bundle containing fixtures") {
            FixtureResponse.bundleClass = PretenderSpec.self
            let response = FixtureResponse("jsonresponse")
            expect("didn't assert") == "didn't assert"
            FixtureResponse.bundleClass = nil
          }

          // does what it says on the tin, so disabled with 'x' prefix
          xit("should assert if you don't set the bundle class either globally or in the initializer") {
            let response = FixtureResponse("jsonresponse")
            expect("to never get here") == "yep, we crashed"
          }
        }


        beforeEach {
          pretender = PretendServer(baseURL: baseURL) { server in
            server.get("json") { _ in FixtureResponse("jsonresponse", inBundleForClass: PretenderSpec.self) }
            server.get("text") { _ in FixtureResponse("stringresponse.txt", inBundleForClass: PretenderSpec.self) }
          }
        }

        it("should return the contents of a fixture file") {
          var responseStr: String?
          manager.request(.GET, baseURL + "/text")
            .responseString({ (request, response, str, error) in responseStr = str })
          expect(responseStr).toEventually(contain("Hello"))
        }

        it("should assume a '.json' file extension if none is provided") {
          var responseData: AnyObject?
          manager.request(.GET, baseURL + "/json")
            .responseJSON { (request, response, data, error) in responseData = data }
          expect(responseData).toEventuallyNot(beNil())
        }
      }

      describe("Alamofire Manager extension") {
        let manager = Pretender.AlamofireManager(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

        it("should include the request parameters automatically") {
          var requestParams: [String:AnyObject]?
          let pretender = PretendServer(baseURL: baseURL) { server in
            server.post("needsparams") { request, params in
              requestParams = params
              return PretendResponse(string: "")
            }
          }

          manager.request(.POST, "http://pretend.stub/needsparams", parameters: ["something": "foo"])
          expect(requestParams?["something"] as? String).toEventually(equal("foo"))
        }
      }
    }
  }
}
