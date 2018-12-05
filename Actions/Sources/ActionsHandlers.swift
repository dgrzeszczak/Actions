//
//  ActionsHandlers.swift
//  Actions
//
//  Created by Grzegorz Jurzak on 05/12/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public protocol ActionHandler {

    associatedtype Act: Action

    func handle(param: Act.ParamType) -> Act.ReturnType

}

public protocol AsyncActionHandler {

    associatedtype Act: AsyncAction

    func handle(param: Act.ParamType, completion: @escaping (Act.ReturnType) -> Void)

}

