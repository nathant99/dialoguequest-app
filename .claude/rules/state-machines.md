---
paths:
  - "**/*.swift"
---

# State Machine Patterns

## When to Use a State Machine

Reach for a state machine when you have 4+ related `@State` variables, mutually exclusive modes, or find yourself preventing invalid boolean combinations. Don't add FSM structure before complexity warrants it — start simple, refactor when it breaks.

## Two Portfolio Patterns

### 1. `*Machine` Structs (Local View State)

Use for complex views with many coordinated `@State` properties (quiz flows, battle views, onboarding). Replaces a proliferation of individual `@State` vars with a single struct.

```swift
struct QuizMachine {
    // MARK: - Progress
    var currentIndex = 0
    var correctCount = 0
    var showResult = false

    // MARK: - Combo
    var comboCount = 0
    var maxCombo = 0

    mutating func reset() {
        self = QuizMachine()
    }
}

// In view:
@State private var machine = QuizMachine()
```

**Conventions**:
- Suffix `*Machine` (e.g., `QuizMachine`, `BattleMachine`, `OnboardingMachine`)
- Top-level struct (not nested inside the view)
- Required `mutating func reset()` that re-assigns `self` to a fresh instance
- Organize with `// MARK: -` section headers
- Keep it a pure value type — no closures, no references to views or services

### 2. Enum-Based State (Navigation & Exclusive Modes)

Use for mutually exclusive states, especially navigation routing or phases with different associated data.

```swift
enum AppPhase: Sendable, Hashable {
    case ageGate
    case onboarding
    case menu
    case playing(PuzzleType)
    case results(score: Int)
}

enum LoadState {
    case idle
    case loading
    case loaded(Data)
    case error(Error)
}
```

**Conventions**:
- Associated values bundle state-specific data (eliminates optionals)
- Computed properties for derived state (e.g., `var isFullScreen: Bool`)
- Exhaustive `switch` in views — compiler catches unhandled states
- Use `guard case let` for extracting specific state data

## Choosing Between Patterns

| Situation | Use |
|---|---|
| 10+ coordinated `@State` vars in one view | `*Machine` struct |
| 3-5 mutually exclusive UI modes | Enum with `switch` |
| States carry different associated data | Enum with associated values |
| Navigation routing across screens | Enum (`AppPhase` pattern) |
| Shared state observed by multiple views | `@Observable` class with enum property |
| SpriteKit scene with update loop lifecycle | Protocol-based state pattern |

## Anti-Patterns

1. **Boolean soup** — Multiple `@State` booleans for exclusive states (`isLoading`, `hasError`, `isComplete`). Replace with a single enum
2. **State explosion** — Combinatorial states from independent dimensions. Split into concurrent machines (two separate enums)
3. **Side effects in transitions** — Network calls or persistence inside state mutation. Keep transitions pure; trigger effects separately
4. **Meaningless states** — Separate enum cases that differ only in data (`networkError`, `validationError`). Use one case with associated data: `.error(Error)`
5. **Premature FSM** — Adding machine structure for 2-3 simple booleans. Start simple, refactor when complexity demands it
6. **Nested `*Machine` structs** — Defining the struct inside the view. Keep top-level for testability and reuse

## Advanced Patterns (Use When Needed)

### Hierarchical States

Group states that share common behavior with nested enums:

```swift
enum CharacterState {
    case onGround(GroundState)
    case inAir(AirState)
    
    enum GroundState { case standing, walking, running }
    enum AirState { case jumping, falling }
}
```

Use when: duplicate transition logic across multiple states.

### Concurrent State Machines

Independent state dimensions as separate properties:

```swift
@State private var movement: MovementState = .idle
@State private var equipment: EquipmentState = .unarmed
```

Use when: adding a state to one dimension would require duplicating every state in the other (n × m → n + m).

### Pushdown Automata (State Stack)

Stack of states for "return to previous" semantics. SwiftUI's `NavigationStack` is already this pattern. For game-specific stacks (pause overlays, modal sequences), use an explicit stack:

```swift
@State private var stateStack: [GamePhase] = [.menu]
```

## Testing State Machines

- **Test transitions, not internal state** — verify observable behavior (what the user sees), not which enum case is active
- **Test reset** — every `*Machine` must fully reset to initial values via `reset()`
- **Test guards** — verify invalid transitions are rejected
- **Test determinism** — same input sequence always produces same result
- **Separate pure logic from effects** — pure `(State, Event) -> State` functions are trivially testable
- **Architecture tests** — enforce that all `*Machine` structs have `reset()` and are top-level (CuriosityQuest pattern)

```swift
@Test func resetClearsAllState() {
    var machine = QuizMachine()
    machine.currentIndex = 5
    machine.comboCount = 7
    machine.reset()
    #expect(machine.currentIndex == 0)
    #expect(machine.comboCount == 0)
}
```

## Swift-Specific Notes

- `*Machine` structs are value types, automatically `Sendable` — safe for Swift 6 strict concurrency
- Enum exhaustive `switch` catches unhandled states at compile time
- Use `@State` + struct for view-local machines; `@Observable` class for shared/injected state
- State transitions must happen on MainActor (UI state). Async side effects via `Task {}`
- `nonisolated` on `*Machine` structs in SPM packages with default MainActor isolation (same rule as other value types)
<!-- END LABSMITH-SYNCED CONTENT -->
