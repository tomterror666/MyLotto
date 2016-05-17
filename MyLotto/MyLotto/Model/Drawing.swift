//
//  Drawing.swift
//  MyLotto
//
//  Created by Andre Heß on 17/04/16.
//  Copyright © 2016 Andre Heß. All rights reserved.
//

import UIKit

enum DrawingType: Int {
	case drawingTypeUnknown = 0
	case drawingTypeZusatzZahl
	case drawingTypeZusatzZahlUndSuperZahl
	case drawingTypeSuperZahl
}

class Drawing: NSObject {
	var drawingNumbers:NSArray!
	var year:NSInteger!
	var date:NSString!
	var zusatzZahl:NSInteger!
	var superZahl:NSInteger!
	var stake:CGFloat?
	var rates:NSArray!
	var wins:NSMutableArray!
	var drawingType:DrawingType!
	
	static func drawingWithJsonDictionary(jsonDict jsonDict:NSDictionary) -> Drawing {
		let me:Drawing = Drawing(jsonDict: jsonDict)
		return me
	}
	
	override var description : String {
		return self.drawingAsString() as String
	}
	
	init(jsonDict:NSDictionary) {
		self.drawingNumbers = NSArray()
		self.year = 0
		self.date = ""
		self.zusatzZahl = 0
		self.superZahl = 0
		self.stake = 0.0
		
		super.init()
		self.readDrawingFromDict(jsonDict)
		if let quotas = jsonDict.valueForKeyPath("lotto.quoten") {
			self.readRatesFromArray(quotas as! [NSDictionary])
		}
//		self.readRatesFromArray(jsonDict.valueForKeyPath("lotto.quoten") as! [NSDictionary])
		self.configureDrawingTypeWithJsonDict(jsonDict)
	}
	
	func readDrawingFromDict(jsonDict:NSDictionary) {
		self.readDrawingNumbersFromDict(jsonDict)
		self.readYearFromDict(jsonDict)
		self.readDateFromDict(jsonDict)
		self.readZusatzZahlFromDict(jsonDict)
		self.readSuperZahlFromDict(jsonDict)
		self.readStakeFromDict(jsonDict)
	}
	
	func readDrawingNumbersFromDict(jsonDict:NSDictionary) {
		if let stringValue = jsonDict.valueForKeyPath("lotto.gewinnzahlen") {
			self.drawingNumbers = stringValue as! NSArray
		}
	}
	
	func readYearFromDict(jsonDict:NSDictionary) {
		if let stringValue = jsonDict.valueForKeyPath("year") {
			self.year = stringValue.integerValue
		}
	}
	
	func readDateFromDict(jsonDict:NSDictionary) {
		if let stringValue = jsonDict.valueForKeyPath("date") {
			self.date = stringValue as! NSString
		}
	}
	
	func readZusatzZahlFromDict(jsonDict:NSDictionary) {
		if let stringValue = jsonDict.valueForKeyPath("lotto.zusatzzahl") {
			self.zusatzZahl = stringValue.integerValue
		}
	}
	
	func readSuperZahlFromDict(jsonDict:NSDictionary) {
		if let stringValue = jsonDict.valueForKeyPath("lotto.superzahl") {
			self.superZahl = stringValue.integerValue
		}
	}
	
	func readStakeFromDict(jsonDict:NSDictionary) {
//		if let stringValue = jsonDict.valueForKeyPath("lotto.spieleinsatz") {
//			self.stake = CGFloat(stringValue.floatValue)
//		}
		let stringValue = jsonDict.valueForKeyPath("lotto.spieleinsatz")
		if (stringValue != nil) {
			self.stake = CGFloat((stringValue?.floatValue)!)
		}
	}
	
	func readRatesFromArray(ratesArray:[NSDictionary]) {
		let resultRates:NSMutableArray = NSMutableArray()
		for rateDict:NSDictionary in ratesArray {
			let drawingtype:DrawingType = self.calctDrawingType()
			let drawingRate:DrawingRate = DrawingRate.drawingRateWithJsonDict(jsonDict: rateDict, drawingType: drawingtype)
			resultRates.addObject(drawingRate)
		}
		self.rates = resultRates.sortedArrayUsingComparator({ (obj1:AnyObject, obj2:AnyObject) -> NSComparisonResult in
			let drawingRateOne:DrawingRate = obj1 as! DrawingRate
			let drawingRateTwo:DrawingRate = obj2 as! DrawingRate
			return drawingRateOne.winningConditions.winningNumbers > drawingRateTwo.winningConditions.winningNumbers ? NSComparisonResult.OrderedAscending :  
				(drawingRateOne.winningConditions.winningNumbers < drawingRateTwo.winningConditions.winningNumbers ? NSComparisonResult.OrderedDescending : NSComparisonResult.OrderedSame)
			
		})
	}
	
