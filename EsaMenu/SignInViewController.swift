//
//  SignInViewController.swift
//  EsaMenu
//
//  Created by horimislime on 12/11/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Cocoa

protocol SignInViewControllerDelegate: class {
    func signInFinished(controller: SignInViewController)
    func signInFailed(controller: SignInViewController, error: NSError)
}

class SignInViewController: NSViewController {
    
    weak var delegate: SignInViewControllerDelegate?
    
    @IBAction func loginButtonClicked(sender: AnyObject) {
        
        Esa.authorize { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let credential):
                debugPrint("auth success")
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: credential), forKey: "esa-credential")
                
                strongSelf.delegate?.signInFinished(controller: strongSelf)
                
            case .failure(let error):
                debugPrint("auth error: \(error.localizedDescription)")
                strongSelf.delegate?.signInFailed(controller: strongSelf, error: error as NSError)
            }
        }
    }
    
    
    @IBAction func quitButtonClicked(sender: NSButton) {
        NSApplication.shared().terminate(self)
    }
}
