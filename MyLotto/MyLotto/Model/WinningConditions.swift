//
//  WinningConditions.swift
//  MyLotto
//
//  Created by Andre Heß on 17/04/16.
//  Copyright © 2016 Andre Heß. All rights reserved.
//

import UIKit

class WinningConditions: NSObject {
	var winningNumbers:NSInteger
	var needsSuperZahl:Bool
	var needsZusatzZahl:Bool
	
	override init() {
		self.winningNumbers = 0
		self.needsSuperZahl = false
		self.needsZusatzZahl = false
	}
}
