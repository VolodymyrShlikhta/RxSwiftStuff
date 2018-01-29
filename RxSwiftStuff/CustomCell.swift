//
//  CustomCell.swift
//  RxSwiftStuff
//
//  Created by Volodymyr Shlikhta on 1/25/18.
//  Copyright © 2018 Volodymyr Shlikhta. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
   
//    var cost: Variable<String>("") {
//        didSet {
//            self.
//        }
//    }
    
    func setup(with item: DisplayItem) {
        self.currencyLabel.text = item.symbol
        self.currencyLabel.text?.append(item.isFavorite ? "❤️" : "") 
    }
    
}
