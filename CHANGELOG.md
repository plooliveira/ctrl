## 0.1.1
 - update README.md
 
## 0.1.0

**Initial Release** 🎉

### Features

#### Core Components
* **Observable**: Enhanced `ChangeNotifier` implementation with value holding and smart change detection
  * Custom equality logic via `changeDetector`
  * `reload()` method to force notifications
  * `emitAll` option to notify even when value hasn't changed
* **Scopes**: Lifecycle management system for observables
  * Automatic initialization and disposal linked to widget lifecycle
  * Hierarchical scope inheritance for dependent observables
* **Ctrl Mixin**: Base mixin for creating controllers/view models/stores
  * `mutable<T>()` method to create scoped observables
  * Automatic scope management

#### Widgets
* **CtrlWidget**: Simplified widget for single state manager class 
  * Automatic ctrl creation and disposal
  * Ctrl passed directly to build method
* **CtrlState**: Stateful widget mixin for complex scenarios
  * Support for multiple state managers via `useCtrl<T>()`
  * Full access to State lifecycle methods
  * Compatible with other mixins (animations, text controllers, etc.)
* **Watch**: Widget to observe and rebuild on observable changes

#### Advanced Observable Features
* **update**: Update complex observable objects
* **transform**: Create derived observables that auto-update from source
* **mirror**: Create read-only views of mutable observables
* **hotswappable**: Dynamically switch underlying observable sources
* **filtered**: (Lists) Create filtered observable lists
* **notNull**: (Lists) Remove null values from observable lists

#### Dependency Injection
* Built-in service locator (`Locator`)
  * Factory registration support
  * Singleton registration support
  * `i()` shortcut for dependency injection
* Custom DI integration support
  * Override `resolveCtrl()` in `CtrlWidget`
  * Pass instances directly to `useCtrl()` in `CtrlState`

### Architecture
* **Pattern Agnostic**: Works with MVC, MVVM, MVP, and other patterns
* **Cascade State Composition**: Isolated state management with unidirectional data flow
* **Lifecycle Safety**: Automatic cleanup prevents memory leaks

### Documentation
* Comprehensive README with usage examples
* Code examples for common scenarios
* Architecture decision documentation
