//
//  ContactNotifiableType.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 15/05/22.
//

import GameplayKit

protocol ContactNotifiableType {

    func contactWithEntityDidBegin(_ entity: GKEntity)
    
    func contactWithEntityDidEnd(_ entity: GKEntity)
}
