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
Overall, this code efficiently handles asynchronous network requests, parsing JSON responses, and error handling to provide a robust mechanism for fetching NBA team data from the BallDontLie API. The same approach is used for players and stats. 

### How did I used this data in a view?
You need to call the function just written as a task, but how? First we will declare an instance of the class `TeamVM` and a `teams` empty array, both marked as a `@State`, a property wrapper type that can read and write a value managed by SwiftUI.
``` swift
@State private var teamsVM = TeamsVM()
@State private var teams : [Team] = []
```
Then just perform the function in a task:
``` swift
.task {
    // Async/Await
    do {
        let newTeams = try await teamsVM.getTeams()
        teams = newTeams.data
        // Look at the Json file and App Models for further explanation about this assegnation
    } catch{
        print(error)
    }
}
```
Job is done! You can now easily use the data thanks to the teams array taht will contain all the `teams` in this case. For example: 
``` swift
ForEach(teams) { team in
    Text(team.fullName)
}
```
### Combine 
The Combine framework is a powerful framework introduced by Apple, starting with iOS 13, that provides a declarative Swift API for processing values over time. It enables you to work with asynchronous and event-based code in a more functional and reactive manner.

At its core, Combine revolves around three main components:
1. **Publishers**: Publishers represent a sequence of values over time. They can emit values of a specific type, including asynchronous events such as network requests, user input, timers, and notifications.
2. **Operators**: Operators are methods that allow you to transform, filter, or combine values emitted by publishers. Operators can be chained together to create complex data processing pipelines.
3. **Subscribers**: Subscribers receive and react to values emitted by publishers. They define what should happen when a new value is produced, including updating UI, performing side effects, or forwarding values to other publishers.

Here it's how Combine works with Api calls: [Medium Article](https://medium.com/@itsachin523/api-calls-with-ios-combine-cb917f9b4a62).

### How did I implemented it? 
First we need to create a service to make API calls. `TeamsService` is the class responsible for fetching teams data from a remote API. It defines an `enum TeamsError` to represent various error cases that might occur during the API request and response handling.
The `getTeams()` method returns a publisher that emits a `TeamsModel` object or an error (`Error`). It's annotated with `-> AnyPublisher<TeamsModel, Error>`, indicating that it returns a publisher with a generic value of `TeamsModel` and an error of `Error`.
``` swift
func getTeams() -> AnyPublisher<TeamsModel, Error> {
    // Code logic here
}
```
First thing first, in the function, it constructs the URL for the API endpoint (`https://api.balldontlie.io/v1/teams`). If the URL construction fails, it returns a publisher with a failure using `Fail(error:)`.
``` swift
guard let url = URL(string: "https://api.balldontlie.io/v1/teams") else {
            return Fail(error: TeamsError.invalidURL).eraseToAnyPublisher()
    }
```
It then creates a `URLRequest` with the constructed URL, sets the HTTP method to GET, and adds an authorization header using the provided API key.
``` swift
var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("\(Constants.apiKey)", forHTTPHeaderField: "Authorization")
``` 
The method uses `URLSession.shared.dataTaskPublisher(for:)` to create a publisher for performing the network request. It then processes the response data using various Combine operators: 
- **tryMap**: Maps the `(Data, URLResponse)` tuple to just the `Data`, throwing an error if the response is not of type `HTTPURLResponse` or if the status code is not 200.
- **decode**: Decodes the received data into a `TeamsModel` object using `JSONDecoder`.
- **mapError**: Maps any errors encountered during the process to `TeamsError.networkError` if they are not already of type `TeamsError`.
- **eraseToAnyPublisher**: Erases the type of the publisher to `AnyPublisher<TeamsModel, Error>` to hide implementation details and ensure type safety.
Finally, the method returns the resulting publisher.
``` swift
return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw TeamsError.invalidResponse
                }
                
                guard httpResponse.statusCode == 200 else {
                    throw TeamsError.invalidStatusCode(httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: TeamsModel.self, decoder: JSONDecoder())
            .mapError { error in
                if let teamsError = error as? TeamsError {
                    return teamsError
                } else {
                    return TeamsError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    } // closing the function
} // closing the class
```

