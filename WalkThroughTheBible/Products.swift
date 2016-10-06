//
//  Products.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 10/4/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation

public struct Products {
    
    public static let Acts = "AJZ.WalkThroughTheBible.Acts"
    public static let Exodus = "AJZ.WalkThroughTheBible.Exodus"
    public static let Numbers = "AJZ.WalkThroughTheBible.Numbers"
    
    //public static let Acts = "Acts"
    //public static let Exodus = "Exodus"
    //public static let Numbers = "Numbers"
    
    static let productIdentifiers: Set<ProductIdentifier> = [Products.Acts,Products.Exodus,Products.Numbers]
    
    public static let store = IAPHelper(productIds: Products.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
