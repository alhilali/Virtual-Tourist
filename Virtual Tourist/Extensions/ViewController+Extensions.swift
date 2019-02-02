//
//  ViewController+Extensions.swift
//  Virtual Tourist
//
//  Created by Saud Alhelali on 02/02/2019.
//  Copyright © 2019 Saud Alhelali. All rights reserved.
//


import UIKit

extension UIViewController {
    
    func save() {
        do {
            try DataController.shared.context.save()
        } catch {
            showInfo(withTitle: "Error", withMessage: "Error while saving data: \(error)")
        }
    }
    
    func showInfo(withTitle: String = "Info", withMessage: String, action: (() -> Void)? = nil) {
        performUIUpdatesOnMain {
            let alertAction = UIAlertController(title: withTitle, message: withMessage, preferredStyle: .alert)
            alertAction.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alertAction) in
                action?()
            }))
            self.present(alertAction, animated: true)
        }
    }
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
}


