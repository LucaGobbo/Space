#  SpaceX Info App
- This was timeboxed to 2 days max
- i try to explain some of the descision in this file
## API 
* The launch library (v2.3.0) was used for the API
  -  https://lldev.thespacedevs.com/docs
-

## Project setup  ##
- Uses a core package using SPM to modularize the app
- iOS 26+
- Xcode 27.1
- Swift 6
- strict concurrency & approachable concurrency
- Debug tab for changing between production & test environment
- uses point free snapshottesting for snapshottesting SpaceUI components

## Deviations 
* Used swift testing in favor of XCTests
-

## Architecture
- Clean architecture, withouth usecase layer, there was no real advantage with an app this size to also add usecases
  - Feature Modules do not depend on each other, we use the Space module as a composition root
    - In a larger app each NavigationStack would be split up into it's own module for clearer seperation
- Plain swift initializers for DI, if the app grew larger we could introduce some other form of DI
- SpaceDomain and SpaceData contain all domain models.
  - If the app grew very large, I would think about splitting them per feature or domain with a small shared core, but that would be over-engineering at this size.

## Decisions
* Used AsyncImage, in production we should probally repace this with an implementation or library that caches on disk
- Data isn't cached, only default URLSession caching is used, if offline use or caching were a requirement it  would have been done it in the repositories layer.
- Localization, simplest setup was choosen, per module localization. 
  - normally i would build one central Localization module that all other modules can use to fetch their translations from. Unless it's a bigger project and module/feature owners should manage theird own translations
- I did not build in an abstraction for URLSesssion, normally there would be something in between the URLSession and the actual service implementations.
- Unit Tests check behaviour and not implementation details

## ## AI usage
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
