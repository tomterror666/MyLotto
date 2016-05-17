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
		self.possibleWin = 0
		self.drawingRateDescription = ""
		self.drawingRateShortDescription = ""
		self.classNumber = 0
		self.winningConditions = WinningConditions()
		super.init()
		self.readDrawingRateFromDict(jsonDict)
		self.calcWinningConditinoForDrawingType(drawingType)
	}
	
	func readDrawingRateFromDict(jsonDict:NSDictionary) {
		self.readPossibleWinFromJsonDict(jsonDict)
		self.readDrawingRateDescriptionFromJsonDict(jsonDict)
		self.readDrawingRateShortDescriptionFromJsonDict(jsonDict)
		self.readClassNumberFromJsonDict(jsonDict)
	}
	
	func readPossibleWinFromJsonDict(jsonDict:NSDictionary) {
		if let stringValue = jsonDict.objectForKey("quote") {
			self.possibleWin = CGFloat(stringValue.floatValue)
		}
	}
	
	func readDrawingRateDescriptionFromJsonDict(jsonDict:NSDictionary) {
		if let stringValue = jsonDict.objectForKey("beschreibung") {
			self.drawingRateDescription = stringValue as! NSString
		}
	}
	
	func readDrawingRateShortDescriptionFromJsonDict(jsonDict:NSDictionary) {
		if let stringValue = jsonDict.objectForKey("kurzbeschreibung") {
			self.drawingRateShortDescription = stringValue as! NSString
		}
	}
	
	func readClassNumberFromJsonDict(jsonDict:NSDictionary) {
		if let stringValue = jsonDict.objectForKey("klasse") {
			self.classNumber = stringValue.integerValue
		}
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
