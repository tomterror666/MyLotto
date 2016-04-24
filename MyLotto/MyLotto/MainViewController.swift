//
//  ViewController.swift
//  MyLotto
//
//  Created by Andre Heß on 17/04/16.
//  Copyright © 2016 Andre Heß. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

	@IBOutlet weak var showWinningsButton: UIButton!
	@IBOutlet weak var examineWinningButton: UIButton!
	@IBOutlet weak var calcStartValueLabel: UILabel!
	@IBOutlet weak var calcStartLabel: UILabel!
	@IBOutlet weak var winningSumLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


	@IBAction func showWinningsButtonTouched(sender: AnyObject) {
	}
	
	@IBAction func examineWinningsButtonTouched(sender: AnyObject) {
		let lottoDaysProvider = LottoDaysProvider.sharedProvider()
		let startingDate = lottoDaysProvider.dateFromString(self.calcStartValueLabel.text!)
		lottoDaysProvider.loadLottoDaysSinceDate(startingDate) { (lottoDays:NSArray) -> (Void) in
			print("\(lottoDays)")
		}
	}
}

