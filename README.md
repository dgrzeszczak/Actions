# Actions

*Action* represent something that has to be done. It may be whatever you need like *ShowHomeScreenAction*, *FetchUserDataAction* etc. Each action may take parameters and may return values. 

We have two kind of actions:
* synchronous ations (```Action```)   
* asynchronous actions (```AsyncAction```). 

The most basic action with no parameters and no return value will look like:
```swift
struct ShowMainScreen: Action { }
```

Action with integer parameter may look like
```swift
struct ShowProfileScreen: Action {
    let param: Int // user's profile id
}
```

Async action that fetch user profile may look like:
```swift
struct FetchUserProfile: AsyncAction {
    let param: Int // user's profile id
    typealias ReturnType = UserProfile
}
```

Before we can use the action we have to register handler in ActionDispatcher for that action eg. 

```swift
let dispatcher = ActionsDispatcher()
dispatcher.register(action: ShowMainScreen.self) {  ... }
dispatcher.register(action: ShowProfileScreen.self) { id in ... }
dispatcher.register(action: FetchUserProfile.self) { id, completion in ... }
dispatcher.register(action: MultipleIntByTwo.self) { number in return number * 2 }
```
Then you can dispatch your action easily:
```swift
dispatcher.dispatch(ShowHomeScreen())
dispatcher.dispatch(ShowProfileScreen(param: 3))
dispatcher.dispatch(FetchUserProfile(param: 3)) { userProfile in ... }
let result = dispatcher.dispatch(MultipleIntByTwo(param: 4))
```
## Router

Examples above shows that you need the reference to the dispatcher which can handle the action. In case you have couple of dispatchers you have to remember which dispatcher should be used for specific action. Wouldn't be nice just to send the action from any place in the app without the reference to dispatcher ? Good news - YOU CAN ! By default all dispatchers are added to the *router* (it can be disabled by setting ```routingEnabled``` parameter to ```false``` in ```ActionDispatcher``` constructor). The goal of the router is to "route" action to proper dispatcher. In consequence you can call the actions like that: 

```swift
ShowHomeScreen().send()
ShowProfileScreen(param: 3).send()
FetchUserProfile(param: 3).async { userProfile in ... }
let result = MultipleIntByTwo(param: 4).send() 
```

## Comparison to Events

Someone can notice that concept is similar to well known *Events*. What is a difference between actions and events? 
1. action has to be handled in one and only one place, events may be handled in many places or may not be handled at all
    * each action has to be handled
    * registering the same action more than once is not allowed
2. actions can return values in synchronous or asynchronous manner, events cannot return any values

## Coordinator implementation with Actions

The idea for *Actions* framework came with a need to implement "clean" coordinators in iOS applications. Usually coordinators are implemented as class or struct with various methods that can be used to change "application state". The questions appear quickly. How should we pass coordinator to controllers ? Should we use dependecy injection, should we use prepareForSegue or maybe should we make coordinator as singleton or global variable in the app? What's more, if you want to split your project to smaller functional modules you need to create more coordinators backed by protocols describing their public interfaces - what of course works but ... brings additional questions :) Is it possible to distinguish internal methods (for module) from public ones ? 

... Of course there is a lot of place for discussion but ...

All above can be solved by *Actions*. You can declare public and internal Actions just by using swift modifiers. You don't need to pass any reference of your coordinator(s). Just use routable dispatcher (default) and it will just work. The only thing you need to remember is to keep somehere the reference to your dispatcher because router keeps weak references. 

Very simple (and naive) coordinator may look like this:

```swift
struct MyWireframe {

    private let navigationController: UINavigationController
    private let dispatcher = ActionsDispatcher()
    
    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    
        dispatcher.register(action: ShowHomeScreen.self) { [unowned self] in self.showHome() }
        dispatcher.register(action: ShowProfileScreen.self) { [unowned self] in self.showProfile(with: $0) }
    }
    
    private func showHome() {
        let homeController = HomeViewController() 
        navigationController.setViewControllers(homeController, animated: true)
    }
    
    private func showProfile(with id: Int) {
        let detailsController = DetailsViewController(with: id)
        navigationController.pushViewController(detailsController, animated: true)
    }
}
```

In app delegate you can add property:
```swift
private var coordinators: [Any]?
```

Keep all references there:
```swift
coordinators = [MyWireframe(with: navigation), MyWireframe2(with: navigation)]
```

and .... "anywhere" in your code you can show home screen just by calling:
```swift
ShowHome().send()
``` 

