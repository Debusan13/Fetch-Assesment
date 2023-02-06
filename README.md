# Fetch Take Home Assignment - Mobile

## Project Goal

1. Query the json object residing at https://fetch-hiring.s3.amazonaws.com/hiring.json
2. Display that object as a human readable list in a native iOS app
3. The list should be grouped by `listId` in ascending order, and within each group should be sorted by `name`
4. Any null values should be excluded from the list

## Procedure

### The JSON object
Directly querying the object in the browser shows that `name` and `id` seem to display the same information, with the exceptin that `name` is in the form of a string.

This string follows the form
```py
f"Item: {id}"
```
where `id` is unique. This information is useful as it is easier to sort via the integer rather than the string.

#### Retrieving the Data
The data retrieval is done by the `loadData` function within the main content view. The URL is hardcoded into the application as an object of type `URL`, which allows the application to use a `URLSession` to handle getting the data from the server. Sicne only one query needs to be made at a time, and all the data is fetched at once, a [shared singleton](https://developer.apple.com/documentation/foundation/urlsession/1409000-shared) `URLSession` will suffice. The `dataTask` method will fetch from a given url an https `response`, `data` at the URL, and an `error` if the request failed. For the purposes of the assessment only `data` is needed.

From there, the `data` from the site is decoded using `JSONDecoder`'s `decode`, but is manually handled by [`Item`](#item-struct) struct. Any empty strings in the `name` field are filtered out and a promise is made to update the `items` array in the main content view. If this data fetch fails, there is a simple error message printed to the console.

### Main View
The main view for the project has a very simple structure:
- A list title entitled "Items"
- A navigation button entitled "Load Data"
- List elements which have on the left side, in large text, the item `name` and on the right side in a subfont the `listId`

#### Loading Data
When the application is first started and the main view appears, the application will go to query the URL and display the data. However, if for some reason this does not work, the navigation button will also do the same after being explicitly pressed. This started as a debugging feature, but could be beneficial to the user, so it remains.

### The List Elements
Due to the relative simplicity of the application, the main data structure that stores the items is simply an `Array` of a defined structure `Item` (named `items`).

#### Item Struct
The item struct has 3 main member data:
```swift
    id: Int
    listId: Int
    name: String
```
The struct uses the [`Decodable`](https://developer.apple.com/documentation/swift/decodable) and [`Identifiable`](https://developer.apple.com/documentation/swift/identifiable) protocols so that a json object can be serialized into its values, and so that each individual struct is uniquely identified by its `id`.

#### Decoding the Object into `items`
Since there is a possibility that the `name` field of the json object will be null, it is necessarry to handle that manually using `decodeIfPresent`. This can be done by adding `enum CodingKeys` to the struct to describe the shape of the data and by adding an `extension` to the struct which handles serializing the data. This allows the struct [to conform to the `Decodable` protocol](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types) and be read in properly. If `name` isn't present then `name` in the struct will be replaced with an empty string so that it can be filtered out.

#### Displaying `items`
Displaying each `Item` had to split into two parts. The actual information on display in the list, and how the `Item`s were ordered on that list. The result is that when `items` is displayed in the main controller, its order and visual design are predetermined, making the display clean and fast.

##### `ItemRow` list element
`ItemRow` is a struct that takes in an `Item` struct as an initalizer. From this it contsrcuts a simple view that displays in large text that is left justified the `name` of the `Item`. The `listId` of the `Item` is in smaller text that is right justified. This makes it so that at a quick glance the user can see each item and what group of `listId` it is in.

##### Grouping and Sorting
Since the main view simply iterates across the `items` array and displays each `Item` it is necessary to group and sort the `Item`s as an array. This is done in the `group` function by first transforming the `items` array into a `Dictionary` using the [`init(grouping:by:)`](https://developer.apple.com/documentation/swift/dictionary/init(grouping:by:)) initializer to group each `Item` by `listId` (`listId` is the key and an array of `Item`s is the value). From there the dictionary is sorted by its keys, then the `Dictonary` is "flattened" into an array and the values are sorted, which is done by the `flatmap` member function. The function finally returns this array.

## Final Results
A simple long list that meets all the project requirements. The code is relatively simple and declarative, which means it could be easily moved around a large project. Certain choices like manually decoding the item means that, should the nature of the json object change, it can be quickly addressed. No outside libraries were used which also means that no speciality is required to understand the code. 
### Potential Improvements
- More safety checks and data handling edge cases for the JSON object. If the `id` and `name` weren't identical and unique then it would have been necessary to give each `Item` a UUID for example.
- Not putting the entire application essentially in the main view controller.
- Segmented list to display `items`. Currently the list is a bit too long and could suffice from different sections or subheadings within the list. However I was unsure how this would play into the scope of the project.
- Proper error handling for a bad URL or bad JSON object or bad decode.
- Incrementally loading in data from the server using `URLSession` to reduce network load and space used.


# Citations
- https://developer.apple.com/documentation
- https://developer.apple.com/tutorials/swiftui
- https://www.avanderlee.com/swift/json-parsing-decoding/
- https://calvinw.medium.com/using-urlsession-to-retrieve-json-in-swift-1-getting-started-d929f3a49c67
- https://www.swiftbysundell.com/basics/map-flatmap-and-compactmap/
- https://www.hackingwithswift.com/books/ios-swiftui/working-with-identifiable-items-in-swiftui
# Update from Fetch
I didn't get the internship, but I am leaving this up as a sort of lesson to myself and for anyone who might see this. I really commend Fetch for actually sending me a detailed response on what I did correctly and incorrectly in my application.

## Response from Fetch

> What went well: 
>
> - A very descriptive and well written ReadMe file on Github. As software developers, we write documentation all the time. Knowing how to properly document the written code is a great skill to have. 
> - Although the project was very simple, the candidate still followed good SwiftUI principle: Combining smaller views to construct bigger views. 
 >
>What could have gone better: 
>
> - Separation of concerns: ContentView is doing a few things in the project. It is describing what should be presented on the screen, it is making network calls, it is sorting the items. Software developers are always in maintenance mode, and having things separated makes maintenance easier. 
> - Error handling: When network call succeeds, a list of items is displayed. But when it fails, the UX could have been better. Displaying an alert or some empty state view could help use understand what is going on. 

I think that it is interesting that what I identified as potential improvements were, in fact, why I didn't do well on the assignment.
