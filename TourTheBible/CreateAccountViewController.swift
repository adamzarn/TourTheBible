//
//  CreateAccountViewController.swift
//  TourTheBible
//
//  Created by Adam Zarn on 1/24/18.
//  Copyright © 2018 Adam Zarn. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class CreateAccountViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var pool: AWSCognitoIdentityUserPool?
    var user: AWSCognitoIdentityUser?
    
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!
    @IBOutlet weak var submitButton: UIBarButtonItem!
    
    //Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
        self.aiv.isHidden = true
        
        let textFields = [firstNameTextField, lastNameTextField, emailTextField, passwordTextField, verifyPasswordTextField]
        
        for textField in textFields {
            formatTextField(textField: textField!)
        }
        
        submitButton.tintColor = GlobalFunctions.shared.themeColor()
        self.navigationController?.navigationBar.barTintColor = GlobalFunctions.shared.themeColor()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.isTranslucent = false
        
    }
    
    func formatTextField(textField: UITextField) {
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 2.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUpView()
    }
    
    //IBActions
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        checkUserInput()
    }
    
    //Helper methods
    
    func checkUserInput() {
        if firstNameTextField.text == "" {
            displayAlert(title: "Missing First Name", message: "You must provide a first name.")
            return
        }
        if lastNameTextField.text == "" {
            displayAlert(title: "Missing Last Name", message: "You must provide a last name.")
            return
        }
        if emailTextField.text == "" {
            displayAlert(title: "Missing Email", message: "You must provide an email.")
            return
        }
        if passwordTextField.text == "" {
            displayAlert(title: "Missing Password", message: "You must provide a password.")
            return
        }
        if passwordTextField.text != verifyPasswordTextField.text {
            displayAlert(title: "Password Mismatch", message: "Please make sure that your passwords match.")
            return
        }
        aiv.isHidden = false
        aiv.startAnimating()
        createUser()
    }
    
    func setUpView() {
        aiv.isHidden = true
    }
    
    func displayAlert(title: String, message: String) {
        self.aiv.isHidden = true
        self.aiv.stopAnimating()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
    
    //Text Field Delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Create Account methods
    
    func createUser() {
        let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespaces)
        let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespaces)
        let email = emailTextField.text
        let password = passwordTextField.text
        
        var attributes = [AWSCognitoIdentityUserAttributeType]()
        
        let emailAttribute = AWSCognitoIdentityUserAttributeType()
        emailAttribute?.name = "email"
        emailAttribute?.value = email
        attributes.append(emailAttribute!)
        
        let firstNameAttribute = AWSCognitoIdentityUserAttributeType()
        firstNameAttribute?.name = "given_name"
        firstNameAttribute?.value = firstName
        attributes.append(firstNameAttribute!)
    
        let lastNameAttribute = AWSCognitoIdentityUserAttributeType()
        lastNameAttribute?.name = "family_name"
        lastNameAttribute?.value = lastName
        attributes.append(lastNameAttribute!)

        if GlobalFunctions.shared.hasConnectivity() {
            
            self.pool?.signUp(email!, password: password!, userAttributes: attributes, validationData: nil).continueWith {[weak self] (task) -> Any? in
                guard let strongSelf = self else { return nil }
                DispatchQueue.main.async(execute: {
                    if let error = task.error as NSError? {
                        let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                                message: error.userInfo["message"] as? String,
                                                                preferredStyle: .alert)
                        let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                        alertController.addAction(retryAction)
                        
                        self?.present(alertController, animated: true, completion:  nil)
                    } else if let result = task.result  {
                        // handle the case where user has to confirm his identity via email / SMS
                        if (result.user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed) {
                            self?.user = result.user
                            self?.checkIfUserExists(email: email!, name: firstName! + " " + lastName!)
                        } else {
                            let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                    
                })
                return nil
            }
            
        } else {
            
            displayAlert(title: "No Internet Connectivity", message: "Establish an Internet Connection and try again.")
            
        }
        
    }
    
    func checkIfUserExists(email: String, name: String) {
        AWSClient.sharedInstance.userExists(email: email, completion: { (exists, error) -> () in
            if let error = error {
                self.displayAlert(title: "Error", message: error)
            } else if let exists = exists {
                if exists {
                    self.displayVerifyEmailAlert()
                } else {
                    self.addUser(email: email, name: name)
                }
            }
        })
    }
    
    func addUser(email: String, name: String) {
        AWSClient.sharedInstance.addUser(email: email, name: name, completion: { (success, error) -> () in
            if let error = error {
                self.displayAlert(title: "Error", message: error)
            } else {
                self.displayVerifyEmailAlert()
            }
        })
    }
    
    func displayVerifyEmailAlert() {
        self.aiv.isHidden = true
        self.aiv.stopAnimating()
        let alertController = UIAlertController(title: "Verify Email", message: "Enter the verification code sent to \(String(describing: emailTextField.text!)).", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Verification Code"
            textField.isSecureTextEntry = true
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            
            if let verificationCode = alertController.textFields![0].text {
                self.user?.confirmSignUp(verificationCode, forceAliasCreation: true).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
                    guard let strongSelf = self else { return nil }
                    DispatchQueue.main.async(execute: {
                        if let error = task.error as NSError? {
                            let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                                    message: error.userInfo["message"] as? String,
                                                                    preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            
                            strongSelf.present(alertController, animated: true, completion:  nil)
                        } else {
                            let alertController = UIAlertController(title: "Success",
                                                                    message: "Your account was successfully created and confirmed. We'll take you to the Login screen now to login.",
                                                                    preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (_) -> () in
                                let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                            })
                            alertController.addAction(okAction)
                            
                            strongSelf.present(alertController, animated: true, completion:  nil)
                            
                        }
                    })
                    return nil
                }
            }
        }
        alertController.addAction(submitAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
