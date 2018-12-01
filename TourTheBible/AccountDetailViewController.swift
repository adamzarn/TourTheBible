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
import UIKit
import AWSCognitoIdentityProvider
import FBSDKCoreKit
import FBSDKLoginKit

class AccountDetailViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDetails: AWSCognitoIdentityUserGetDetailsResponse?
    var fbUserDetails: NSDictionary?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var attributesMap = ["sub": "Unique ID",
                         "email_verified": "Email Verified",
                         "given_name": "First Name",
                         "family_name": "Last Name",
                         "email": "Email"]
    
    var fbAttributes = ["id", "name", "email"]
    var fbAttributesMap = ["id": "Unique ID",
                        "name": "Name",
                        "email": "Email"]
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    let profilePicButton: UIButton = UIButton(type: UIButtonType.custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        self.tableView.delegate = self
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Account"
        tableView.isHidden = true
        appDelegate.virtualTourTableViewController = nil
        appDelegate.accountDetailViewController = self
        self.user = self.pool?.currentUser()
        displayAccountInfo()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let userDetails = self.userDetails  {
            return userDetails.userAttributes!.count + 1
        } else if let fbUserDetails = self.fbUserDetails {
            return fbUserDetails.allKeys.count + 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "attribute", for: indexPath)
        if let attributes = self.userDetails?.userAttributes {
            if indexPath.row == 0 {
                cell.textLabel!.text = "Logged in via"
                cell.detailTextLabel!.text = "TourTheBible"
            } else {
                let userAttribute = attributes[indexPath.row-1]
                cell.textLabel!.text = attributesMap[(userAttribute.name)!]
                cell.detailTextLabel!.text = userAttribute.value
            }
        } else if let fbUserDetails = self.fbUserDetails {
            if indexPath.row == 0 {
                cell.textLabel!.text = "Logged in via"
                cell.detailTextLabel!.text = "Facebook"
            } else {
                let fbUserAttribute = fbAttributes[indexPath.row-1]
                cell.textLabel!.text = fbAttributesMap[fbUserAttribute]
                cell.detailTextLabel!.text = fbUserDetails.value(forKey: fbUserAttribute) as? String
            }
        } else {
            cell.textLabel!.text = "Logged in via"
            cell.detailTextLabel!.text = "Not logged in"
        }
        return cell
    }
    
    func getFBUserDetails() {
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields" : "email, name"])
            .start(completionHandler:  { (connection, result, error) in
                if let result = result {
                    self.fbUserDetails = result as? NSDictionary
                    self.logoutButton.title = "Logout"
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                    if let url = URL(string: "https://graph.facebook.com/me/picture?type=large&width=32&return_ssl_resources=1&access_token="+FBSDKAccessToken.current().tokenString) {
                        self.downloadImage(url: url)
                    }
                }
            })
    }
    
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                let image = UIImage(data: data)
                self.profilePicButton.imageView?.contentMode = .scaleAspectFit
                self.profilePicButton.setImage(image, for: UIControlState.normal)
                self.profilePicButton.imageView?.layer.cornerRadius = 16
                let barButton = UIBarButtonItem(customView: self.profilePicButton)
                barButton.width = 0.0
                self.navigationItem.leftBarButtonItem = barButton
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func refresh() {
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                let result = task.result
                self.userDetails = result
                self.logoutButton.title = "Logout"
                self.tableView.isHidden = false
                self.tableView.reloadData()
            })
            return nil
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        if logoutButton.title == "Logout" {
            appDelegate.currentlyLoggedIn = false
        }
        if FBSDKAccessToken.current() != nil {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            self.fbUserDetails = nil
            self.navigationItem.leftBarButtonItem = nil
            self.refresh()
        } else {
            self.user?.signOut()
            self.userDetails = nil
            self.refresh()
        }
    }
    
}

extension AccountDetailViewController: LoginViewControllerDelegate {
    
    func switchTabs(index: Int) {
        self.tabBarController?.selectedIndex = index
    }
    
    func setLogoutButtonTitle(title: String) {
        logoutButton.title = title
    }
    
    func clearDetails() {
        self.userDetails = nil
        self.fbUserDetails = nil
        self.tableView.reloadData()
    }
    
    func displayAccountInfo() {
        if FBSDKAccessToken.current() != nil {
            getFBUserDetails()
        } else {
            self.user = self.pool?.currentUser()
            self.tableView.reloadData()
            self.refresh()
        }
    }
    
}