	func configureDrawingTypeWithJsonDict(jsonDict:NSDictionary) {
		let superZahlNumber = jsonDict.valueForKeyPath("lotto.superzahl")
		let zusatzZahlNumber = jsonDict.valueForKeyPath("lotto.zusatzzahl")
		if ((zusatzZahlNumber != nil) && (superZahlNumber == nil)) {
			self.drawingType = DrawingType.drawingTypeZusatzZahl
		}
		else if ((zusatzZahlNumber == nil) && (superZahlNumber != nil)) {
			self.drawingType = DrawingType.drawingTypeSuperZahl
		}
		else if (zusatzZahlNumber != nil && superZahlNumber != nil) {
			self.drawingType = DrawingType.drawingTypeZusatzZahlUndSuperZahl
		}
		else {
			self.drawingType = DrawingType.drawingTypeUnknown
		}
	}
	
	func calctDrawingType() -> DrawingType {
		
		let formatter:NSDateFormatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		let drawingDate = formatter.dateFromString(self.date as String)!
		let beginOfLotto = formatter.dateFromString("1955-10-08")!
		let umstellungsDateZZSZ = formatter.dateFromString("1991-12-06")!
		let umstellungsDateSZ = formatter.dateFromString("2013-05-03")!
		if ((drawingDate.compare(beginOfLotto) == NSComparisonResult.OrderedDescending) && (drawingDate.compare(umstellungsDateZZSZ) == NSComparisonResult.OrderedAscending)) {
			return DrawingType.drawingTypeZusatzZahl;
		} else if ((drawingDate.compare(umstellungsDateZZSZ) == NSComparisonResult.OrderedDescending) && (drawingDate.compare(umstellungsDateSZ) == NSComparisonResult.OrderedAscending)) {
			return DrawingType.drawingTypeZusatzZahlUndSuperZahl;
		} else if (drawingDate.compare(umstellungsDateSZ) == NSComparisonResult.OrderedDescending) {
			return DrawingType.drawingTypeSuperZahl;
		}
		return DrawingType.drawingTypeUnknown
	}
	
	func addWinForGuess(guess:Guess) {
		let possibleWin = Win(guess: guess, drawing: self)
		if (possibleWin.winningDrawingRate != nil) {
			if (self.wins == nil) {
				self.wins = NSMutableArray(object: possibleWin)
			} else {
				self.wins.addObject(possibleWin)
			}
		}
	}
	
	func drawingAsString() -> NSString {
		if (self.drawingType == DrawingType.drawingTypeZusatzZahl) {
			return "Ziehung vom \(self.date): \(self.drawingNumbers[0]) - \(self.drawingNumbers[1]) - \(self.drawingNumbers[2]) - \(self.drawingNumbers[3]) - \(self.drawingNumbers[4]) - \(self.drawingNumbers[5]) ZZ:\(self.zusatzZahl)\r"
		}
		else if (self.drawingType == DrawingType.drawingTypeSuperZahl) {
			return "Ziehung vom \(self.date): \(self.drawingNumbers[0]) - \(self.drawingNumbers[1]) - \(self.drawingNumbers[2]) - \(self.drawingNumbers[3]) - \(self.drawingNumbers[4]) - \(self.drawingNumbers[5]) SZ:\(self.superZahl)\r"
		}
		else if (self.drawingType == DrawingType.drawingTypeZusatzZahlUndSuperZahl) {
			return "Ziehung vom \(self.date): \(self.drawingNumbers[0]) - \(self.drawingNumbers[1]) - \(self.drawingNumbers[2]) - \(self.drawingNumbers[3]) - \(self.drawingNumbers[4]) - \(self.drawingNumbers[5]) SZ:\(self.superZahl) ZZ:\(self.zusatzZahl)\r"
		}
		else {
			return ""
		}
	}
	
	func formattedDrawingDate() -> NSString {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		let drawingDate = formatter.dateFromString(self.date! as String)
		formatter.dateStyle = NSDateFormatterStyle.ShortStyle
		formatter.timeStyle = NSDateFormatterStyle.NoStyle
		return formatter.stringFromDate(drawingDate!)
	}
}
