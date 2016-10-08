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
        "Matthew" :
       ["1": ["Babylon" :                        BibleLocation(name: "Babylon",                  lat: 32.536389, long: 44.420833, delta: 10.0)]
        ,
        "2": ["Bethlehem" :                      BibleLocation(name: "Bethlehem",                lat: 31.705400, long: 35.202400, delta: 0.75)
              ,"Judea" :                         BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Israel" :                        BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Egypt" :                         BibleLocation(name: "Egypt",                    lat: 30.787419, long: 31.821367, delta: 3.70)
              ,"Ramah" :                         BibleLocation(name: "Ramah",                    lat: 31.840000, long: 35.210000, delta: 0.30)
              ,"Galilee" :                       BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Nazareth" :                      BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)]
        ,
        "3": ["the wilderness" :                 BibleLocation(name: "The Wilderness",           lat: 31.752365, long: 35.384903, delta: 1.00)
              ,"Judea" :                         BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Jordan" :                        BibleLocation(name: "The Jordan River",         lat: 31.826748, long: 35.547091, delta: 1.00)
              ,"Galilee" :                       BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)]
        ,
        "4": ["the wilderness" :                 BibleLocation(name: "The Wilderness",           lat: 31.752365, long: 35.384903, delta: 1.00)
              ,"temple" :                        BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Galilee" :                       BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Nazareth" :                      BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"Capernaum" :                     BibleLocation(name: "Capernaum",                lat: 32.880330, long: 35.573307, delta: 0.25)
              ,"beyond the Jordan" :             BibleLocation(name: "Beyond the Jordan",        lat: 31.978813, long: 35.733032, delta: 2.00)
              ,"Sea of Galilee" :                BibleLocation(name: "The Sea of Galilee",       lat: 32.824432, long: 35.587998, delta: 0.50)
              ,"Syria" :                         BibleLocation(name: "Syria",                    lat: 33.028743, long: 35.781097, delta: 1.00)
              ,"Decapolis" :                     BibleLocation(name: "The Decapolis",            lat: 32.386630, long: 36.062622, delta: 2.00)
              ,"Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Judea" :                         BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)]
        ,
        "5": ["Jerusalem" :                      BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)]
        ,
        "6": [:]
            ,
        "7": [:]
            ,
        "8": ["Capernaum" :                      BibleLocation(name: "Capernaum",                lat: 32.880330, long: 35.573307, delta: 0.25)
              ,"Israel" :                        BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"country of the Gadarenes" :      BibleLocation(name: "The Gadarenes (Gerasenes)",lat: 32.832376, long: 35.646468, delta: 0.10)]
        ,
        "9": ["Israel" :                         BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)]
        ,
        "10":["Israel" :                         BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Sodom" :                         BibleLocation(name: "Sodom",                    lat: 31.282494, long: 35.552444, delta: 1.50)
              ,"Gomorrah" :                      BibleLocation(name: "Gomorrah",                 lat: 31.132736, long: 35.518112, delta: 1.50)]
        ,
        "11":["the wilderness" :                 BibleLocation(name: "The Wilderness",           lat: 31.752365, long: 35.384903, delta: 1.00)
              ,"Chorazin" :                      BibleLocation(name: "Chorazin",                 lat: 32.911389, long: 35.563889, delta: 0.25)
              ,"Bethsaida" :                     BibleLocation(name: "Bethsaida",                lat: 32.898486, long: 35.611496, delta: 0.25)
              ,"Tyre" :                          BibleLocation(name: "Tyre",                     lat: 33.270492, long: 35.203763, delta: 2.00)
              ,"Sidon" :                         BibleLocation(name: "Sidon",                    lat: 33.557069, long: 35.372948, delta: 2.00)
              ,"Capernaum" :                     BibleLocation(name: "Capernaum",                lat: 32.880330, long: 35.573307, delta: 0.25)
              ,"Sodom" :                         BibleLocation(name: "Sodom",                    lat: 31.282494, long: 35.552444, delta: 1.50)]
        ,
        "12":["temple" :                         BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Nineveh" :                       BibleLocation(name: "Nineveh",                  lat: 36.359444, long: 43.152778, delta: 10.0)
              ,"the South" :                     BibleLocation(name: "Sheba",                    lat: 15.416667, long: 45.350000, delta: 30.0)]
        ,
        "13":["hometown" :                       BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)]
        ,
        "14":["Gennesaret" :                     BibleLocation(name: "Gennesaret",               lat: 32.870000, long: 35.539312, delta: 0.50)]
        ,
        "15":["Jerusalem" :                      BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Tyre" :                          BibleLocation(name: "Tyre",                     lat: 33.270492, long: 35.203763, delta: 2.00)
              ,"Sidon" :                         BibleLocation(name: "Sidon",                    lat: 33.557069, long: 35.372948, delta: 2.00)
              ,"Israel" :                        BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Sea of Galilee" :                BibleLocation(name: "The Sea of Galilee",       lat: 32.824432, long: 35.587998, delta: 0.50)
              ,"Magadan" :                       BibleLocation(name: "Magadan",                  lat: 32.851286, long: 35.524635, delta: 0.25)]
        ,
        "16":["Caesarea Philippi" :              BibleLocation(name: "Caesarea Philippi",        lat: 33.246111, long: 35.693333, delta: 1.00)
              ,"Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)]
        ,
        "17":["a high mountain" :                BibleLocation(name: "Mount Hermon",             lat: 33.416111, long: 35.857500, delta: 1.00)
              ,"Galilee" :                       BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Capernaum" :                     BibleLocation(name: "Capernaum",                lat: 32.880330, long: 35.573307, delta: 0.25)]
        ,
        "18":[:]
        ,
        "19":["Galilee" :                        BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Judea" :                         BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"beyond the Jordan" :             BibleLocation(name: "Beyond the Jordan",        lat: 31.978813, long: 35.733032, delta: 2.00)
              ,"Israel" :                        BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)]
        ,
        "20":["Jerusalem" :                      BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Jericho" :                       BibleLocation(name: "Jericho",                  lat: 31.856982, long: 35.460567, delta: 1.00)]
        ,
        "21":["Jerusalem" :                      BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Bethphage" :                     BibleLocation(name: "Bethphage",                lat: 31.777249, long: 35.250750, delta: 0.10)
              ,"Mount of Olives" :               BibleLocation(name: "Mount of Olives",          lat: 31.779249, long: 35.242738, delta: 0.10)
              ,"Zion" :                          BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Nazareth" :                      BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"Galilee" :                       BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"temple" :                        BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Bethany" :                       BibleLocation(name: "Bethany",                  lat: 31.771411, long: 35.261325, delta: 0.10)
            ]
        ,
        "22":[:]
        ,
        "23":["temple" :                         BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)]
        ,
        "24":["temple" :                         BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Mount of Olives" :               BibleLocation(name: "Mount of Olives",          lat: 31.779249, long: 35.242738, delta: 0.10)
              ,"Judea" :                         BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"the wilderness" :                BibleLocation(name: "The Wilderness",           lat: 31.752365, long: 35.384903, delta: 1.00)]
        ,
        "25":[:]
        ,
        "26":["palace" :                        BibleLocation(name: "Caiaphas' Palace",         lat: 31.773444, long: 35.229120, delta: 0.03)
              ,"Bethany" :                      BibleLocation(name: "Bethany",                  lat: 31.771411, long: 35.261325, delta: 0.10)
              ,"at your house" :                BibleLocation(name: "The Upper Room",           lat: 31.771881, long: 35.229273, delta: 0.03)
              ,"Mount of Olives" :              BibleLocation(name: "Mount of Olives",          lat: 31.779249, long: 35.242738, delta: 0.10)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Gethsemane" :                   BibleLocation(name: "The Garden of Gethsemane", lat: 31.779656, long: 35.239645, delta: 0.03)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"courtyard" :                    BibleLocation(name: "Caiaphas' Palace",         lat: 31.773444, long: 35.229120, delta: 0.03)
              ,"Nazareth" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)]
        ,
        "27":["over to Pilate" :                BibleLocation(name: "The Antonia Fortress",     lat: 31.780229, long: 35.233734, delta: 0.03)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"stood before the governor" :    BibleLocation(name: "The Antonia Fortress",     lat: 31.780229, long: 35.233734, delta: 0.03)
              ,"governor's headquarters" :      BibleLocation(name: "The Antonia Fortress",     lat: 31.780229, long: 35.233734, delta: 0.03)
              ,"Cyrene" :                       BibleLocation(name: "Cyrene",                   lat: 32.803449, long: 21.862820, delta: 30.0)
              ,"Golgotha" :                     BibleLocation(name: "Golgotha (The Skull)",     lat: 31.778341, long: 35.229625, delta: 0.03)
              ,"Place of a Skull" :             BibleLocation(name: "Golgotha (The Skull)",     lat: 31.778341, long: 35.229625, delta: 0.03)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Arimathea" :                    BibleLocation(name: "Arimathea",                lat: 31.952992, long: 34.889302, delta: 2.00)
              ,"Jesus' Tomb" :                  BibleLocation(name: "Jesus' Tomb",              lat: 31.778489, long: 35.229592, delta: 0.03)
              ,"before Pilate" :                BibleLocation(name: "The Antonia Fortress",     lat: 31.780229, long: 35.233734, delta: 0.03)]
        ,
        "28":["Galilee" :                       BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)]]
        ,
        "Mark" :
       ["1": ["the wilderness" :                BibleLocation(name: "The Wilderness",           lat: 31.752365, long: 35.384903, delta: 1.00)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Jordan" :                       BibleLocation(name: "The Jordan River",         lat: 31.826748, long: 35.547091, delta: 1.00)
              ,"Nazareth" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Sea of Galilee" :               BibleLocation(name: "The Sea of Galilee",       lat: 32.824432, long: 35.587998, delta: 0.50)
              ,"Capernaum" :                    BibleLocation(name: "Capernaum",                lat: 32.880330, long: 35.573307, delta: 0.25)]
        ,
        "2": ["Capernaum" :                     BibleLocation(name: "Capernaum",                lat: 32.880330, long: 35.573307, delta: 0.25)]
        ,
        "3": ["Galilee" :                       BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Idumea" :                       BibleLocation(name: "Edom (Idumea)",            lat: 30.688559, long: 35.208435, delta: 1.00)
              ,"beyond the Jordan" :            BibleLocation(name: "Beyond the Jordan",        lat: 31.978813, long: 35.733032, delta: 2.00)
              ,"Tyre" :                         BibleLocation(name: "Tyre",                     lat: 33.270492, long: 35.203763, delta: 2.00)
              ,"Sidon" :                        BibleLocation(name: "Sidon",                    lat: 33.557069, long: 35.372948, delta: 2.00)]
        ,
        "4": [:]
        ,
        "5": ["country of the Gerasenes" :      BibleLocation(name: "The Gadarenes (Gerasenes)",lat: 32.832376, long: 35.646468, delta: 0.10)
              ,"Decapolis" :                    BibleLocation(name: "The Decapolis",            lat: 32.386630, long: 36.062622, delta: 2.00)]
        ,
        "6": ["hometown" :                      BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Bethsaida" :                    BibleLocation(name: "Bethsaida",                lat: 32.898486, long: 35.611496, delta: 0.25)
              ,"Gennesaret" :                   BibleLocation(name: "Gennesaret",               lat: 32.870000, long: 35.539312, delta: 0.50)]
        ,
        "7": ["Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Tyre" :                         BibleLocation(name: "Tyre",                     lat: 33.270492, long: 35.203763, delta: 2.00)
              ,"Sidon" :                        BibleLocation(name: "Sidon",                    lat: 33.557069, long: 35.372948, delta: 2.00)
              ,"Sea of Galilee" :               BibleLocation(name: "The Sea of Galilee",       lat: 32.824432, long: 35.587998, delta: 0.50)
              ,"Decapolis" :                    BibleLocation(name: "The Decapolis",            lat: 32.386630, long: 36.062622, delta: 2.00)]
        ,
        "8": ["Dalmanutha" :                    BibleLocation(name: "Magdala (Dalmanutha)",     lat: 32.825000, long: 35.515556, delta: 0.25)
              ,"Bethsaida" :                    BibleLocation(name: "Bethsaida",                lat: 32.898486, long: 35.611496, delta: 0.25)
              ,"Caesarea Philippi" :            BibleLocation(name: "Caesarea Philippi",        lat: 33.246111, long: 35.693333, delta: 1.00)]
        ,
        "9": ["a high mountain" :               BibleLocation(name: "Mount Hermon",             lat: 33.416111, long: 35.857500, delta: 1.00)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Capernaum" :                    BibleLocation(name: "Capernaum",                lat: 32.880330, long: 35.573307, delta: 0.25)]
        ,
        "10":["Judea" :                         BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"beyond the Jordan" :            BibleLocation(name: "Beyond the Jordan",        lat: 31.978813, long: 35.733032, delta: 2.00)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Jericho" :                      BibleLocation(name: "Jericho",                  lat: 31.856982, long: 35.460567, delta: 1.00)
              ,"Nazareth" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)]
        ,
        "11":["Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Bethphage" :                    BibleLocation(name: "Bethphage",                lat: 31.777249, long: 35.250750, delta: 0.10)
              ,"Bethany" :                      BibleLocation(name: "Bethany",                  lat: 31.771411, long: 35.261325, delta: 0.10)
              ,"Mount of Olives" :              BibleLocation(name: "Mount of Olives",          lat: 31.779249, long: 35.242738, delta: 0.10)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)]
        ,
        "12":["Israel" :                        BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)]
        ,
        "13":["temple" :                        BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Mount of Olives" :              BibleLocation(name: "Mount of Olives",          lat: 31.779249, long: 35.242738, delta: 0.10)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)]
        ,
        "14":["Bethany" :                       BibleLocation(name: "Bethany",                  lat: 31.771411, long: 35.261325, delta: 0.10)
              ,"upper room" :                   BibleLocation(name: "The Upper Room",           lat: 31.771881, long: 35.229273, delta: 0.03)
              ,"Mount of Olives" :              BibleLocation(name: "Mount of Olives",          lat: 31.779249, long: 35.242738, delta: 0.10)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Gethsemane" :                   BibleLocation(name: "The Garden of Gethsemane", lat: 31.779656, long: 35.239645, delta: 0.03)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"courtyard" :                    BibleLocation(name: "Caiaphas' Palace",         lat: 31.773444, long: 35.229120, delta: 0.03)]
        ,
        "15":["over to Pilate" :                BibleLocation(name: "The Antonia Fortress",     lat: 31.780229, long: 35.233734, delta: 0.03)
              ,"governor's headquarters" :      BibleLocation(name: "The Antonia Fortress",     lat: 31.780229, long: 35.233734, delta: 0.03)
              ,"Cyrene" :                       BibleLocation(name: "Cyrene",                   lat: 32.803449, long: 21.862820, delta: 30.0)
              ,"Golgotha" :                     BibleLocation(name: "Golgotha (The Skull)",     lat: 31.778341, long: 35.229625, delta: 0.03)
              ,"The Place of a Skull" :         BibleLocation(name: "Golgotha (The Skull)",     lat: 31.778341, long: 35.229625, delta: 0.03)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Arimathea" :                    BibleLocation(name: "Arimathea",                lat: 31.952992, long: 34.889302, delta: 2.00)
              ,"Jesus' Tomb" :                  BibleLocation(name: "Jesus' Tomb",              lat: 31.778489, long: 35.229592, delta: 0.03)]
        ,
        "16":["Nazareth" :                      BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)]]
        ,
        "Luke" :
       ["1": ["Judea" :                         BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Nazareth" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"the wilderness" :               BibleLocation(name: "The Wilderness",           lat: 31.752365, long: 35.384903, delta: 1.00)]
        ,
        "2": ["Syria" :                         BibleLocation(name: "Syria",                    lat: 33.028743, long: 35.781097, delta: 1.00)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Nazareth" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Bethlehem" :                    BibleLocation(name: "Bethlehem",                lat: 31.705400, long: 35.202400, delta: 0.75)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)]
        ,
        "3": ["Judea" :                         BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Ituraea" :                      BibleLocation(name: "Ituraea (region)",         lat: 33.471401, long: 35.884094, delta: 1.00)
              ,"Trachonitis" :                  BibleLocation(name: "Trachonitis (region)",     lat: 33.246584, long: 36.323547, delta: 1.00)
              ,"Abilene" :                      BibleLocation(name: "Abilene (region)",         lat: 33.649922, long: 36.092834, delta: 1.00)
              ,"the wilderness" :               BibleLocation(name: "The Wilderness",           lat: 31.752365, long: 35.384903, delta: 1.00)
              ,"Jordan" :                       BibleLocation(name: "The Jordan River",         lat: 31.826748, long: 35.547091, delta: 1.00)]
        ,
        "4": ["Jordan" :                        BibleLocation(name: "The Jordan River",         lat: 31.826748, long: 35.547091, delta: 1.00)
              ,"the wilderness" :               BibleLocation(name: "The Wilderness",           lat: 31.752365, long: 35.384903, delta: 1.00)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Nazareth" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"Capernaum" :                    BibleLocation(name: "Capernaum",                lat: 32.880330, long: 35.573307, delta: 0.25)
              ,"hometown" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Sidon" :                        BibleLocation(name: "Sidon",                    lat: 33.557069, long: 35.372948, delta: 2.00)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)]
        ,
        "5": ["lake of Gennesaret" :            BibleLocation(name: "The Sea of Galilee",       lat: 32.824432, long: 35.587998, delta: 0.50)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)]
        ,
        "6": ["Judea" :                         BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Tyre" :                         BibleLocation(name: "Tyre",                     lat: 33.270492, long: 35.203763, delta: 2.00)
              ,"Sidon" :                        BibleLocation(name: "Sidon",                    lat: 33.557069, long: 35.372948, delta: 2.00)]
        ,
        "7": ["Capernaum" :                     BibleLocation(name: "Capernaum",                lat: 32.880330, long: 35.573307, delta: 0.25)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Nain" :                         BibleLocation(name: "Nain",                     lat: 32.633333, long: 35.350000, delta: 1.00)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"the wilderness" :               BibleLocation(name: "The Wilderness",           lat: 31.752365, long: 35.384903, delta: 1.00)]
        ,
        "8": ["country of the Gerasenes" :      BibleLocation(name: "The Gadarenes (Gerasenes)",lat: 32.832376, long: 35.646468, delta: 0.10)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)]
        ,
        "9": ["Bethsaida" :                     BibleLocation(name: "Bethsaida",                lat: 32.898486, long: 35.611496, delta: 0.25)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)]
        ,
        "10":["Sodom" :                         BibleLocation(name: "Sodom",                    lat: 31.282494, long: 35.552444, delta: 1.50)
              ,"Chorazin" :                     BibleLocation(name: "Chorazin",                 lat: 32.911389, long: 35.563889, delta: 0.25)
              ,"Bethsaida" :                    BibleLocation(name: "Bethsaida",                lat: 32.898486, long: 35.611496, delta: 0.25)
              ,"Tyre" :                         BibleLocation(name: "Tyre",                     lat: 33.270492, long: 35.203763, delta: 2.00)
              ,"Sidon" :                        BibleLocation(name: "Sidon",                    lat: 33.557069, long: 35.372948, delta: 2.00)
              ,"Capernaum" :                    BibleLocation(name: "Capernaum",                lat: 32.880330, long: 35.573307, delta: 0.25)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Jericho" :                      BibleLocation(name: "Jericho",                  lat: 31.856982, long: 35.460567, delta: 1.00)]
        ,
        "11":["Nineveh" :                       BibleLocation(name: "Nineveh",                  lat: 36.359444, long: 43.152778, delta: 10.0)
              ,"the South" :                    BibleLocation(name: "Sheba",                    lat: 15.416667, long: 45.350000, delta: 30.0)]
        ,
        "12":[:]
        ,
        "13":["Siloam" :                        BibleLocation(name: "Siloam",                   lat: 31.770081, long: 35.236158, delta: 0.03)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)]
        ,
        "14":[:]
        ,
        "15":[:]
        ,
        "16":[:]
        ,
        "17":["Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Samaria" :                      BibleLocation(name: "Samaria (region)",         lat: 32.374017, long: 35.246887, delta: 1.00)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Sodom" :                        BibleLocation(name: "Sodom",                    lat: 31.282494, long: 35.552444, delta: 1.50)]
        ,
        "18":["temple" :                        BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Jericho" :                      BibleLocation(name: "Jericho",                  lat: 31.856982, long: 35.460567, delta: 1.00)
              ,"Nazareth" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)]
        ,
        "19":["Jericho" :                       BibleLocation(name: "Jericho",                  lat: 31.856982, long: 35.460567, delta: 1.00)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Bethphage" :                    BibleLocation(name: "Bethphage",                lat: 31.777249, long: 35.250750, delta: 0.10)
              ,"Bethany" :                      BibleLocation(name: "Bethany",                  lat: 31.771411, long: 35.261325, delta: 0.10)
              ,"Mount of Olives" :              BibleLocation(name: "Mount of Olives",          lat: 31.779249, long: 35.242738, delta: 0.10)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)]
        ,
        "20":["temple" :                        BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)]
        ,
        "21":["temple" :                        BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"mount called Olivet" :          BibleLocation(name: "Mount of Olives",          lat: 31.779249, long: 35.242738, delta: 0.10)]
        ,
        "22":["upper room" :                    BibleLocation(name: "The Upper Room",           lat: 31.771881, long: 35.229273, delta: 0.03)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Mount of Olives" :              BibleLocation(name: "Mount of Olives",          lat: 31.779249, long: 35.242738, delta: 0.10)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"courtyard" :                    BibleLocation(name: "Caiaphas' Palace",         lat: 31.773444, long: 35.229120, delta: 0.03)]
        ,
        "23":["before Pilate" :                 BibleLocation(name: "The Antonia Fortress",     lat: 31.780229, long: 35.233734, delta: 0.03)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Cyrene" :                       BibleLocation(name: "Cyrene",                   lat: 32.803449, long: 21.862820, delta: 30.0)
              ,"The Skull" :                    BibleLocation(name: "Golgotha (The Skull)",     lat: 31.778341, long: 35.229625, delta: 0.03)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Arimathea" :                    BibleLocation(name: "Arimathea",                lat: 31.952992, long: 34.889302, delta: 2.00)
              ,"Jesus' Tomb" :                  BibleLocation(name: "Jesus' Tomb",              lat: 31.778489, long: 35.229592, delta: 0.03)]
        ,
        "24":["Galilee" :                       BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Emmaus" :                       BibleLocation(name: "Emmaus",                   lat: 31.839300, long: 34.989500, delta: 1.00)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Nazareth" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Bethany" :                      BibleLocation(name: "Bethany",                  lat: 31.771411, long: 35.261325, delta: 0.10)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)]]
        ,
        "John" :
       ["1": ["Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"the wilderness" :               BibleLocation(name: "The Wilderness",           lat: 31.752365, long: 35.384903, delta: 1.00)
              ,"Bethany across the Jordan":     BibleLocation(name: "Bethany across the Jordan",lat: 31.837109, long: 35.550301, delta: 0.75)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Bethsaida" :                    BibleLocation(name: "Bethsaida",                lat: 32.898486, long: 35.611496, delta: 0.25)
              ,"Nazareth" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)]
        ,
        "2": ["Cana" :                          BibleLocation(name: "Cana",                     lat: 33.209167, long: 35.299167, delta: 1.00)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Capernaum" :                    BibleLocation(name: "Capernaum",                lat: 32.880330, long: 35.573307, delta: 0.25)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)]
        ,
        "3": ["Israel" :                        BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"the wilderness" :               BibleLocation(name: "The Wilderness",           lat: 31.752365, long: 35.384903, delta: 1.00)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Aenon" :                        BibleLocation(name: "Aenon",                    lat: 32.343236, long: 35.553904, delta: 1.00)
              ,"Salim" :                        BibleLocation(name: "Salim",                    lat: 32.372676, long: 35.524979, delta: 1.00)
              ,"Jordan" :                       BibleLocation(name: "The Jordan River",         lat: 31.826748, long: 35.547091, delta: 1.00)]
        ,
        "4": ["Judea" :                         BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Samaria" :                      BibleLocation(name: "Samaria (region)",         lat: 32.374017, long: 35.246887, delta: 1.00)
              ,"Sychar" :                       BibleLocation(name: "Sychar",                   lat: 32.211944, long: 35.277778, delta: 1.00)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"hometown" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"Cana" :                         BibleLocation(name: "Cana",                     lat: 33.209167, long: 35.299167, delta: 1.00)
              ,"Capernaum" :                    BibleLocation(name: "Capernaum",                lat: 32.880330, long: 35.573307, delta: 0.25)]
        ,
        "5": ["Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Bethesda" :                     BibleLocation(name: "Pool of Bethesda",         lat: 31.781389, long: 35.235833, delta: 0.03)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)]
        ,
        "6": ["Sea of Galilee" :                BibleLocation(name: "The Sea of Galilee",       lat: 32.824432, long: 35.587998, delta: 0.50)
              ,"Sea of Tiberias" :              BibleLocation(name: "The Sea of Galilee",       lat: 32.824432, long: 35.587998, delta: 0.50)
              ,"Capernaum" :                    BibleLocation(name: "Capernaum",                lat: 32.880330, long: 35.573307, delta: 0.25)
              ,"Tiberias" :                     BibleLocation(name: "Tiberias",                 lat: 32.795859, long: 35.530973, delta: 0.25)
              ,"the wilderness" :               BibleLocation(name: "The Wilderness",           lat: 31.752365, long: 35.384903, delta: 1.00)]
        ,
        "7": ["Galilee" :                       BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Bethlehem" :                    BibleLocation(name: "Bethlehem",                lat: 31.705400, long: 35.202400, delta: 0.75)
        ]
        ,
        "8": ["Mount of Olives" :               BibleLocation(name: "Mount of Olives",          lat: 31.779249, long: 35.242738, delta: 0.10)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)]
        ,
        "9": ["Siloam" :                        BibleLocation(name: "Siloam",                   lat: 31.770081, long: 35.236158, delta: 0.03)]
        ,
        "10":["Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"across the Jordan" :            BibleLocation(name: "Bethany across the Jordan",lat: 31.837109, long: 35.550301, delta: 0.75)]
        ,
        "11":["Bethany" :                       BibleLocation(name: "Bethany",                  lat: 31.771411, long: 35.261325, delta: 0.10)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"the wilderness" :               BibleLocation(name: "The Wilderness",           lat: 31.752365, long: 35.384903, delta: 1.00)
              ,"Ephraim" :                      BibleLocation(name: "Ephraim",                  lat: 31.954444, long: 35.300278, delta: 1.00)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)]
        ,
        "12":["Bethany" :                       BibleLocation(name: "Bethany",                  lat: 31.771411, long: 35.261325, delta: 0.10)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Zion" :                         BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Bethsaida" :                    BibleLocation(name: "Bethsaida",                lat: 32.898486, long: 35.611496, delta: 0.25)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)]
        ,
        "13":[:]
        ,
        "14":[:]
        ,
        "15":[:]
        ,
        "16":[:]
        ,
        "17":[:]
        ,
        "18":["brook Kidron" :                  BibleLocation(name: "Kidron Valley",            lat: 31.773773, long: 35.238326, delta: 0.03)
              ,"garden" :                       BibleLocation(name: "The Garden of Gethsemane", lat: 31.779656, long: 35.239645, delta: 0.03)
              ,"Nazareth" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"courtyard" :                    BibleLocation(name: "Caiaphas' Palace",         lat: 31.773444, long: 35.229120, delta: 0.03)
              ,"house of Caiaphas" :            BibleLocation(name: "Caiaphas' Palace",         lat: 31.773444, long: 35.229120, delta: 0.03)
              ,"governor's headquarters" :      BibleLocation(name: "The Antonia Fortress",     lat: 31.780229, long: 35.233734, delta: 0.03)]
        ,
        "19":["The Stone Pavement" :            BibleLocation(name: "The Stone Pavement (Gabbatha)",lat: 31.780129, long: 35.233846, delta: 0.03)
              ,"Gabbatha" :                     BibleLocation(name: "The Stone Pavement (Gabbatha)",lat: 31.780129, long: 35.233846, delta: 0.03)
              ,"The Place of a Skull" :         BibleLocation(name: "Golgotha (The Skull)",     lat: 31.778341, long: 35.229625, delta: 0.03)
              ,"Golgotha" :                     BibleLocation(name: "Golgotha (The Skull)",     lat: 31.778341, long: 35.229625, delta: 0.03)
              ,"Arimathea" :                    BibleLocation(name: "Arimathea",                lat: 31.952992, long: 34.889302, delta: 2.00)
              ,"Jesus' Tomb" :                  BibleLocation(name: "Jesus' Tomb",              lat: 31.778489, long: 35.229592, delta: 0.03)]
        ,
        "20":[:]
        ,
        "21":["Sea of Tiberias" :               BibleLocation(name: "The Sea of Galilee",       lat: 32.824432, long: 35.587998, delta: 0.50)
              ,"Cana" :                         BibleLocation(name: "Cana",                     lat: 33.209167, long: 35.299167, delta: 1.00)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)]]
        ,
        "Acts" :
       ["1": ["Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Samaria" :                      BibleLocation(name: "Samaria (region)",         lat: 32.374017, long: 35.246887, delta: 1.00)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"mount called Olivet" :          BibleLocation(name: "Mount of Olives",          lat: 31.779249, long: 35.242738, delta: 0.10)
              ,"upper room" :                   BibleLocation(name: "The Upper Room",           lat: 31.771881, long: 35.229273, delta: 0.03)
        ]
        ,
        "2": ["Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Mesoppotamia" :                 BibleLocation(name: "Mesopotamia (region)",     lat: 34.405777, long: 42.319336, delta: 15.0)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Cappadocia" :                   BibleLocation(name: "Cappadocia (region)",      lat: 38.658333, long: 34.853611, delta: 15.0)
              ,"Pontus" :                       BibleLocation(name: "Pontus (region)",          lat: 40.600000, long: 38.000000, delta: 15.0)
              ,"Asia" :                         BibleLocation(name: "Asia Minor",               lat: 39.562294, long: 33.969727, delta: 15.0)
              ,"Phrygia" :                      BibleLocation(name: "Phrygia (region)",         lat: 39.000000, long: 31.000000, delta: 15.0)
              ,"Pamphylia" :                    BibleLocation(name: "Pamphylia (region)",       lat: 37.000000, long: 31.000000, delta: 15.0)
              ,"Egypt" :                        BibleLocation(name: "Egypt",                    lat: 30.787419, long: 31.821367, delta: 3.70)
              ,"Libya" :                        BibleLocation(name: "Libya",                    lat: 26.335100, long: 17.228331, delta: 15.0)
              ,"Cyrene" :                       BibleLocation(name: "Cyrene",                   lat: 32.803449, long: 21.862820, delta: 30.0)
              ,"Rome" :                         BibleLocation(name: "Rome",                     lat: 41.902783, long: 12.496366, delta: 13.0)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Nazareth" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)]
        ,
        "3": ["temple" :                        BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Nazareth" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)]
        ,
        "4": ["temple" :                        BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Nazareth" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"Cyprus" :                       BibleLocation(name: "Cyprus",                   lat: 35.000000, long: 33.000000, delta: 13.0)]
        ,
        "5": ["Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)]
        ,
        "6": ["Syrian Antioch" :                BibleLocation(name: "Syrian Antioch",           lat: 36.200000, long: 36.150000, delta: 15.0)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Cilicia" :                      BibleLocation(name: "Cilicia (region)",         lat: 37.000000, long: 35.000000, delta: 15.0)
              ,"Asia" :                         BibleLocation(name: "Asia Minor",               lat: 39.562294, long: 33.969727, delta: 15.0)
              ,"Nazareth" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)]
        ,
        "7": ["Mesoppotamia" :                  BibleLocation(name: "Mesopotamia (region)",     lat: 34.405777, long: 42.319336, delta: 15.0)
              ,"Haran" :                        BibleLocation(name: "Haran",                    lat: 36.877500, long: 39.033889, delta: 15.0)
              ,"land of the Chaldeans" :        BibleLocation(name: "Chaldea",                  lat: 32.708156, long: 46.867676, delta: 15.0)
              ,"Egypt" :                        BibleLocation(name: "Egypt",                    lat: 30.787419, long: 31.821367, delta: 3.70)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"the wilderness" :               BibleLocation(name: "Wilderness of Sin",        lat: 30.246908, long: 34.134521, delta: 15.0)
              ,"Babylon" :                      BibleLocation(name: "Babylon",                  lat: 32.536389, long: 44.420833, delta: 10.0)]
        ,
        "8": ["Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Samaria" :                      BibleLocation(name: "Samaria (region)",         lat: 32.374017, long: 35.246887, delta: 1.00)
              ,"Gaza" :                         BibleLocation(name: "Gaza",                     lat: 31.501695, long: 34.466844, delta: 15.0)
              ,"Azotus" :                       BibleLocation(name: "Azotus",                   lat: 31.800000, long: 34.650000, delta: 15.0)
              ,"Caesarea" :                     BibleLocation(name: "Caesarea",                 lat: 32.519016, long: 34.904544, delta: 15.0)]
        ,
        "9": ["Damascus" :                      BibleLocation(name: "Damascus",                 lat: 33.513807, long: 36.276528, delta: 15.0)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Tarsus" :                       BibleLocation(name: "Tarsus",                   lat: 36.916667, long: 34.895556, delta: 15.0)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Caesarea" :                     BibleLocation(name: "Caesarea",                 lat: 32.519016, long: 34.904544, delta: 15.0)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Samaria" :                      BibleLocation(name: "Samaria (region)",         lat: 32.374017, long: 35.246887, delta: 1.00)
              ,"Lydda" :                        BibleLocation(name: "Lydda",                    lat: 31.948497, long: 34.889000, delta: 15.0)
              ,"Sharon" :                       BibleLocation(name: "Plain of Sharon",          lat: 32.400000, long: 34.883000, delta: 15.0)
              ,"Joppa" :                        BibleLocation(name: "Joppa",                    lat: 32.050000, long: 34.750000, delta: 15.0)]
        ,
        "10":["Caesarea" :                      BibleLocation(name: "Caesarea",                 lat: 32.519016, long: 34.904544, delta: 15.0)
              ,"Joppa" :                        BibleLocation(name: "Joppa",                    lat: 32.050000, long: 34.750000, delta: 15.0)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Galilee" :                      BibleLocation(name: "Galilee (region)",         lat: 32.782007, long: 35.354004, delta: 3.00)
              ,"Nazareth" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)]
        ,
        "11":["Judea" :                         BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Caesarea" :                     BibleLocation(name: "Caesarea",                 lat: 32.519016, long: 34.904544, delta: 15.0)
              ,"Phoenicia" :                    BibleLocation(name: "Phoenicia (region)",       lat: 34.247568, long: 36.123047, delta: 15.0)
              ,"Cyprus" :                       BibleLocation(name: "Cyprus",                   lat: 35.000000, long: 33.000000, delta: 13.0)
              ,"Syrian Antioch" :               BibleLocation(name: "Syrian Antioch",           lat: 36.200000, long: 36.150000, delta: 15.0)
              ,"Cyrene" :                       BibleLocation(name: "Cyrene",                   lat: 32.803449, long: 21.862820, delta: 30.0)
              ,"Tarsus" :                       BibleLocation(name: "Tarsus",                   lat: 36.916667, long: 34.895556, delta: 15.0)]
        ,
        "12":["Judea" :                         BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Caesarea" :                     BibleLocation(name: "Caesarea",                 lat: 32.519016, long: 34.904544, delta: 15.0)
              ,"Tyre" :                         BibleLocation(name: "Tyre",                     lat: 33.270492, long: 35.203763, delta: 2.00)
              ,"Sidon" :                        BibleLocation(name: "Sidon",                    lat: 33.557069, long: 35.372948, delta: 2.00)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)]
        ,
        "13":["Syrian Antioch" :                BibleLocation(name: "Syrian Antioch",           lat: 36.200000, long: 36.150000, delta: 15.0)
              ,"Cyrene" :                       BibleLocation(name: "Cyrene",                   lat: 32.803449, long: 21.862820, delta: 30.0)
              ,"Seleucia" :                     BibleLocation(name: "Seleucia",                 lat: 36.123889, long: 35.921944, delta: 15.0)
              ,"Cyprus" :                       BibleLocation(name: "Cyprus",                   lat: 35.000000, long: 33.000000, delta: 13.0)
              ,"Salamis" :                      BibleLocation(name: "Salamis",                  lat: 35.183333, long: 33.900000, delta: 15.0)
              ,"Paphos" :                       BibleLocation(name: "Paphos",                   lat: 34.766667, long: 32.416667, delta: 15.0)
              ,"Perga" :                        BibleLocation(name: "Perga",                    lat: 36.961389, long: 30.853889, delta: 15.0)
              ,"Pamphylia" :                    BibleLocation(name: "Pamphylia (region)",       lat: 37.000000, long: 31.000000, delta: 15.0)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Pisidian Antioch" :             BibleLocation(name: "Pisidian Antioch",         lat: 38.306111, long: 31.189167, delta: 15.0)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Egypt" :                        BibleLocation(name: "Egypt",                    lat: 30.787419, long: 31.821367, delta: 3.70)
              ,"the wilderness" :               BibleLocation(name: "Wilderness of Sin",        lat: 30.246908, long: 34.134521, delta: 15.0)
              ,"Canaan" :                       BibleLocation(name: "Canaan (region)",          lat: 32.766700, long: 35.333300, delta: 15.0)
              ,"Galatia" :                      BibleLocation(name: "Galatia (region)",         lat: 40.000000, long: 33.500000, delta: 15.0)
              ,"Iconium" :                      BibleLocation(name: "Iconium",                  lat: 37.866667, long: 32.483333, delta: 15.0)]
        ,
        "14":["Iconium" :                       BibleLocation(name: "Iconium",                  lat: 37.866667, long: 32.483333, delta: 15.0)
              ,"Lystra" :                       BibleLocation(name: "Lystra",                   lat: 37.664119, long: 32.210711, delta: 15.0)
              ,"Derbe" :                        BibleLocation(name: "Derbe",                    lat: 37.438889, long: 33.163889, delta: 15.0)
              ,"Lycaonia" :                     BibleLocation(name: "Lycaonia (region)",        lat: 38.000000, long: 33.000000, delta: 15.0)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Pisidian Antioch" :             BibleLocation(name: "Pisidian Antioch",         lat: 38.306111, long: 31.189167, delta: 15.0)
              ,"Pisidia" :                      BibleLocation(name: "Pisidia (region)",         lat: 37.300000, long: 30.300000, delta: 15.0)
              ,"Pamphylia" :                    BibleLocation(name: "Pamphylia (region)",       lat: 37.000000, long: 31.000000, delta: 15.0)
              ,"Perga" :                        BibleLocation(name: "Perga",                    lat: 36.961389, long: 30.853889, delta: 15.0)
              ,"Attalia" :                      BibleLocation(name: "Attalia",                  lat: 36.900000, long: 30.683333, delta: 15.0)
              ,"Syrian Antioch" :               BibleLocation(name: "Syrian Antioch",           lat: 36.200000, long: 36.150000, delta: 15.0)]
        ,
        "15":["Judea" :                         BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Phoenicia" :                    BibleLocation(name: "Phoenicia (region)",       lat: 34.247568, long: 36.123047, delta: 15.0)
              ,"Samaria" :                      BibleLocation(name: "Samaria (region)",         lat: 32.374017, long: 35.246887, delta: 1.00)
              ,"Syrian Antioch" :               BibleLocation(name: "Syrian Antioch",           lat: 36.200000, long: 36.150000, delta: 15.0)
              ,"Syria" :                        BibleLocation(name: "Syria",                    lat: 33.028743, long: 35.781097, delta: 1.00)
              ,"Cilicia" :                      BibleLocation(name: "Cilicia (region)",         lat: 37.000000, long: 35.000000, delta: 15.0)
              ,"Pamphylia" :                    BibleLocation(name: "Pamphylia (region)",       lat: 37.000000, long: 31.000000, delta: 15.0)
              ,"Cyprus" :                       BibleLocation(name: "Cyprus",                   lat: 35.000000, long: 33.000000, delta: 13.0)]
        ,
        "16":["Derbe" :                         BibleLocation(name: "Derbe",                    lat: 37.438889, long: 33.163889, delta: 15.0)
              ,"Lystra" :                       BibleLocation(name: "Lystra",                   lat: 37.664119, long: 32.210711, delta: 15.0)
              ,"Iconium" :                      BibleLocation(name: "Iconium",                  lat: 37.866667, long: 32.483333, delta: 15.0)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Phrygia" :                      BibleLocation(name: "Phrygia (region)",         lat: 39.000000, long: 31.000000, delta: 15.0)
              ,"Galatia" :                      BibleLocation(name: "Galatia (region)",         lat: 40.000000, long: 33.500000, delta: 15.0)
              ,"Asia" :                         BibleLocation(name: "Asia Minor",               lat: 39.562294, long: 33.969727, delta: 15.0)
              ,"Mysia" :                        BibleLocation(name: "Mysia (region)",           lat: 40.000000, long: 28.500000, delta: 15.0)
              ,"Bithynia" :                     BibleLocation(name: "Bithynia (region)",        lat: 40.425519, long: 30.739746, delta: 15.0)
              ,"Troas" :                        BibleLocation(name: "Troas",                    lat: 39.751667, long: 26.158611, delta: 15.0)
              ,"Macedonia" :                    BibleLocation(name: "Macedonia (region)",       lat: 41.600000, long: 21.700000, delta: 15.0)
              ,"Samothrace" :                   BibleLocation(name: "Samothrace",               lat: 40.483333, long: 25.516667, delta: 15.0)
              ,"Neapolis" :                     BibleLocation(name: "Neapolis",                 lat: 40.933333, long: 24.400000, delta: 15.0)
              ,"Philippi" :                     BibleLocation(name: "Philippi",                 lat: 41.013056, long: 24.286389, delta: 15.0)]
        ,
        "17":["Amphipolis" :                    BibleLocation(name: "Amphipolis",               lat: 40.816667, long: 23.833333, delta: 15.0)
              ,"Apollonia" :                    BibleLocation(name: "Apollonia",                lat: 40.691963, long: 23.681030, delta: 15.0)
              ,"Thessalonica" :                 BibleLocation(name: "Thessalonica",             lat: 40.650000, long: 22.900000, delta: 12.0)
              ,"Berea" :                        BibleLocation(name: "Berea",                    lat: 40.308331, long: 22.170410, delta: 15.0)
              ,"Athens" :                       BibleLocation(name: "Athens",                   lat: 37.983810, long: 23.727539, delta: 15.0)]
        ,
        "18":["Athens" :                        BibleLocation(name: "Athens",                   lat: 37.983810, long: 23.727539, delta: 15.0)
              ,"Corinth" :                      BibleLocation(name: "Corinth",                  lat: 37.933333, long: 22.933333, delta: 15.0)
              ,"Pontus" :                       BibleLocation(name: "Pontus (region)",          lat: 40.600000, long: 38.000000, delta: 15.0)
              ,"Italy" :                        BibleLocation(name: "Italy",                    lat: 42.292421, long: 13.244019, delta: 15.0)
              ,"Rome" :                         BibleLocation(name: "Rome",                     lat: 41.902783, long: 12.496366, delta: 13.0)
              ,"Macedonia" :                    BibleLocation(name: "Macedonia (region)",       lat: 41.600000, long: 21.700000, delta: 15.0)
              ,"Achaia" :                       BibleLocation(name: "Achaia (region)",          lat: 38.834894, long: 21.994629, delta: 15.0)
              ,"Syria" :                        BibleLocation(name: "Syria",                    lat: 33.028743, long: 35.781097, delta: 1.00)
              ,"Cenchreae" :                    BibleLocation(name: "Cenchreae",                lat: 37.885000, long: 22.987500, delta: 15.0)
              ,"Ephesus" :                      BibleLocation(name: "Ephesus",                  lat: 37.795986, long: 27.288553, delta: 15.0)
              ,"Caesarea" :                     BibleLocation(name: "Caesarea",                 lat: 32.519016, long: 34.904544, delta: 15.0)
              ,"Syrian Antioch" :               BibleLocation(name: "Syrian Antioch",           lat: 36.200000, long: 36.150000, delta: 15.0)
              ,"Galatia" :                      BibleLocation(name: "Galatia (region)",         lat: 40.000000, long: 33.500000, delta: 15.0)
              ,"Phrygia" :                      BibleLocation(name: "Phrygia (region)",         lat: 39.000000, long: 31.000000, delta: 15.0)
              ,"Alexandria" :                   BibleLocation(name: "Alexandria",               lat: 31.200092, long: 29.918739, delta: 15.0)]
        ,
        "19":["Corinth" :                       BibleLocation(name: "Corinth",                  lat: 37.933333, long: 22.933333, delta: 15.0)
              ,"Ephesus" :                      BibleLocation(name: "Ephesus",                  lat: 37.795986, long: 27.288553, delta: 15.0)
              ,"Macedonia" :                    BibleLocation(name: "Macedonia (region)",       lat: 41.600000, long: 21.700000, delta: 15.0)
              ,"Achaia" :                       BibleLocation(name: "Achaia (region)",          lat: 38.834894, long: 21.994629, delta: 15.0)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Rome" :                         BibleLocation(name: "Rome",                     lat: 41.902783, long: 12.496366, delta: 13.0)
              ,"Asia" :                         BibleLocation(name: "Asia Minor",               lat: 39.562294, long: 33.969727, delta: 15.0)]
        ,
        "20":["Macedonia" :                     BibleLocation(name: "Macedonia (region)",       lat: 41.600000, long: 21.700000, delta: 15.0)
              ,"Greece" :                       BibleLocation(name: "Greece",                   lat: 39.074208, long: 21.824312, delta: 15.0)
              ,"Syria" :                        BibleLocation(name: "Syria",                    lat: 33.028743, long: 35.781097, delta: 1.00)
              ,"Berea" :                        BibleLocation(name: "Berea",                    lat: 40.308331, long: 22.170410, delta: 15.0)
              ,"Derbe" :                        BibleLocation(name: "Derbe",                    lat: 37.438889, long: 33.163889, delta: 15.0)
              ,"Troas" :                        BibleLocation(name: "Troas",                    lat: 39.751667, long: 26.158611, delta: 15.0)
              ,"Philippi" :                     BibleLocation(name: "Philippi",                 lat: 41.013056, long: 24.286389, delta: 15.0)
              ,"Assos" :                        BibleLocation(name: "Assos",                    lat: 39.487778, long: 26.336944, delta: 15.0)
              ,"Mitylene" :                     BibleLocation(name: "Mitylene",                 lat: 39.100000, long: 26.550000, delta: 15.0)
              ,"Chios" :                        BibleLocation(name: "Chios",                    lat: 38.400000, long: 26.016667, delta: 15.0)
              ,"Samos" :                        BibleLocation(name: "Samos",                    lat: 37.750000, long: 26.833333, delta: 15.0)
              ,"Miletus" :                      BibleLocation(name: "Miletus",                  lat: 37.530278, long: 27.278333, delta: 15.0)
              ,"Ephesus" :                      BibleLocation(name: "Ephesus",                  lat: 37.795986, long: 27.288553, delta: 15.0)
              ,"Asia" :                         BibleLocation(name: "Asia Minor",               lat: 39.562294, long: 33.969727, delta: 15.0)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)]
        ,
        "21":["Cos" :                           BibleLocation(name: "Cos",                      lat: 36.850000, long: 27.233333, delta: 15.0)
              ,"Rhodes" :                       BibleLocation(name: "Rhodes",                   lat: 36.166667, long: 28.000000, delta: 15.0)
              ,"Patara" :                       BibleLocation(name: "Patara",                   lat: 36.266217, long: 29.317222, delta: 15.0)
              ,"Phoenicia" :                    BibleLocation(name: "Phoenicia (region)",       lat: 34.247568, long: 36.123047, delta: 15.0)
              ,"Cyprus" :                       BibleLocation(name: "Cyprus",                   lat: 35.000000, long: 33.000000, delta: 13.0)
              ,"Syria" :                        BibleLocation(name: "Syria",                    lat: 33.028743, long: 35.781097, delta: 1.00)
              ,"Tyre" :                         BibleLocation(name: "Tyre",                     lat: 33.270492, long: 35.203763, delta: 2.00)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Ptolemais" :                    BibleLocation(name: "Ptolemais",                lat: 32.927778, long: 35.081667, delta: 15.0)
              ,"Caesarea" :                     BibleLocation(name: "Caesarea",                 lat: 32.519016, long: 34.904544, delta: 15.0)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Asia" :                         BibleLocation(name: "Asia Minor",               lat: 39.562294, long: 33.969727, delta: 15.0)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Egypt" :                        BibleLocation(name: "Egypt",                    lat: 30.787419, long: 31.821367, delta: 3.70)
              ,"Tarsus" :                       BibleLocation(name: "Tarsus",                   lat: 36.916667, long: 34.895556, delta: 15.0)
              ,"Cilicia" :                      BibleLocation(name: "Cilicia (region)",         lat: 37.000000, long: 35.000000, delta: 15.0)]
        ,
        "22":["Tarsus" :                        BibleLocation(name: "Tarsus",                   lat: 36.916667, long: 34.895556, delta: 15.0)
              ,"Cilicia" :                      BibleLocation(name: "Cilicia (region)",         lat: 37.000000, long: 35.000000, delta: 15.0)
              ,"Damascus" :                     BibleLocation(name: "Damascus",                 lat: 33.513807, long: 36.276528, delta: 15.0)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Nazareth" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)]
        ,
        "23":["Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Rome" :                         BibleLocation(name: "Rome",                     lat: 41.902783, long: 12.496366, delta: 13.0)
              ,"Caesarea" :                     BibleLocation(name: "Caesarea",                 lat: 32.519016, long: 34.904544, delta: 15.0)
              ,"Antipatris" :                   BibleLocation(name: "Antipatris",               lat: 32.105000, long: 34.930417, delta: 15.0)
              ,"Cilicia" :                      BibleLocation(name: "Cilicia (region)",         lat: 37.000000, long: 35.000000, delta: 15.0)]
        ,
        "24":["temple" :                        BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Asia" :                         BibleLocation(name: "Asia Minor",               lat: 39.562294, long: 33.969727, delta: 15.0)]
        ,
        "25":["Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Caesarea" :                     BibleLocation(name: "Caesarea",                 lat: 32.519016, long: 34.904544, delta: 15.0)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)]
        ,
        "26":["Jerusalem" :                     BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Nazareth" :                     BibleLocation(name: "Nazareth",                 lat: 32.699600, long: 35.303500, delta: 1.00)
              ,"Damascus" :                     BibleLocation(name: "Damascus",                 lat: 33.513807, long: 36.276528, delta: 15.0)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)
              ,"temple" :                       BibleLocation(name: "The Temple",               lat: 31.778393, long: 35.235386, delta: 0.03)]
        ,
        "27":["Adramyttium" :                   BibleLocation(name: "Adramyttium",              lat: 39.592222, long: 27.020000, delta: 15.0)
              ,"Asia" :                         BibleLocation(name: "Asia Minor",               lat: 39.562294, long: 33.969727, delta: 15.0)
              ,"Macedonia" :                    BibleLocation(name: "Macedonia (region)",       lat: 41.600000, long: 21.700000, delta: 15.0)
              ,"Thessalonica" :                 BibleLocation(name: "Thessalonica",             lat: 40.650000, long: 22.900000, delta: 12.0)
              ,"Sidon" :                        BibleLocation(name: "Sidon",                    lat: 33.557069, long: 35.372948, delta: 2.00)
              ,"Cyprus" :                       BibleLocation(name: "Cyprus",                   lat: 35.000000, long: 33.000000, delta: 13.0)
              ,"Cilicia" :                      BibleLocation(name: "Cilicia (region)",         lat: 37.000000, long: 35.000000, delta: 15.0)
              ,"Pamphylia" :                    BibleLocation(name: "Pamphylia (region)",       lat: 37.000000, long: 31.000000, delta: 15.0)
              ,"Myra" :                         BibleLocation(name: "Myra",                     lat: 36.259061, long: 29.985175, delta: 15.0)
              ,"Lycia" :                        BibleLocation(name: "Lycia",                    lat: 36.733333, long: 29.900000, delta: 15.0)
              ,"Alexandria" :                   BibleLocation(name: "Alexandria",               lat: 31.200092, long: 29.918739, delta: 15.0)
              ,"Italy" :                        BibleLocation(name: "Italy",                    lat: 42.292421, long: 13.244019, delta: 15.0)
              ,"Cnidus" :                       BibleLocation(name: "Cnidus",                   lat: 36.685833, long: 27.375000, delta: 15.0)
              ,"Crete" :                        BibleLocation(name: "Crete",                    lat: 35.210000, long: 24.910000, delta: 15.0)
              ,"Salmone" :                      BibleLocation(name: "Salmone",                  lat: 35.312222, long: 26.304722, delta: 15.0)
              ,"Fair Havens" :                  BibleLocation(name: "Fair Havens",              lat: 34.950609, long: 24.771423, delta: 15.0)
              ,"Lasea" :                        BibleLocation(name: "Lasea",                    lat: 34.993371, long: 25.166931, delta: 15.0)
              ,"Phoenix" :                      BibleLocation(name: "Phoenix",                  lat: 35.200000, long: 24.083333, delta: 15.0)
              ,"Cauda" :                        BibleLocation(name: "Cauda",                    lat: 34.833333, long: 24.083333, delta: 15.0)]
        ,
        "28":["Malta" :                         BibleLocation(name: "Malta",                    lat: 35.885833, long: 14.403056, delta: 15.0)
              ,"Alexandria" :                   BibleLocation(name: "Alexandria",               lat: 31.200092, long: 29.918739, delta: 15.0)
              ,"Syracuse" :                     BibleLocation(name: "Syracuse",                 lat: 37.083333, long: 15.283333, delta: 15.0)
              ,"Rhegium" :                      BibleLocation(name: "Rhegium",                  lat: 38.111389, long: 15.661944, delta: 15.0)
              ,"Puteoli" :                      BibleLocation(name: "Puteoli",                  lat: 40.844444, long: 14.093333, delta: 13.0)
              ,"Rome" :                         BibleLocation(name: "Rome",                     lat: 41.902783, long: 12.496366, delta: 13.0)
              ,"Forum of Appius" :              BibleLocation(name: "Forum of Appius",          lat: 41.349753, long: 13.568115, delta: 13.0)
              ,"Three Taverns" :                BibleLocation(name: "Three Taverns",            lat: 41.423936, long: 13.018799, delta: 13.0)
              ,"Jerusalem" :                    BibleLocation(name: "Jerusalem",                lat: 31.768300, long: 35.213700, delta: 0.75)
              ,"Israel" :                       BibleLocation(name: "Israel",                   lat: 32.107879, long: 35.167236, delta: 5.00)
              ,"Judea" :                        BibleLocation(name: "Judea (region)",           lat: 31.577219, long: 35.002441, delta: 3.00)]]
    ]
    
    
}
