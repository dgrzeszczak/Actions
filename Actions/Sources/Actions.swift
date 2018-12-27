//
//  Actions.swift
//  Actions
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public protocol Action: GenericAction { }
public protocol AsyncAction: GenericAction { }

public protocol GenericAction {
    associatedtype ReturnType = Void
}

extension GenericAction {
    static var actionID: String {
        return String(reflecting: self)
    }
}
