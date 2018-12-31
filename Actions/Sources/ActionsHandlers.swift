//
//  ActionsHandlers.swift
//  Actions
//
//  Created by Grzegorz Jurzak on 05/12/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public protocol ActionHandler {

    associatedtype Act: Action

    func handle(action: Act)

}

public protocol SyncActionHandler {

    associatedtype Act: SyncAction

    func handle(action: Act) -> Act.ReturnType

}

public protocol AsyncActionHandler {

    associatedtype Act: AsyncAction

    func handle(action: Act, completion: @escaping (Act.ReturnType) -> Void)

}
