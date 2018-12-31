//
//  Actions.swift
//  Actions
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public protocol Action: GenericAction { }
public protocol SyncAction: GenericAction {
    associatedtype ReturnType
}
public protocol AsyncAction: GenericAction {
    associatedtype ReturnType = Void
}

public protocol GenericAction { }

extension GenericAction {
    static var actionID: String {
        return String(reflecting: self)
    }
}
