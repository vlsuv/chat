//
//  ConversationsController.swift
//  chat
//
//  Created by vlsuv on 02.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class ConversationsController: UIViewController {
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        
        let loginController = UINavigationController(rootViewController: LoginController())
        navigationController?.present(loginController, animated: true, completion: nil)
    }
}
