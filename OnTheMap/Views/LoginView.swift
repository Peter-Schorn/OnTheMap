//
//  ViewController.swift
//  OnTheMap
//
//  Created by Peter Schorn on 6/10/20.
//  Copyright © 2020 Peter Schorn. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var loginTasks: [URLSessionDataTask?] = []
    
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text
        else {
            displayErrorMessage("The email or password field is blank")
            return
        }
        
        isLoggingIn = true
        loginViewLogger.debug("loggin in button tapped")
        
        let task = UdacityAPI.createSession(
            email: email, password: password
        ) { error in
            
            loginViewLogger.debug("inside createSession completion handler")
            
            self.isLoggingIn = false
            self.cancelLoginTasks()

            // MARK: - Handle Login Error -
            if let error = error {
                loginViewLogger.error("couldn't login\n\(error)")
                self.displayErrorMessage(error)
                return
            }
            
            loginViewLogger.debug("succeeded loging in")
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "LoginToTabBar", sender: self)
            }
            
        }
        
        loginTasks.append(task)
        
    
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        cancelLoginTasks()
        isLoggingIn = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #warning("Remove Login Credentials")
        emailTextField.text = "accountifunny@yahoo.com"
        passwordTextField.text = "iRH5NCNc8aqeQSf"
        
        loginButton.isEnabled = !emailOrPasswordAreEmpty
        for textField in [emailTextField, passwordTextField] {
            textField?.addTarget(
                self,
                action: #selector(textFieldDidChange(_:)),
                for: .editingChanged
            )
        }
     
        
    }
    
    
    func cancelLoginTasks() {
        
        for task in loginTasks {
            task?.cancel()
        }
        loginTasks = []
        
    }
    
    var _isLoggingIn = false
    var isLoggingIn: Bool {
        get {
            return _isLoggingIn
        }
        set {
            loginViewLogger.debug("is logging in: \(_isLoggingIn)")
            DispatchQueue.main.async {
                self._isLoggingIn = newValue
                self.loginButton.isEnabled = !self._isLoggingIn
                self.signUpButton.isEnabled = !self._isLoggingIn
                self.emailTextField.isEnabled = !self._isLoggingIn
                self.passwordTextField.isEnabled = !self._isLoggingIn
                self.cancelButton.isHidden = !self._isLoggingIn
                if self._isLoggingIn {
                    self.activityIndicator.startAnimating()
                }
                else {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    
    
    var emailOrPasswordAreEmpty: Bool {
        return emailTextField.text?.isEmpty ?? true ||
                passwordTextField.text?.isEmpty ?? true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        loginButton.isEnabled = !emailOrPasswordAreEmpty
        
    }

    
    func displayErrorMessage(_ error: Error?) {
        
        if (error as NSError?)?.code == -999 {
            loginViewLogger.debug("user manually canceled login tasks")
            return
        }
        
        DispatchQueue.main.async {
            let alert = makeAlert(
                title: "Couldn't Login",
                msg: error?.localizedDescription ?? "no error message was provided"
            )
            self.present(alert, animated: true)
        }
        
    }
    
    


}

