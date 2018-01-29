//
//  ViewController.swift
//  RxSwiftStuff
//
//  Created by Volodymyr Shlikhta on 1/25/18.
//  Copyright © 2018 Volodymyr Shlikhta. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Foundation

fileprivate let cellIdentifier = "CustomCell"

class DisplayItem {
    var symbol: String
    var isFavorite: Bool = false
    private let price = Variable<Double>(0)
    var priceObservable: Observable<Double> {
        return price.asObservable()
    }
    
    init(symbol: String, favorite: Bool) {
        self.symbol = symbol
        self.isFavorite = favorite
    }
    
    func update(_ price: Double) {
        self.price.value = price
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var customTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var showFavoriteSwitch: UISwitch!
    
    
    fileprivate var bag = DisposeBag()
    var allItems = Variable<[DisplayItem]>([])
    var testSymbols = ["USD", "EUR", "UAH", "GBP"]
    var items = Variable<[DisplayItem]>([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "Test"
        customTableView.delegate = self
        customTableView.dataSource = self
        allItems.value = testSymbols.enumerated().map({ DisplayItem(symbol: $1, favorite: $0 % 2 == 0)
        })
        
        bindUI()
        
        generateNewValues()
    }
    
    func bindUI() {
        
        // collects updates from allItems, change in text, change on switch
        Observable.combineLatest (
            allItems.asObservable(), // if data is loaded in allItems
            showFavoriteSwitch.rx.isOn, // if fav switch toggled
            searchTextField.rx.text, // if searchField changes text
            resultSelector: { (currentPrices, onlyFavorites, search) in
                // and performs result selector
                return currentPrices.filter { price -> Bool in
                    return self.shouldDisplayPrice(forItem: price,
                                              search: search,
                                              onlyFavorites: onlyFavorites)
                }
                
        })
        .bind(to: items) // update items
        .disposed(by: bag)
        
        
        
        // updates table view when items get updated
        items.asObservable()
            .subscribe(onNext: { [weak self] value in
                self?.customTableView.reloadData()
            })
            .disposed(by: bag)
            
        
        
    }
    
    fileprivate func shouldDisplayPrice(forItem item: DisplayItem, search: String?, onlyFavorites: Bool) -> Bool {
        // condition to filter ones that are not favorite in onlyFavorite mode
        if onlyFavorites && !item.isFavorite {
            return false
        }
        if let searchText = search {
            if !searchText.isEmpty && !item.symbol.contains(searchText) {
                return false
            }
        }
        return true
    }
    
    fileprivate func update(items: [DisplayItem], with newItems: [String: Double]) -> [DisplayItem] {
        for (key, newItem) in newItems {
            if let item = items.filter({ $0.symbol == key }).first {
                item.update(newItem)
            }
        }
        return items
    }
    
    fileprivate func generateNewValues() {
        allItems.value = allItems.value.map({ item in
            item.update(Double(arc4random_uniform(100)))
            return item
        })
        
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CustomCell
        let item = items.value[indexPath.row]
        cell.setup(with: item)
        
        item.priceObservable.subscribe(onNext: { [unowned cell] value in
            cell.valueLabel.text = "\(value)"
        })
        .disposed(by: bag)
        
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items.value[indexPath.row].isFavorite = !items.value[indexPath.row].isFavorite
        customTableView.reloadRows(at: [indexPath], with: .none)
    }
}
