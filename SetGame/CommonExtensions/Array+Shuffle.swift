//
//  Array+Shuffle.swift
//  Concentration
//
//  Created by Pablo Leite on 01/07/2018.
//  Copyright © 2018 Pablo Cobucci Leite. All rights reserved.
//

import Foundation

extension Array {
    
    mutating func shuffle() {
        var shuffledCollection = [Element]()
        while !isEmpty {
            shuffledCollection.append(remove(at: Int.random(count)))
        }
        self = shuffledCollection
    }
    
    func shuffled() -> Array<Element> {
        var mutatingSelf = self //Swift will create a copy (Array is a struct), so self won't be modified
        mutatingSelf.shuffle()
        return mutatingSelf
    }
}
