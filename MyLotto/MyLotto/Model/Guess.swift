//
//  Guess.swift
//  MyLotto
//
//  Created by Andre Heß on 17/04/16.
//  Copyright © 2016 Andre Heß. All rights reserved.
//

import UIKit

let kGuessNumbersKey = "guessNumbersKey"
let kGuessSuperZahlKey = "guessSuperZahlKey"

class Guess: NSObject, NSCopying, NSCoding {
	var numbers:NSArray
	var superZahl:NSInteger
	
	static func guessWithNumbersAndSuperZahl(numbers:NSArray, superZahl:NSInteger) -> Guess {
		let me:Guess = Guess(numbers: numbers, superZahl: superZahl)
		return me
	}
	
	init(numbers:NSArray, superZahl:NSInteger) {
		self.numbers = numbers
		self.superZahl = superZahl
	}
	
	func encodeWithCoder(aCoder:NSCoder) {
		aCoder.encodeObject(self.numbers, forKey:kGuessNumbersKey)
		aCoder.encodeInteger(self.superZahl, forKey:kGuessSuperZahlKey)
	}
	
	required init?(coder aDecoder:NSCoder) {
		self.numbers = aDecoder.decodeObjectForKey(kGuessNumbersKey) as! NSArray
		self.superZahl = aDecoder.decodeIntegerForKey(kGuessSuperZahlKey)
	}
	
	func copyWithZone(zone:NSZone) -> AnyObject {
		let copy = Guess(numbers: self.numbers, superZahl: self.superZahl)
		return copy
	}

}
	