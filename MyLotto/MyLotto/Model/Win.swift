//
//  Win.swift
//  MyLotto
//
//  Created by Andre Heß on 17/04/16.
//  Copyright © 2016 Andre Heß. All rights reserved.
//

import UIKit

class Win: NSObject {
	var winningDrawingRate:DrawingRate?
	var winningNumbers:NSArray?
	var winningZusatzZahl:NSInteger
	var winningSuperZahl:NSInteger
	var guess:Guess
	var drawing:Drawing
	
	static func winWithGuessAndDrawing(guess:Guess, drawing:Drawing) -> Win {
		let me = Win(guess: guess, drawing: drawing)
		return me
	}
	
	init(guess:Guess, drawing:Drawing) {
		self.guess = guess
		self.drawing = drawing
		self.winningSuperZahl = -1
		self.winningZusatzZahl = -1
		self.winningDrawingRate = nil
		self.winningNumbers = nil
		super.init()
		self.checkForWinning()
	}
	
	func checkForWinning()  {
		self.calcWinningNumbers()
		self.checkDrawingType()
		self.examineWinningDrawingRate()
	}
	
	func calcWinningNumbers() {
		let winningNumbers = NSMutableArray.init(capacity: 6)
		for drawingNumber in self.drawing.drawingNumbers {
			if (self.guess.numbers.containsObject(drawingNumber)) {
				winningNumbers.addObject(drawingNumber)
			}
		}
		self.winningNumbers = winningNumbers
	}
	
	func checkDrawingType() {
		if (self.drawing.drawingType == DrawingType.drawingTypeZusatzZahl) {
			self.winningSuperZahl = -1
			self.winningZusatzZahl = self.guess.numbers.containsObject(NSNumber.init(integer: self.drawing.zusatzZahl!)) ? self.drawing.zusatzZahl! : -1
		}
		else if (self.drawing.drawingType == DrawingType.drawingTypeSuperZahl) {
			self.winningSuperZahl = self.guess.numbers.containsObject(NSNumber.init(integer: self.drawing.superZahl!)) ? self.drawing.superZahl! : -1
			self.winningZusatzZahl = -1
		}
		else if (self.drawing.drawingType == DrawingType.drawingTypeZusatzZahlUndSuperZahl) {
			self.winningSuperZahl = self.guess.numbers.containsObject(NSNumber.init(integer: self.drawing.superZahl!)) ? self.drawing.superZahl! : -1
			self.winningZusatzZahl = self.guess.numbers.containsObject(NSNumber.init(integer: self.drawing.zusatzZahl!)) ? self.drawing.zusatzZahl! : -1
		}
		else {
			self.winningSuperZahl = -1
			self.winningZusatzZahl = -1
		}
	}
	
	func examineWinningDrawingRate() {
		let numberOfWinnings = self.winningNumbers != nil ? self.winningNumbers!.count : 0
		for object:AnyObject in self.drawing.rates {
			let rate:DrawingRate = object as! DrawingRate
			if ((rate.winningConditions == numberOfWinnings) &&
				((rate.winningConditions.needsZusatzZahl && (self.winningZusatzZahl > -1)) || !rate.winningConditions.needsZusatzZahl) &&
				((rate.winningConditions.needsSuperZahl && (self.winningSuperZahl > -1)) || !rate.winningConditions.needsSuperZahl)) {
				self.winningDrawingRate = rate
				return
			}
		}
	}
}
