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
    public func send() {
        return ActionsRouter.instance.send(action: self)
    }
}

extension Routable where Self: SyncAction {
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

    private func dispatcher(for action: GenericAction) -> ActionsDispatcher {
        guard let dispatcher = dispatchers.allObjects.first(where: { $0.actions.contains(type(of: action).actionID) }) else {
            fatalError("There is no handler registered for \(type(of: action).actionID)")
        }
        return dispatcher
    }

    func send(action: Action) {
        return dispatcher(for: action).dispatch(action: action)
    }

    func send<Act: SyncAction>(action: Act) -> Act.ReturnType {
        return dispatcher(for: action).dispatch(action: action)
    }

    func async<Act: AsyncAction>(action: Act, completion: @escaping (Act.ReturnType) -> Void) {
        dispatcher(for: action).dispatch(action: action, completion: completion)
    }
}
