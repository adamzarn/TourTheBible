//
// Copyright 2014-2018 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License").
// You may not use this file except in compliance with the
// License. A copy of the License is located at
//
//     http://aws.amazon.com/asl/
//
// or in the "license" file accompanying this file. This file is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, express or implied. See the License
// for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import AWSCognitoIdentityProvider
import FBSDKCoreKit
import FBSDKLoginKit

@objc
protocol LoginViewControllerDelegate {
    @objc func switchTabs(index: Int)
    @objc optional func setLogoutButtonTitle(title: String)
    @objc optional func clearDetails()
    @objc optional func displayAccountInfo()
    @objc optional func refresh()
}

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var promptLabel: UILabel!
    
    var currentlyLoggedIn: Bool = false
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    var email: String?
    var virtualToursDelegate: LoginViewControllerDelegate?
    var accountDetailDelegate: LoginViewControllerDelegate?
    var pool: AWSCognitoIdentityUserPool?
    var user: AWSCognitoIdentityUser?
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = UIScreen.main.bounds.width
        let fbLoginButton = FBSDKLoginButton(frame: CGRect(x: (width/2-100.0), y: self.aiv.frame.origin.y + 20.0, width: 200.0, height: 40.0))
        fbLoginButton.readPermissions = ["email"]
        view.addSubview(fbLoginButton)
        fbLoginButton.delegate = self
        
        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
        formatTextField(textField: emailTextField)
        formatTextField(textField: passwordTextField)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if FBSDKAccessToken.current() != nil {
            
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields" : "email, name"])
                .start(completionHandler:  { (connection, result, error) in
                if let result = result {
                    let result = result as! NSDictionary
                    let email = result.value(forKey: "email") as! String
                    let name = result.value(forKey: "name") as! String
                    self.checkIfUserExists(email: email, name: name)
                }
            })
        }
    }
    
    func checkIfUserExists(email: String, name: String) {
        AWSClient.sharedInstance.userExists(email: email, completion: { (exists, error) -> () in
            if let error = error {
                self.displayAlert(title: "Error", message: error)
            } else if let exists = exists {
                if exists {
                    self.dismissLogin()
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
                self.dismissLogin()
            }
        })
    }
    
    func dismissLogin() {
        self.virtualToursDelegate?.refresh!()
        self.accountDetailDelegate?.displayAccountInfo!()
        self.accountDetailDelegate?.setLogoutButtonTitle!(title: "Logout")
        self.dismiss(animated: true, completion: nil)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.passwordTextField.text = nil
        self.emailTextField.text = email
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.aiv.isHidden = true
        if virtualToursDelegate != nil {
            promptLabel.text = "You must login to access Virtual Tours"
        }
        if accountDetailDelegate != nil {
            promptLabel.text = ""
        }
    }
    
    func formatTextField(textField: UITextField) {
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 2.0
    }
    
    @IBAction func LoginPressed(_ sender: AnyObject) {
        self.aiv.isHidden = false
        self.aiv.startAnimating()
        if (self.emailTextField.text != nil && self.passwordTextField.text != nil) {
            let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.emailTextField.text!, password: self.passwordTextField.text!)
            self.passwordAuthenticationCompletion?.set(result: authDetails)
        } else {
            self.aiv.isHidden = true
            self.aiv.stopAnimating()
            let alertController = UIAlertController(title: "Missing information",
                                                    message: "Please enter a valid user name and password",
                                                    preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
            alertController.addAction(retryAction)
        }
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        virtualToursDelegate?.switchTabs(index: 0)
        accountDetailDelegate?.switchTabs(index: 4)
        if currentlyLoggedIn {
            accountDetailDelegate?.setLogoutButtonTitle!(title: "Logout")
        } else {
            accountDetailDelegate?.setLogoutButtonTitle!(title: "Login")
            accountDetailDelegate?.clearDetails!()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "showCreateAccount", sender: sender)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension LoginViewController: AWSCognitoIdentityPasswordAuthentication {
    
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            if let lastEmail = UserDefaults.standard.value(forKey: "lastEmail") {
                self.email = lastEmail as? String
            }
        }
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError? {
                self.aiv.isHidden = true
                self.aiv.stopAnimating()
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: "This may be because your email isn't verified. In order to log in, your email must be verified.",
                                                        preferredStyle: .alert)
                
                let verifyEmailAction = UIAlertAction(title: "Verify Email", style: .default, handler: { (_) -> () in
                    self.aiv.isHidden = false
                    self.aiv.startAnimating()
                    self.displayVerifyEmailAlert()
                })
                alertController.addAction(verifyEmailAction)
                
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self.present(alertController, animated: true, completion:  nil)
            } else {
                self.accountDetailDelegate?.setLogoutButtonTitle!(title: "Logout")
                UserDefaults.standard.set(self.emailTextField.text, forKey: "lastEmail")
                self.emailTextField.text = nil
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func displayVerifyEmailAlert() {
        
        self.pool?.getUser(emailTextField.text!).resendConfirmationCode().continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let _ = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else if task.result != nil {
                    let emailToVerify = (self?.emailTextField.text!)!
                    let alertController = UIAlertController(title: "Verify Email", message: "Enter the verification code sent to \(emailToVerify).", preferredStyle: .alert)
                    
                    alertController.addTextField { (textField) in
                        textField.placeholder = "Verification Code"
                        textField.isSecureTextEntry = true
                    }
                    
                    let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
                        
                        if let verificationCode = alertController.textFields![0].text {
                            self?.pool?.getUser(emailToVerify).confirmSignUp(verificationCode, forceAliasCreation: true).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
                                guard let strongSelf = self else { return nil }
                                DispatchQueue.main.async(execute: {
                                    if task.error != nil {
                                        let alertController = UIAlertController(title: "Error",
                                                                                message: "An error occurred. Please try again.",
                                                                                preferredStyle: .alert)
                                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                        alertController.addAction(okAction)
                                        
                                        strongSelf.present(alertController, animated: true, completion:  nil)
                                    } else {
                                        let alertController = UIAlertController(title: "Success",
                                                                                message: "Your account was successfully confirmed. Please login now.",
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
                    
                    self?.aiv.isHidden = true
                    self?.aiv.stopAnimating()
                    self?.present(alertController, animated: true, completion: nil)
                    
                }
            })
            return nil
            
        }
        
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: AnyObject) {
        
        self.aiv.isHidden = false
        self.aiv.startAnimating()
        
        let passwordResetEmail = emailTextField.text
        if passwordResetEmail == "" {
            displayAlert(title: "Missing Email", message: "You must provide an email to reset your password.")
            return
        }
        
        self.user = self.pool?.getUser(passwordResetEmail!)
        self.user?.forgotPassword().continueWith{[weak self] (task: AWSTask) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self?.aiv.isHidden = true
                    self?.aiv.stopAnimating()
                    self?.present(alertController, animated: true, completion:  nil)
                } else {
                    self?.displayResetPasswordAlert(email: passwordResetEmail!)
                }
            })
            return nil
        }
    }
    
    func displayAlert(title: String, message: String) {
        self.aiv.isHidden = true
        self.aiv.stopAnimating()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
    
    func displayResetPasswordAlert(email: String) {
        
        let alertController = UIAlertController(title: "Reset Password", message: "Enter the password reset code sent to \(email) to reset your password.\n\nMake sure your new password is at least 8 characters long and includes numbers, lowercase letters, and uppercase letters.", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Password Reset Code"
            textField.isSecureTextEntry = true
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "New Password"
            textField.isSecureTextEntry = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            
            self.aiv.isHidden = false
            self.aiv.startAnimating()
            
            if let passwordResetCode = alertController.textFields![0].text,
            let newPassword = alertController.textFields![1].text {
                self.user?.confirmForgotPassword(passwordResetCode, password: newPassword).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
                    DispatchQueue.main.async(execute: {
                        if let error = task.error as NSError? {
                            let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                                    message: error.userInfo["message"] as? String,
                                                                    preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            self?.aiv.isHidden = true
                            self?.aiv.stopAnimating()
                            self?.present(alertController, animated: true, completion:  nil)
                        } else {
                            self?.displayAlert(title: "Success", message: "Your password was successfully reset.")
                        }
                    })
                    return nil
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        self.aiv.isHidden = true
        self.aiv.stopAnimating()
        self.present(alertController, animated: true, completion:  nil)
        
    }
    
}
