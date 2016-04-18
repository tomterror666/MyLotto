//
//  LottoDaysProvider.swift
//  MyLotto
//
//  Created by Andre Heß on 18/04/16.
//  Copyright © 2016 Andre Heß. All rights reserved.
//

import UIKit

typealias LottoDaysCompletion = (Void) -> (NSArray)

class LottoDaysProvider: NSObject {
	
	var allLottoDays:NSMutableDictionary
	var httpManager:HTTPManager
	
	static func sharedProvider() -> LottoDaysProvider {
		let me = LottoDaysProvider()
		return me
	}
	
	override init() {
		self.allLottoDays = NSMutableDictionary()
		self.httpManager = HTTPManager.sharedManager()
		super.init()
	}
	
	func loadLottoDaysSinceDate(date:NSDate, completion:LottoDaysCompletion) {
		//todo: gehe liste der jahre durch und wenn noch nicht geladen, dann pack laderequest auf nsoperationqueue
		// sind alle laderequests fertig (operationaueue ist leer) oder wurden alle jahre gefunden, dann gehe diese liste nochmals durch und bilde result
	}

}
