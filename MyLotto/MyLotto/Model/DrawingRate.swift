//
//  DrawingRate.swift
//  MyLotto
//
//  Created by Andre Heß on 17/04/16.
//  Copyright © 2016 Andre Heß. All rights reserved.
//

import UIKit

class DrawingRate: NSObject {
	var possibleWin:CGFloat
	var drawingRateDescription:NSString
	var drawingRateShortDescription:NSString
	var classNumber:NSInteger
	var winningConditions:WinningConditions
	
	static func drawingRateWithJsonDict(jsonDict jsonDict:NSDictionary, drawingType:DrawingType) -> DrawingRate {
		let me:DrawingRate = DrawingRate(jsonDict: jsonDict, drawingType: drawingType)
		return me
	}
	
	init(jsonDict:NSDictionary, drawingType:DrawingType) {
		self.possibleWin = jsonDict.objectForKey("quote") as! CGFloat
		self.drawingRateDescription = jsonDict.objectForKey("beschreibung") as! NSString
		self.drawingRateShortDescription = jsonDict.objectForKey("kurzbeschreibung") as! NSString
		self.classNumber = jsonDict.objectForKey("klasse") as! NSInteger
		self.winningConditions = WinningConditions()
		super.init()
		self.calcWinningConditinoForDrawingType(drawingType)
	}
	
	func calcWinningConditinoForDrawingType(drawingType:DrawingType) {
		if (drawingType == DrawingType.drawingTypeSuperZahl) {
			self.winningConditions.needsSuperZahl = self.classNumber % 2 == 1
			self.winningConditions.needsZusatzZahl = false
			self.winningConditions.winningNumbers = 6 - (self.classNumber - 1) / 2
		}
		else if (drawingType == DrawingType.drawingTypeZusatzZahl) {
			self.winningConditions.needsZusatzZahl = self.classNumber % 2 == 0
			self.winningConditions.needsSuperZahl = false
			self.winningConditions.winningNumbers = 6 - self.classNumber / 2
		}
		else if (drawingType == DrawingType.drawingTypeZusatzZahlUndSuperZahl) {
			if (self.classNumber == 1) {
				self.winningConditions.needsSuperZahl = true
				self.winningConditions.needsZusatzZahl = false
				self.winningConditions.winningNumbers = 6
			} else {
				self.winningConditions.needsZusatzZahl = self.classNumber % 2 == 0
				self.winningConditions.needsSuperZahl = false
				self.winningConditions.winningNumbers = 6 - self.classNumber / 2
			}
		}
		else {
			self.winningConditions.needsSuperZahl = false
			self.winningConditions.needsZusatzZahl = false
			self.winningConditions.winningNumbers = NSInteger(INT32_MAX)
		}
	}
}
