#  SpaceX Info App
I've tried to spend a max of 2 days on the app. So some shortcuts where choosen, i will try to explain most of the decisions here, and what I would do if i had more time.
## API 
* we use the launch library (v2.3.0)  see -> https://lldev.thespacedevs.com/docs
-

## Deviations 
* Used swift testing in favor of XCTests
-
## Project setup  ##
- Uses a core package using SPM to modularize the app
- iOS 26+
- Xcode 27.1
- Swift 6
- strict concurrency & approachable concurrency
- iOS/iPadOS/macOS
- Debug tab for changing between production & test environment
- uses point free snapshottesting for snapshottesting SpaceUI components

## Architecture
- We just use plain initializers for DI, if the app grew larger we could introduce some other form of DI
- Feature Modules do not depend on each other, we use the Space module as a composition root
  - In a larger app I would split up each NavigationStack into it's own module for clearer seperation
- `SpaceDomain` and `SpaceData` are deliberately modules for now. 
  - If the app grew very large, I would think about splitting them per feature or domain with a small shared core, but that would be over-engineering at this size.

## Decisions
* Used AsyncImage, can be replaced by an actual Image implementation that caches on disk
- Data isn't cached, except for default URLSession caching, if offline use or caching were a requirement we would put it in the repositories layer.
- Localization, i choose for the simplest setup because of time limitations, 
  - normally i would build one central Localization module that all other modules can use to fetch their translations from. Unless it's a bigger project and module/feature owners should manage theird own translations
- I did not build in an abstraction for URLSesssion, normally a nice generic system would sit on top.

## Testing
- Tests check behaviour and not implementation details. I've tried to keep it as pure as possible , only Input -> Output

## AI usage
Some AI was used while building this. Used claude code, either integrated in Xcode or using the Claude code terminal app.

###  AI usage
- Copied and improved on a paginator that I already had build in the past.
- Some refactoring was done using AI
- Mock data/classes were generated using AI
- Some of the Tests were written by AI, after i wrote the first ones.
- I let it manage the package.swift
- I explicitly did it not let write UI code,
  - i've found that personally it's still really bad at writting correct and peforment SwiftUI code
- to demonstrate some agentic coding maturity i've blocked a specific SwiftUI anti-pattern, using a hook.
