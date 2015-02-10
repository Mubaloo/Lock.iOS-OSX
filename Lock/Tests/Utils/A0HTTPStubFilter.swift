// A0HTTPStubFilter.swift
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

class A0HTTPStubFilter: NSObject {

    let application: A0Application

    init(application: A0Application) {
        self.application = application;
    }

    func filterForResourceOwnerWithUsername(username: String, password: String) -> ((NSURLRequest) -> Bool) {
        return filterForResourceOwnerWithParameters([
                "username": username,
                "password": password,
                "scope": "openid offline_access",
                "grant_type": "password",
                "client_id": self.application.identifier,
                "connection": self.application.databaseStrategy.connections.first!.name
            ])
    }

    func filterForResourceOwnerWithParameters(parameters: [String: String]) -> ((NSURLRequest) -> Bool) {
        return filter("/oauth/ro", method: "POST", parameters: parameters)
    }

    func filterForTokenInfoWithJWT(jwt: String) -> ((NSURLRequest) -> Bool) {
        return filter("/tokeninfo", method: "POST", parameters: ["id_token": jwt])
    }

    func filterForSignUpWithParameters(parameters: [String: String]) -> ((NSURLRequest) -> Bool) {
        return filter("/dbconnections/signup", method: "POST", parameters: parameters)
    }

    func filterForChangePasswordWithParameters(parameters: [String: String]) -> ((NSURLRequest) -> Bool) {
        return filter("/dbconnections/change_password", method: "POST", parameters: parameters)
    }

    func filterForSocialAuthenticationWithParameters(parameters: [String: String]) -> ((NSURLRequest) -> Bool) {
        return filter("/oauth/access_token", method: "POST", parameters: parameters)
    }

    func filterForDelegationWithParameters(parameters: [String: String]) -> ((NSURLRequest) -> Bool) {
        return filter("/delegation", method: "POST", parameters: parameters)
    }

    private func filter(path: String, method: String, parameters: [String: String]) -> ((NSURLRequest) -> Bool) {
        return { (request) in
            let dictionary = NSURLProtocol.propertyForKey("parameters", inRequest: request) as NSDictionary
            let keys = parameters.keys.array as [AnyObject]
            return request.HTTPMethod! == method
                && request.URL.path! == path
                && parameters as NSDictionary == dictionary.dictionaryWithValuesForKeys(keys)
        }
    }
}