Now, let's move to our View Model.
The `TeamsVMCombine` class is our view model and it is annotatds with `@Observable`. This implies that instances of this class are observable objects, allowing SwiftUI views to observe and react to changes in its properties.
Then we declare some properties: 
- **`private var cancellables = Set<AnyCancellable>()`**: This property is a set to hold Combine cancellable objects, which are responsible for canceling subscriptions to publishers when they are no longer needed. It's marked as private to encapsulate its access within the class.
- **`private let teamsService = TeamsService()`**: This property holds an instance of TeamsService, which is responsible for fetching teams data from the remote API.
- **`var teams: [Team] = []`**: This property holds an array of Team objects fetched from the API. It's initialized as an empty array.
- **`var errorMessage: String?`**: This optional property holds an error message string if an error occurs during the API request.
```swift
@Observable class TeamsVMCombine {
        private var cancellables = Set<AnyCancellable>()
        private let teamsService = TeamsService()
        var teams: [Team] = []
        var errorMessage: String?
        // code logic here
}
```
Then there is the `fetchTeams()` method.  It is responsible for initiating the process of fetching teams data from the remote API. It calls the `getTeams()` method of the `teamsService`, which returns a publisher that emits a `TeamsModel` object or an `error`.
The method uses Combine operators to handle the publisher's output:
- **`.receive(on: DispatchQueue.main)`**: This operator specifies that subsequent operations should occur on the main thread, ensuring that UI updates are performed on the main thread.
- **`.sink(receiveCompletion:receiveValue:)`**: This operator subscribes to the publisher and defines closures to handle completion events and emitted values.
- **`receiveCompletion`**: This closure handles completion events, such as success or failure. In case of failure, it sets the `errorMessage` property to the localized description of the error.
- **`receiveValue`**: This closure handles emitted values from the publisher, in this case, the fetched teams data. It assigns the `teams` property to the array of teams extracted from the received `TeamsModel` object.
- **`.store(in: &cancellables)`**: This operator stores the subscription in the `cancellables` set, ensuring that it remains active and can be canceled when necessary.
```swift
func fetchTeams() {
            teamsService.getTeams()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    case .finished:
                        break
                    }
                }, receiveValue: { teams in
                    self.teams = teams.data
                })
                .store(in: &cancellables)
        }
```
This code demonstrates how to use Combine to fetch data asynchronously from a remote API, handle the response, and update properties accordingly.

### How did I used this data in a view?
As we did before, we have to call the function inside a task, but this time is not needed to use a `do-catch`, since the error are returned in the ViewModel. We should handle the error in a view, maybe with an error message. Anyways, the process is like the async/await one. We declare an instance of the `TeamsVMCombine` class and it will contains the `teams` array. It would have been an `@ObservedObject`, but since we are adopting the `@Observable` we don't need anymore this property wrapper. 
```swift
var teamsCombine =  TeamsVMCombine()
```
Then we call the func `fetchTeams()` and use the data in the view (if everything goes well!!). 
```swift
.task { 
        teamsCombine.fetchTeams()
        if let errorMessage = teamsCombine.errorMessage {
        print(errorMessage)
}
```
```swift
ForEach(teamsCombine.teams) { team in
     Text(team.fullName)
}
```
## Issues Encountered
While implementing the app, I encountered an issue with the BallDontLie API. Despite successfully testing the API calls using Postman, fetching season averages and player for each team resulted in a 401 (unauthorized) error. In the API documentation is written that the free version can make 30 request/minute and I'm making just one (get all the teams). Moreover, the season averages request is only for the current regular season and that was what I was making. As a workaround, player data was loaded from JSON files directly imported into the app, even knowing that is not an optimal solution. 
If anyone has experienced a similar situation with the BallDontLie API (or others) or has insights into resolving the 401 error when fetching season averages and player, any assistance would be greatly appreciated. Please reach me out if you have any suggestions or solutions.




