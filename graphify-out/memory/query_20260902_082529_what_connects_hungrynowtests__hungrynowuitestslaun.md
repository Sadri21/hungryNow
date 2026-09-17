---
type: "query"
date: "2026-09-02T08:25:29.147698+00:00"
question: "What connects hungrynowTests, hungrynowUITestsLaunchTests, hungrynowUITests to the rest of the system?"
contributor: "graphify"
source_nodes: ["hungrynowTests", "hungrynowUITests", "hungrynowUITestsLaunchTests", "XCTestCase"]
---

# Q: What connects hungrynowTests, hungrynowUITestsLaunchTests, hungrynowUITests to the rest of the system?

## Answer

All three test classes inherit from a shared XCTestCase node - that is the structural bridge between them. But none of them have any edge to ContentView, hungrynowApp, or the planned RecommendationServiceProtocol/LocationService abstractions - every method inside is unmodified Xcode template boilerplate (testExample, testPerformanceExample, testLaunch). The isolation the report flagged is a real project gap, not an extraction gap: there is currently zero test coverage of actual app behavior, because the app behavior (recommendation flow, location service, Moya networking) has not been built yet.

## Source Nodes

- hungrynowTests
- hungrynowUITests
- hungrynowUITestsLaunchTests
- XCTestCase