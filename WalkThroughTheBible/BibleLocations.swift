//
//  BibleLocations.swift
//  WalkThroughTheBible
//
//  Created by Adam Zarn on 9/26/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation

struct BibleLocations {
    
    static let Locations = [
         "Babylon" :                        BibleLocation(name: "Babylon",                  lat: 32.536389, long: 44.420833, delta: 10.0)
        ,"Bethlehem" :                      BibleLocation(name: "Bethlehem",                lat: 31.705400, long: 35.202400, delta: 0.75)
        
        ,"Jerusalem" :                      BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
        ,"Zion" :                           BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
        
        ,"Egypt" :                          BibleLocation(name: "Egypt",                    lat: 30.787419, long: 31.821367, delta: 3.70)
        ,"Ramah" :                          BibleLocation(name: "Ramah",                    lat: 31.840000, long: 35.210000, delta: 0.30)
        
        ,"Nazareth" :                       BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
        ,"hometown" :                       BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
        
        ,"the river Jordan" :               BibleLocation(name: "The Jordan River",         lat: 31.826748, long: 35.547091, delta: 1.00)
        ,"the Jordan" :                     BibleLocation(name: "The Jordan River",         lat: 31.826748, long: 35.547091, delta: 1.00)
        
        ,"The Wilderness" :                 BibleLocation(name: "The Wilderness",           lat: 31.752365, long: 35.384903, delta: 1.00)
        ,"the wilderness" :                 BibleLocation(name: "The Wilderness",           lat: 31.752365, long: 35.384903, delta: 1.00)
        
        ,"Capernaum" :                      BibleLocation(name: "Capernaum",                lat: 32.880330, long: 35.573307, delta: 0.25)
        
        ,"the Sea of Galilee" :             BibleLocation(name: "The Sea of Galilee",       lat: 32.824432, long: 35.587998, delta: 0.50)
        ,"the sea," :                        BibleLocation(name: "The Sea of Galilee",      lat: 32.824432, long: 35.587998, delta: 0.50)
        ,"the sea." :                        BibleLocation(name: "The Sea of Galilee",      lat: 32.824432, long: 35.587998, delta: 0.50)
        ,"the sea " :                        BibleLocation(name: "The Sea of Galilee",      lat: 32.824432, long: 35.587998, delta: 0.50)
        
        ,"Syria" :                          BibleLocation(name: "Syria",                    lat: 33.028743, long: 35.781097, delta: 1.00)
        ,"the Decapolis" :                  BibleLocation(name: "The Decapolis",            lat: 32.386630, long: 36.062622, delta: 2.00)
        
        ,"the country of the Gadarenes" :   BibleLocation(name: "The Gadarenes (Gerasenes)",lat: 32.832376, long: 35.646468, delta: 0.10)
        ,"the country of the Gerasenes" :   BibleLocation(name: "The Gadarenes (Gerasenes)",lat: 32.832376, long: 35.646468, delta: 0.10)
        
        ,"Sodom" :                          BibleLocation(name: "Sodom",                    lat: 31.282494, long: 35.552444, delta: 1.50)
        ,"Gomorrah" :                       BibleLocation(name: "Gomorrah",                 lat: 31.132736, long: 35.518112, delta: 1.50)
        ,"Chorazin" :                       BibleLocation(name: "Chorazin",                 lat: 32.911389, long: 35.563889, delta: 0.25)
        ,"Bethsaida" :                      BibleLocation(name: "Bethsaida",                lat: 32.898486, long: 35.611496, delta: 0.25)
        ,"Tyre" :                           BibleLocation(name: "Tyre",                     lat: 33.270492, long: 35.203763, delta: 2.00)
        ,"Sidon" :                          BibleLocation(name: "Sidon",                    lat: 33.557069, long: 35.372948, delta: 2.00)
        ,"Nineveh" :                        BibleLocation(name: "Nineveh",                  lat: 36.359444, long: 43.152778, delta: 10.0)
        ,"the South" :                      BibleLocation(name: "Sheba",                    lat: 15.416667, long: 45.350000, delta: 30.0)
        ,"Gennesaret" :                     BibleLocation(name: "Gennesaret",               lat: 32.870000, long: 35.539312, delta: 0.50)
        ,"Israel" :                         BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 10.0)
        ,"Magadan" :                        BibleLocation(name: "Magadan",                  lat: 32.851286, long: 35.524635, delta: 0.25)
        ,"Caesarea Philippi" :              BibleLocation(name: "Caesarea Philippi",        lat: 33.246111, long: 35.693333, delta: 1.00)
        ,"a high mountain" :                BibleLocation(name: "Mount Hermon",             lat: 33.416111, long: 35.857500, delta: 1.00)
        ,"Galilee" :                        BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
        ,"Judea" :                          BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
        ,"beyond the Jordan" :              BibleLocation(name: "Beyond the Jordan",        lat: 31.978813, long: 35.733032, delta: 2.00)
        ,"Jericho" :                        BibleLocation(name: "Jericho",                  lat: 31.856982, long: 35.460567, delta: 1.00)
        ,"Bethphage" :                      BibleLocation(name: "Bethphage",                lat: 31.777249, long: 35.250750, delta: 0.10)
        ,"Mount of Olives" :                BibleLocation(name: "Mount of Olives",          lat: 31.779249, long: 35.242738, delta: 0.10)
        ,"the temple" :                     BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
        ,"Bethany" :                        BibleLocation(name: "Bethany",                  lat: 31.771411, long: 35.261325, delta: 0.10)
        
