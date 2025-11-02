import java.util.*;
import clips.*;

/**
 * Tic-Tac-Toe Expert System Integration Example
 * 
 * This class demonstrates how to integrate the CLIPS expert system
 * with a Java application for a Tic-Tac-Toe game.
 * 
 * Requirements:
 * - CLIPSJNI library (http://clipsrules.sourceforge.net/)
 * - tic-tac-toe.clp file in the same directory or resources folder
 * 
 * Usage:
 * 1. Initialize the AI: TicTacToeAI ai = new TicTacToeAI();
 * 2. Set board state: ai.setBoardState(board);
 * 3. Get AI move: int move = ai.getAIMove();
 * 4. Get applied rule: String rule = ai.getLastRule();
 */
public class TicTacToeAI {
    private Environment clips;
    private int lastMove = -1;
    private String lastRule = "";
    private char[] board = new char[9];
    
    /**
     * Initialize the CLIPS environment and load the expert system rules
     */
    public TicTacToeAI() {
        try {
            // Create CLIPS environment
            clips = new Environment();
            
            // Load the expert system rules
            clips.load("tic-tac-toe.clp");
            
            // Build the rules
            clips.build("(defmodule TICTACTOE)");
            clips.reset();
            
        } catch (CLIPSException e) {
            System.err.println("Error initializing CLIPS: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Set the current board state
     * @param board Array of 9 characters: 'X', 'O', or ' ' (empty)
     */
    public void setBoardState(char[] board) {
        if (board.length != 9) {
            throw new IllegalArgumentException("Board must have 9 positions");
        }
        this.board = Arrays.copyOf(board, 9);
    }
    
    /**
     * Get the AI's optimal move using the expert system
     * @return Position index (0-8) for the AI move
     */
    public int getAIMove() {
        try {
            // Clear previous move decisions
            clips.eval("(retract ?* (move-decision))");
            
            // Create board state fact
            String boardFact = buildBoardFact();
            clips.eval("(assert " + boardFact + ")");
            
            // Initialize move decision
            clips.eval("(assert (move-decision (position -1) (rule-applied \"\") (priority 10)))");
            
            // Run the inference engine
            clips.run();
            
            // Extract the move decision
            FactAddressValue moveFact = clips.findFact("move-decision");
            if (moveFact != null) {
                MultifieldValue positionField = (MultifieldValue) moveFact.getSlot("position");
                lastMove = positionField.get(0).intValue();
                
                PrimitiveValue ruleField = (PrimitiveValue) moveFact.getSlot("rule-applied");
                lastRule = ruleField.stringValue();
            } else {
                // Fallback: find first empty cell
                for (int i = 0; i < 9; i++) {
                    if (board[i] == ' ') {
                        lastMove = i;
                        lastRule = "Default move";
                        break;
                    }
                }
            }
            
            // Clean up
            clips.eval("(retract ?*)");
            
            return lastMove;
            
        } catch (CLIPSException e) {
            System.err.println("Error getting AI move: " + e.getMessage());
            e.printStackTrace();
            
            // Fallback: return first empty position
            for (int i = 0; i < 9; i++) {
                if (board[i] == ' ') {
                    return i;
                }
            }
            return -1;
        }
    }
    
    /**
     * Build CLIPS fact string for current board state
     */
    private String buildBoardFact() {
        StringBuilder sb = new StringBuilder("(board-state (cells ");
        
        for (int i = 0; i < 9; i++) {
            String cellValue;
            if (board[i] == 'X') {
                cellValue = "X";
            } else if (board[i] == 'O') {
                cellValue = "O";
            } else {
                cellValue = "EMPTY";
            }
            sb.append(cellValue).append(" ");
        }
        
        sb.append(") (turn O) (game-over FALSE) (winner NONE))");
        return sb.toString();
    }
    
    /**
     * Get the rule that was applied for the last move
     * @return Description of the applied rule
     */
    public String getLastRule() {
        return lastRule;
    }
    
    /**
     * Check if there's a winner on the current board
     * @return 'X', 'O', or ' ' (no winner)
     */
    public char checkWinner() {
        int[][] lines = {
            {0, 1, 2}, {3, 4, 5}, {6, 7, 8}, // rows
            {0, 3, 6}, {1, 4, 7}, {2, 5, 8}, // columns
            {0, 4, 8}, {2, 4, 6}             // diagonals
        };
        
        for (int[] line : lines) {
            if (board[line[0]] != ' ' && 
                board[line[0]] == board[line[1]] && 
                board[line[1]] == board[line[2]]) {
                return board[line[0]];
            }
        }
        
        return ' ';
    }
    
    /**
     * Check if the board is full (draw)
     */
    public boolean isBoardFull() {
        for (char cell : board) {
            if (cell == ' ') {
                return false;
            }
        }
        return true;
    }
    
    /**
     * Clean up CLIPS resources
     */
    public void cleanup() {
        if (clips != null) {
            try {
                clips.clear();
                clips.destroy();
            } catch (CLIPSException e) {
                System.err.println("Error cleaning up CLIPS: " + e.getMessage());
            }
        }
    }
    
    /**
     * Example usage and testing
     */
    public static void main(String[] args) {
        TicTacToeAI ai = new TicTacToeAI();
        
        // Example game state: empty board
        char[] board = {
            ' ', ' ', ' ',
            ' ', ' ', ' ',
            ' ', ' ', ' '
        };
        
        ai.setBoardState(board);
        int move = ai.getAIMove();
        System.out.println("AI chooses position: " + move);
        System.out.println("Rule applied: " + ai.getLastRule());
        
        // Example: Player moves in corner
        board[0] = 'X';
        ai.setBoardState(board);
        move = ai.getAIMove();
        System.out.println("\nAfter player move in corner:");
        System.out.println("AI chooses position: " + move);
        System.out.println("Rule applied: " + ai.getLastRule());
        
        ai.cleanup();
    }
}

