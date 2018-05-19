//
//  ActionsHandler.swift
//  Actions
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public typealias ActionsHandler = SyncActionsHandler & AsyncActionsHandler

public protocol SyncActionsHandler {
    func handle<Act: Action>(action: Act) -> Act.ReturnType
}

public protocol AsyncActionsHandler {
    func handle<Act: AsyncAction>(action: Act, completion: @escaping (Act.ReturnType) -> Void)
}
