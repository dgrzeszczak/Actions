//
//  ActionsDispatcher.swift
//  Actions
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public protocol ActionDispatcher {
    func dispatch(action: Action)
}

public protocol SyncActionDispatcher {
    func dispatch<Act: SyncAction>(action: Act) -> Act.ReturnType
}

public protocol AsyncActionDispatcher {
    func dispatch<Act: AsyncAction>(action: Act, completion: @escaping (Act.ReturnType) -> Void)
}

public final class ActionsDispatcher: ActionDispatcher, SyncActionDispatcher, AsyncActionDispatcher {

    private var handlers: [String: Any] =  [:]
    var actions: [String] {
        return handlers.map { $0.key }
    }

    public let routingEnabled: Bool
    public init(routingEnabled: Bool = true) {
        self.routingEnabled = routingEnabled
        guard routingEnabled else { return }
        ActionsRouter.instance.add(dispatcher: self)
    }

    private func add(handler: Any, for action: GenericAction.Type) {
        let actionID = action.actionID
        if routingEnabled && action is Routable.Type && ActionsRouter.instance.contains(actionID: actionID) {
            fatalError("Doubled action: \(actionID). The same Action cannot be handled by two different handlers.")
        }
        handlers[actionID] = handler
    }

    public func register<Act: Action>(action: Act.Type, handler: @escaping (Act) -> Void) {
        let han: (Action) -> Void = { action in
            handler(action as! Act)
        }
        add(handler: han, for:  action)
    }

    public func dispatch(action: Action) {
        guard let handler = handlers[type(of: action).actionID] as? ((Action) -> Void) else {
            fatalError("Unsuported action")
        }

        return handler(action)
    }

    public func register<Act: SyncAction>(action: Act.Type, handler: @escaping (Act) -> Act.ReturnType) {
        add(handler: handler, for:  action)
    }

    public func dispatch<Act: SyncAction>(action: Act) -> Act.ReturnType {
        guard let handler = handlers[type(of: action).actionID] as? ((Act) -> Act.ReturnType) else {
            fatalError("Unsuported action")
        }

        return handler(action)
    }

    public func register<Act: AsyncAction>(action: Act.Type,
                                           handler: @escaping (Act, _ completion: @escaping (Act.ReturnType) -> Void) -> Void) {
        add(handler: handler, for: action)
    }

    public func dispatch<Act: AsyncAction>(action: Act, completion: @escaping (Act.ReturnType) -> Void) {
        guard let handler = handlers[type(of: action).actionID]
            as? ((Act, _ completion: @escaping (Act.ReturnType) -> Void) -> Void) else {

                fatalError("Unsuported action")
        }

        handler(action, completion)
    }

    public func supports(action: GenericAction.Type) -> Bool {
        return actions.contains(action.actionID)
    }

    public func supports(action: GenericAction) -> Bool {
        return supports(action: type(of: action))
    }

    // registration actions handlers
    public func register<Handler: ActionHandler>(handler: Handler) {
        register(action: Handler.Act.self, handler: handler.handle)
    }

    public func register<Handler: AsyncActionHandler>(handler: Handler) {
        register(action: Handler.Act.self, handler: handler.handle)
    }

    public func register<Handler: SyncActionHandler>(handler: Handler) {
        register(action: Handler.Act.self, handler: handler.handle)
    }
}
