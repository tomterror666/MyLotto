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
	var zusatzZahl:NSInteger?
	var superZahl:NSInteger?
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
		self.drawingNumbers = jsonDict.valueForKeyPath("lotto.gewinnzahlen") as! NSArray
		self.year = jsonDict.valueForKeyPath("year")?.integerValue
		self.date = jsonDict.valueForKeyPath("date") as! NSString
		self.zusatzZahl = jsonDict.valueForKeyPath("lotto.zusatzzahl") as? NSInteger
		self.superZahl = jsonDict.valueForKeyPath("lotto.superzahl") as? NSInteger
		self.stake = jsonDict.valueForKeyPath("lotto.spieleinsatz") as? CGFloat
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
			return "\(self.drawingNumbers[0]) - \(self.drawingNumbers[1]) - \(self.drawingNumbers[2]) - \(self.drawingNumbers[3]) - \(self.drawingNumbers[4]) - \(self.drawingNumbers[5]) ZZ:\(self.zusatzZahl)"
		}
		else if (self.drawingType == DrawingType.drawingTypeSuperZahl) {
			return "\(self.drawingNumbers[0]) - \(self.drawingNumbers[1]) - \(self.drawingNumbers[2]) - \(self.drawingNumbers[3]) - \(self.drawingNumbers[4]) - \(self.drawingNumbers[5]) SZ:\(self.superZahl)"
		}
		else if (self.drawingType == DrawingType.drawingTypeZusatzZahlUndSuperZahl) {
			return "\(self.drawingNumbers[0]) - \(self.drawingNumbers[1]) - \(self.drawingNumbers[2]) - \(self.drawingNumbers[3]) - \(self.drawingNumbers[4]) - \(self.drawingNumbers[5]) SZ:\(self.superZahl) ZZ:\(self.zusatzZahl)"
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
