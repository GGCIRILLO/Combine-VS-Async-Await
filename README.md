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

### How did I implemented it? 
The `TeamsVM` class is responsible for fetching NBA team data from the BallDontLie API. It utilizes the async/await pattern to perform asynchronous operations and handle potential errors that may occur during the process. The `@Observable` macro is typically used in SwiftUI to mark properties as observable, allowing SwiftUI to update views based on changes to the observable properties that a view’s body reads instead of any property changes that occur to an observable object, which can help improve your app’s performance.

The `getTeams()` function is the entry point for fetching team data. It calls the `fetchData()` function to retrieve raw data from the API endpoint. If successful, it then calls the `parseTeamsResponse()` function to decode the data into a `TeamsModel` object containing the relevant team information. Any errors encountered during these steps are propagated using Swift's error handling mechanism. 
``` swift
func getTeams () async throws -> TeamsModel {
        do {
            let data = try await fetchData()
            let teams = try parseTeamsResponse(data)
            return teams
        } catch {
            throw error
        }
    }

```
In the `fetchData()` function, a URLRequest is created with the API endpoint URL and necessary headers, including the API key. The URLSession is then used to asynchronously fetch data from the provided URL. Upon receiving the response, it checks for HTTP status code 200 to ensure a successful response. If any errors occur during the network request or parsing, appropriate errors are thrown to be handled by the caller.
``` swift
private func fetchData() async throws -> Data {
        guard let url = URL(string: "https://api.balldontlie.io/v1/teams") else {
            throw TeamsError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("\(Constants.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, res) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = res as? HTTPURLResponse else {
                throw TeamsError.invalidResponse
            }

            guard httpResponse.statusCode == 200 else {
                throw TeamsError.invalidStatusCode(httpResponse.statusCode)
            }

            return data
        } catch {
            throw TeamsError.networkError(error)
        }
    }
```
Finally, the `parseTeamsResponse()` function decodes the received data into a `TeamsModel` object using JSONDecoder. Any decoding errors are caught and rethrown as `TeamsError.decodingError`.
``` swift
private func parseTeamsResponse(_ data:Data) throws -> TeamsModel {
        do {
            let teams = try JSONDecoder().decode(TeamsModel.self, from: data)
            return teams
        } catch {
            throw TeamsError.decodingError(error)
        }
    }
```



