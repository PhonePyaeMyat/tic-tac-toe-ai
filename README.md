# Tic-Tac-Toe Expert System AI

A sophisticated Tic-Tac-Toe game implementation featuring an expert system AI powered by rule-based reasoning. The AI uses a knowledge base containing strategic rules to make optimal moves.

## Features

- **Expert System AI**: Rule-based decision making with 8 priority-ordered rules
- **Interactive Web Interface**: Built with React and Bootstrap for a modern UI
- **CLIPS Integration**: Expert system implementation in CLIPS language for integration with other systems
- **Real-time Rule Feedback**: See which expert system rule the AI applies for each move
- **Score Tracking**: Track wins, losses, and draws across multiple games

## Expert System Rules (Priority Order)

The AI follows these rules in strict priority order:

1. **Win**: Complete three-in-a-row if possible
2. **Block**: Prevent opponent's three-in-a-row
3. **Fork**: Create two winning opportunities
4. **Block Fork**: Prevent opponent's fork (with advanced counter-strategy)
5. **Center**: Take the center position
6. **Opposite Corner**: Counter opponent's corner
7. **Corner**: Take any available corner
8. **Side**: Take any available side position

## How to Play

1. Open `index.html` in a modern web browser
2. You play as **X**, the AI plays as **O**
3. Click on an empty cell to make your move
4. The AI will automatically respond using the expert system rules
5. Watch the "AI Rule Applied" panel to see which rule the AI used
6. Click "New Game" to start over

## Project Structure

```
tic-tac-toe-ai/
├── index.html          # Main web application (React + Bootstrap)
├── tic-tac-toe.clp     # CLIPS expert system implementation
└── README.md           # This file
```

## Technical Details

### Web Application (`index.html`)

- **Framework**: React 18 (via CDN)
- **Styling**: Bootstrap 5.3.2
- **Expert System**: JavaScript implementation of rule-based reasoning
- **Features**:
  - Real-time game state management
  - Visual feedback for last move
  - Rule explanation display
  - Persistent score tracking

### CLIPS Implementation (`tic-tac-toe.clp`)

The CLIPS file contains a complete expert system implementation that can be integrated with Java, Python, or other programming languages.

#### Key Components:

- **Fact Templates**: Define game state structure
- **Rules**: 8 priority-ordered rules plus default fallback
- **Helper Functions**: Check for winners, potential wins, and forks
- **Salience Values**: Control rule priority execution

#### Integration Example:

```clips
; Initialize board
(assert (board-state (cells EMPTY EMPTY EMPTY EMPTY EMPTY EMPTY EMPTY EMPTY EMPTY) (turn O)))

; Run inference engine
(run)

; Get AI move decision
(facts move-decision)
```

## Expert System Architecture

### Rule Execution Flow

1. The system checks rules in priority order (highest salience first)
2. Each rule evaluates the current board state
3. When a rule matches, it creates/modifies a move-decision fact
4. Higher priority rules can override lower priority decisions
5. The final move decision is applied to the board

### Knowledge Base Structure

The expert system knowledge base consists of:

- **Board State**: Current game configuration
- **Win Conditions**: All possible three-in-a-row combinations
- **Strategic Patterns**: Fork detection, blocking strategies
- **Position Evaluation**: Corner, center, side priority

## Integration with Other Languages

### Java Integration

To integrate the CLIPS expert system with Java:

1. Use [CLIPSJNI](http://clipsrules.sourceforge.net/) for Java-CLIPS binding
2. Load the `tic-tac-toe.clp` file
3. Initialize board state facts
4. Run the inference engine
5. Extract move decisions from facts

### Python Integration

For Python integration:

1. Use [PyCLIPS](https://sourceforge.net/projects/pyclips/) or CLIPS via subprocess
2. Load CLIPS rules from file
3. Execute rules and retrieve facts
4. Parse move decisions

## Algorithm Complexity

- **Time Complexity**: O(n²) for rule evaluation, where n is board size (9)
- **Space Complexity**: O(n) for board state storage
- **Rule Evaluation**: Constant time per rule (early termination on match)

## Future Enhancements

Potential improvements to the expert system:

1. **Learning Component**: Adapt strategy based on opponent patterns
2. **Difficulty Levels**: Introduce randomness for easier difficulty
3. **Game History**: Analyze and learn from previous games
4. **Mini-Max Integration**: Combine rule-based and minimax approaches
5. **Multiplayer Support**: Allow AI vs AI matches

## Browser Compatibility

- Chrome/Edge (recommended)
- Firefox
- Safari
- Modern browsers with ES6+ support

## License

This project is provided as an educational example of expert system implementation for game AI.

## References

- **CLIPS**: [http://clipsrules.sourceforge.net/](http://clipsrules.sourceforge.net/)
- **Expert Systems**: Rule-based AI systems for decision making
- **Tic-Tac-Toe Strategy**: Optimal play strategies for perfect play

---

**Note**: The expert system implementation ensures optimal play - it will never lose a game (can only win or draw if the player plays optimally).

