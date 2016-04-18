//
//  HTTPManager.swift
//  MyLotto
//
//  Created by Andre Heß on 18/04/16.
//  Copyright © 2016 Andre Heß. All rights reserved.
//

import UIKit

typealias RequestCompletion = (NSError?, AnyObject?) -> (Void)
typealias RequestProgress = (NSProgress) -> (Void)

class HTTPManager: NSObject {
	
	var sessionManager:AFHTTPSessionManager
	let lottoBasePath:NSString = "https://www.lotto.de/bin/"
	
	static func sharedManager() -> HTTPManager {
		let me = HTTPManager()
		return me
	}
	
	override init() {
		self.sessionManager = AFHTTPSessionManager(baseURL: NSURL(string: self.lottoBasePath as String))
		super.init()
		self.configureSessionManager()
	}
	
	func configureSessionManager() {
		self.configureRequestSerializer()
		self.configureResponseSerializer()
	}
	
	func configureRequestSerializer() {
		let requestSerializer = AFHTTPRequestSerializer()
		self.sessionManager.requestSerializer = requestSerializer
	}
	
	func configureResponseSerializer() {
		let responseSerializer = AFHTTPResponseSerializer()
		self.sessionManager.responseSerializer = responseSerializer
	}
	
	func GET(urlString:NSString, parameters:NSDictionary, progress:RequestProgress?, completion:RequestCompletion?) {
		self.sessionManager.GET(urlString as String,
		                        parameters: parameters,
		                        progress: { (downloadProgress:NSProgress) in
									if (progress != nil) {
										progress!(downloadProgress)
									}
			},
		                        success: { (task:NSURLSessionDataTask, responseObject:AnyObject?) in
									if (completion != nil) {
										completion!(nil, responseObject)
									}
			},
		                        failure: { (task:NSURLSessionDataTask?, error:NSError) in
									if (completion != nil) {
										completion!(error, nil)
									}
		})
	}
}