        ,"palace of the high priest" :      BibleLocation(name: "Caiaphas' Palace",         lat: 31.773444, long: 35.229120, delta: 0.03)
        ,"the courtyard" :                  BibleLocation(name: "Caiaphas' Palace",         lat: 31.773444, long: 35.229120, delta: 0.03)
        
        ,"at your house" :                  BibleLocation(name: "The Upper Room",           lat: 31.771881, long: 35.229273, delta: 0.03)
        ,"upper room" :                     BibleLocation(name: "The Upper Room",           lat: 31.771881, long: 35.229273, delta: 0.03)
        ,"Gethsemane" :                     BibleLocation(name: "The Garden of Gethsemane", lat: 31.779656, long: 35.239645, delta: 0.03)
        
        ,"the governor's headquarters" :    BibleLocation(name: "The Antonia Fortress",     lat: 31.780229, long: 35.233734, delta: 0.03)
        ,"stood before the governor" :      BibleLocation(name: "The Antonia Fortress",     lat: 31.780229, long: 35.233734, delta: 0.03)
        ,"over to Pilate" :                 BibleLocation(name: "The Antonia Fortress",     lat: 31.780229, long: 35.233734, delta: 0.03)
        
        ,"Golgotha" :                       BibleLocation(name: "Golgotha",                 lat: 31.778341, long: 35.229625, delta: 0.03)
        ,"Arimathea" :                      BibleLocation(name: "Arimathea",                lat: 31.952992, long: 34.889302, delta: 2.00)
        ,"tomb " :                          BibleLocation(name: "Jesus' Tomb",              lat: 31.779043, long: 35.228477, delta: 0.03)
        
        ,"Idumea" :                         BibleLocation(name: "Edom (Idumea)",            lat: 30.688559, long: 35.208435, delta: 1.00)
        ,"Magdala" :                        BibleLocation(name: "Magdala (Dalmanutha)",     lat: 32.825000, long: 35.515556, delta: 0.25)
        ,"Dalmanutha" :                     BibleLocation(name: "Magdala (Dalmanutha)",     lat: 32.825000, long: 35.515556, delta: 0.25)
        
    ]
    
    let transitionTypeArray = ["Drop Pin" //Babylon
        , "Drop Pin" //Bethlehem
        , "Drop Pin" //Jerusalem
        , "Draw Route" //Bethlehem to Egypt
        , "Drop Pin" //Ramah
        , "Draw Route" //Egypt to Nazareth
        ,"Drop Pin" //The Jordan River
        ,"Draw Route" //Nazareth to the Jordan
        ,"Draw Route" //The Jordan to wilderness
        ,"Draw Route" //Nazareth to Capernaum
        ,"Drop Pin" //The Sea of Galilee
        ,"Drop Pin" //Syria
        ,"Drop Pin" //The Decapolis
        ,"Draw Route" //Capernaum to the Mount
        ,"Draw Route" //The Mount to Capernaum
        ,"Draw Route" //Capernaum to the Gadarenes
        ,"Draw Route" //The Gadarenes to Capernaum
        ,"Drop Pin" //Sodom
        ,"Drop Pin" //Gomorrah
        ,"Drop Pin" //Chorazin
        ,"Drop Pin" //Bethsaida
        ,"Drop Pin" //Tyre
        ,"Drop Pin" //Sidon
        ,"Drop Pin" //Nineveh
        ,"Drop Pin" //Sheba
        ,"Draw Route" //Capernaum to Nazareth
        ,"Draw Route" //Out on the Sea
        ,"Draw Route" //Sea to Gennesaret
    ]
    
    let routes = [
        [""]
        ,[""]
        ,[""]
        ,["{31.7054,35.2024}","{31.20,34.41}","{31.04,34.01}","{30.92,33.44}","{30.88,32.96}","{30.86,32.40}","{30.787419,31.821367}"]//Bethlehem to Egypt
        ,[""]
        ,["{30.787419,31.821367}","{30.90,32.39}","{31.00,33.01}","{31.06,33.62}","{31.21,34.15}","{31.49,34.51}","{32.6996,35.3035}"]//Egypt to Nazareth
        ,[""]
        ,["{32.6996,35.3035}","{31.826748,35.547091}"] //Nazareth to the Jordan
        ,["{31.826748,35.547091}","{31.752365,35.384903}"] //The Jordan to the wilderness
        ,["{32.6996,35.3035}","{32.770370, 35.375977}","{32.845973, 35.457001}","{32.880330,35.573307}"] //Nazareth to Capernaum
        ,[""]
        ,[""]
        ,[""]
        ,["{32.880330,35.573307}","{32.880787,35.555902}"] //Capernaum to the Mount
        ,["{32.880787,35.555902}","{32.880330,35.573307}"] //The Mount to Capernaum
        ,["{32.880330,35.573307}","{32.832376,35.646468}"] //Capernaum to the Gadarenes
        ,["{32.832376,35.646468}","{32.880330,35.573307}"] //The Gadarenes to Capernaum
        ,[""] //Sodom
        ,[""] //Gomorrah
        ,[""] //Chorazin
        ,[""] //Bethsaida
        ,[""] //Tyre
        ,[""] //Sidon
        ,[""] //Nineveh
        ,[""] //Sheba
        ,["{32.880330,35.573307}","{32.845973, 35.457001}","{32.770370, 35.375977}","{32.6996,35.3035}"] //Capernaum to Nazareth
        ,["{32.880787,35.555902}","{32.867396, 35.615959}"] //Out on the Sea
        ,["{32.867396, 35.615959}","{32.87000, 35.539312}"] //Sea to Gennesaret
    ]
    
    
}
