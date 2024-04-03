# NBA Stats App: Combine or Async/Await?
This iOS app is built using the BallDontLie API to retrieve NBA teams, players, and season average stats. The app provides a simple interface to view team details and player information.

## Features 
- View NBA team details
- Scroll through players for each team
- Read player details including name, surname, height, weight, number, and position
- Utilizes iOS 17 scroll APIs for smooth scrolling and interaction
- Team card expands when scrolling up to view players, creating a modal-like view
- Horizontal scrolling to switch between teams with magnetic effect
- Every data is taken thanks to the [BallDontLie api](https://new.balldontlie.io). It were used the Combine framework and the Async/Await protocol

## API Call Comparison

### Async/Await Protocol
The async/await protocol is a programming paradigm introduced in Swift to simplify asynchronous programming. 
In essence, async/await enables functions to be marked as asynchronous using the `async` keyword. This indicates that the function will perform 
some long-running task asynchronously, such as fetching data from a network or performing heavy computations, without blocking the main thread. 
Within an asynchronous function, you can use the `await` keyword to suspend execution until an asynchronous operation completes.

Here's how async/await works:
1. **Async Function Declaration**: You mark a function as asynchronous by prefixing its declaration with the `async` keyword and optionally specifying
that it throws errors using the `throws` keyword. For example:
``` swift
func fetchData() async throws -> Data {
    // Asynchronous code here
}
```
2. **Awaiting Asynchronous Operations**: Inside an asynchronous function, you use the `await` keyword to suspend execution until an asynchronous operation completes.
This operation could be anything that returns a value asynchronously, such as a network request or a time-consuming computation.
You can use the `try` keyword before the await expression to handle any errors that might be thrown by the asynchronous operation. For example:
```swift
let data = try await fetchData()
```
3. **Concurrency**: When an asynchronous function encounters an `await` expression, it temporarily suspends its execution, allowing other tasks to run concurrently.
This prevents blocking the main thread and keeps the app responsive.
4. **Error Handling**: Async/await simplifies error handling by allowing you to use `try`, `catch`, and `throw` keywords just like in synchronous code.
If an asynchronous operation throws an error, you can catch it using a `do-catch` block.



