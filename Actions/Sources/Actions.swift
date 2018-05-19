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
    associatedtype ParamType = Void
    var param: ParamType { get }

    associatedtype ReturnType = Void
}

extension GenericAction {
    static var actionID: String {
        return String(reflecting: self)
    }
}

extension GenericAction where ParamType == Void {
    public var param: Void { return }
}

extension Action {
    public func send() -> ReturnType {
        return ActionsRouter.instance.send(action: self)
    }
}

extension AsyncAction {
    public func async(completion: @escaping (ReturnType) -> Void) {
        ActionsRouter.instance.async(action: self, completion: completion)
    }
}
