//
//  ContactLogicManager.swift
//  Contacts
//
//  Copyright © 2017 Nathan Tannar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Nathan Tannar on 7/25/17.
//

import UIKit
import RxSwift
import RxCocoa

class ContactLogicManager: NSObject {
    
    // MARK: - MVVM
    
    private let viewModel: ContactViewModel
    private weak var viewManager: ContactViewManager!
    
    // MARK: - RxSwift
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    
    init(viewModel: ContactViewModel, viewManager: ContactViewManager? = nil) {
        self.viewModel = viewModel
        super.init()
        self.viewManager = viewManager
        bindUItoViewModel()
    }
    
    fileprivate func bindUItoViewModel() {
        
        Observable.combineLatest([viewModel.firstName, viewModel.lastName]) { (fullname) -> String in
            return "\(fullname[0]) \(fullname[1])"
            }
            .bind(to: viewManager.nameLabel.rx.text).addDisposableTo(disposeBag)
        
        
        let stringURL: String
        do {
            stringURL = try viewModel.avatarURL.value()
        } catch _ {
            return
        }
        guard let avatarURL = URL(string: stringURL) else {
            return
        }
        
        URLSession.shared.rx.data(request: URLRequest(url: avatarURL)).subscribe(onNext: { (data) in
            DispatchQueue.main.async {
                self.viewManager.avatarView.image = UIImage(data: data)
                self.viewManager.avatarView.setNeedsLayout()
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(self.disposeBag)
    }
}
