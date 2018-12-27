//
//  ActionsRouter.swift
//  Actions
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

public protocol Routable {
    static var isRegistered: Bool { get }
}

public extension Routable where Self: GenericAction {
    static var isRegistered: Bool {
        return ActionsRouter.instance.contains(actionID: actionID)
    }
}

extension Routable where Self: Action {
    public func send() -> ReturnType {
        return ActionsRouter.instance.send(action: self)
    }
}

extension Routable where Self: AsyncAction {
    public func async(completion: @escaping (ReturnType) -> Void) {
        ActionsRouter.instance.async(action: self, completion: completion)
    }
}

final class ActionsRouter {

    static let instance = ActionsRouter()

    private var dispatchers = NSHashTable<ActionsDispatcher>.weakObjects()

    func add(dispatcher: ActionsDispatcher) {
        let actions = dispatchers.allObjects.flatMap { $0.actions }
        guard Set(actions).isDisjoint(with: dispatcher.actions) else {
            fatalError("Doubled actions. The same Action cannot be handled by two different handlers.")
        }
        dispatchers.add(dispatcher)
    }

    func contains(actionID: String) -> Bool {
        return dispatchers.allObjects.flatMap { $0.actions }.contains(actionID)
    }

    func send<Act: Action>(action: Act) -> Act.ReturnType {
        // think about fatal error ? should it be silent maybe ? or maybe we should throw exception instead ?
        guard let handler = dispatchers.allObjects.first(where: { $0.actions.contains(type(of: action).actionID) }) else {
            fatalError("There is no handler registered for \(type(of: action).actionID)")
        }

        return handler.dispatch(action: action)
    }

    func async<Act: AsyncAction>(action: Act, completion: @escaping (Act.ReturnType) -> Void) {
        guard let handler = dispatchers.allObjects.first(where: { $0.actions.contains(type(of: action).actionID) }) else {
            fatalError("There is no handler registered for \(type(of: action).actionID)")
        }

        handler.dispatch(action: action, completion: completion)
    }
}
