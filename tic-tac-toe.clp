;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tic-Tac-Toe Expert System Implementation in CLIPS
;; 
;; This file contains the knowledge base and rules for an expert system
;; that plays optimal Tic-Tac-Toe using rule-based reasoning.
;;
;; The expert system follows these rules in priority order:
;; 1. Win: Complete three-in-a-row if possible
;; 2. Block: Prevent opponent's three-in-a-row
;; 3. Fork: Create two winning opportunities
;; 4. Block Fork: Prevent opponent's fork
;; 5. Center: Take the center position
;; 6. Opposite Corner: Counter opponent's corner
;; 7. Corner: Take any available corner
;; 8. Side: Take any available side
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule TICTACTOE)

;; Fact templates for the game state
(deftemplate cell
  (slot position (type INTEGER) (default 0))
  (slot value (type SYMBOL) (allowed-symbols X O EMPTY) (default EMPTY)))

(deftemplate board-state
  (multislot cells (type SYMBOL))
  (slot turn (type SYMBOL) (allowed-symbols X O))
  (slot game-over (type SYMBOL) (allowed-symbols TRUE FALSE) (default FALSE))
  (slot winner (type SYMBOL) (allowed-symbols X O NONE) (default NONE)))

(deftemplate move-decision
  (slot position (type INTEGER))
  (slot rule-applied (type STRING))
  (slot priority (type INTEGER)))

;; Winning combinations (rows, columns, diagonals)
(defglobal ?*winning-combinations* = 
  (create$ 
    (create$ 0 1 2)  ; row 1
    (create$ 3 4 5)  ; row 2
    (create$ 6 7 8)  ; row 3
    (create$ 0 3 6)  ; column 1
    (create$ 1 4 7)  ; column 2
    (create$ 2 5 8)  ; column 3
    (create$ 0 4 8)  ; diagonal 1
    (create$ 2 4 6))) ; diagonal 2

;; Helper function to check if a player can win on next move
(deffunction can-win (?board ?player)
  (bind ?result FALSE)
  (loop-for-count ?i 9
    (if (and (not ?result) 
             (eq (nth$ ?i ?board) EMPTY))
      then
        (bind ?test-board (replace$ ?board ?i ?i ?player))
        (if (check-winner ?test-board ?player)
          then (bind ?result TRUE))))
  (return ?result))

;; Helper function to check if there's a winner
(deffunction check-winner (?board ?player)
  (bind ?result FALSE)
  (loop-for-count ?combo 8
    (bind ?line (nth$ ?combo ?*winning-combinations*))
    (bind ?pos1 (nth$ 1 ?line))
    (bind ?pos2 (nth$ 2 ?line))
    (bind ?pos3 (nth$ 3 ?line))
    (if (and (eq (nth$ ?pos1 ?board) ?player)
             (eq (nth$ ?pos2 ?board) ?player)
             (eq (nth$ ?pos3 ?board) ?player))
      then (bind ?result TRUE)))
  (return ?result))

;; Rule 1: WIN - If AI can win, take the winning move (Priority 1)
(defrule rule-win
  (declare (salience 100))
  ?state <- (board-state (cells ?board) (turn O))
  ?move <- (move-decision (priority ?p&:(> ?p 1)))
  =>
  (bind ?move-pos -1)
  (loop-for-count ?i 9
    (if (and (eq ?move-pos -1)
             (eq (nth$ ?i ?board) EMPTY))
      then
        (bind ?test-board (replace$ ?board ?i ?i O))
        (if (check-winner ?test-board O)
          then (bind ?move-pos ?i))))
  (if (>= ?move-pos 0)
    then
      (modify ?move (position ?move-pos) (rule-applied "Win: Complete three-in-a-row") (priority 1))))

;; Rule 2: BLOCK - If opponent can win, block them (Priority 2)
(defrule rule-block
  (declare (salience 90))
  ?state <- (board-state (cells ?board) (turn O))
  ?move <- (move-decision (priority ?p&:(> ?p 2)))
  =>
  (bind ?move-pos -1)
  (loop-for-count ?i 9
    (if (and (eq ?move-pos -1)
             (eq (nth$ ?i ?board) EMPTY))
      then
        (bind ?test-board (replace$ ?board ?i ?i X))
        (if (check-winner ?test-board X)
          then (bind ?move-pos ?i))))
  (if (>= ?move-pos 0)
    then
      (modify ?move (position ?move-pos) (rule-applied "Block: Prevent opponent's three-in-a-row") (priority 2))))

;; Rule 3: FORK - Create two winning opportunities (Priority 3)
(defrule rule-fork
  (declare (salience 80))
  ?state <- (board-state (cells ?board) (turn O))
  ?move <- (move-decision (priority ?p&:(> ?p 3)))
  =>
  (bind ?move-pos -1)
  (bind ?max-forks 0)
  (loop-for-count ?i 9
    (if (eq (nth$ ?i ?board) EMPTY)
      then
        (bind ?test-board (replace$ ?board ?i ?i O))
        (bind ?fork-count 0)
        (loop-for-count ?j 9
          (if (eq (nth$ ?j ?test-board) EMPTY)
            then
              (bind ?test-board2 (replace$ ?test-board ?j ?j O))
              (if (check-winner ?test-board2 O)
                then (bind ?fork-count (+ ?fork-count 1)))))
        (if (>= ?fork-count 2)
          then
            (bind ?move-pos ?i)
            (bind ?max-forks ?fork-count))))
  (if (>= ?move-pos 0)
    then
      (modify ?move (position ?move-pos) (rule-applied "Fork: Create two winning opportunities") (priority 3))))

;; Rule 4: BLOCK FORK - Prevent opponent's fork (Priority 4)
(defrule rule-block-fork
  (declare (salience 70))
  ?state <- (board-state (cells ?board) (turn O))
  ?move <- (move-decision (priority ?p&:(> ?p 4)))
  =>
  (bind ?move-pos -1)
  (bind ?opponent-forks (create$))
  (loop-for-count ?i 9
    (if (eq (nth$ ?i ?board) EMPTY)
      then
        (bind ?test-board (replace$ ?board ?i ?i X))
        (bind ?fork-count 0)
        (loop-for-count ?j 9
          (if (eq (nth$ ?j ?test-board) EMPTY)
            then
              (bind ?test-board2 (replace$ ?test-board ?j ?j X))
              (if (check-winner ?test-board2 X)
                then (bind ?fork-count (+ ?fork-count 1)))))
        (if (>= ?fork-count 2)
          then (bind ?opponent-forks (create$ ?opponent-forks ?i)))))
  (if (> (length$ ?opponent-forks) 0)
    then
      (bind ?move-pos (nth$ 1 ?opponent-forks))
      (modify ?move (position ?move-pos) (rule-applied "Block Fork: Prevent opponent's fork") (priority 4))))

;; Rule 5: CENTER - Take the center if available (Priority 5)
(defrule rule-center
  (declare (salience 60))
  ?state <- (board-state (cells ?board) (turn O))
  ?move <- (move-decision (priority ?p&:(> ?p 5)))
  =>
  (if (eq (nth$ 5 ?board) EMPTY)
    then
      (modify ?move (position 4) (rule-applied "Center: Control the middle position") (priority 5))))

;; Rule 6: OPPOSITE CORNER - Counter opponent's corner (Priority 6)
(defrule rule-opposite-corner
  (declare (salience 50))
  ?state <- (board-state (cells ?board) (turn O))
  ?move <- (move-decision (priority ?p&:(> ?p 6)))
  =>
  (bind ?move-pos -1)
  (if (and (eq (nth$ 1 ?board) X) (eq (nth$ 9 ?board) EMPTY))
    then (bind ?move-pos 8))
  (if (and (eq ?move-pos -1) (eq (nth$ 9 ?board) X) (eq (nth$ 1 ?board) EMPTY))
    then (bind ?move-pos 0))
  (if (and (eq ?move-pos -1) (eq (nth$ 3 ?board) X) (eq (nth$ 7 ?board) EMPTY))
    then (bind ?move-pos 6))
  (if (and (eq ?move-pos -1) (eq (nth$ 7 ?board) X) (eq (nth$ 3 ?board) EMPTY))
    then (bind ?move-pos 2))
  (if (>= ?move-pos 0)
    then
      (modify ?move (position ?move-pos) (rule-applied "Opposite Corner: Counter opponent's corner") (priority 6))))

;; Rule 7: CORNER - Take any available corner (Priority 7)
(defrule rule-corner
  (declare (salience 40))
  ?state <- (board-state (cells ?board) (turn O))
  ?move <- (move-decision (priority ?p&:(> ?p 7)))
  =>
  (bind ?move-pos -1)
  (bind ?corners (create$ 1 3 7 9))
  (loop-for-count ?i 4
    (if (and (eq ?move-pos -1) (eq (nth$ (nth$ ?i ?corners) ?board) EMPTY))
      then (bind ?move-pos (- (nth$ ?i ?corners) 1))))
  (if (>= ?move-pos 0)
    then
      (modify ?move (position ?move-pos) (rule-applied "Corner: Strong strategic position") (priority 7))))

;; Rule 8: SIDE - Take any available side (Priority 8)
(defrule rule-side
  (declare (salience 30))
  ?state <- (board-state (cells ?board) (turn O))
  ?move <- (move-decision (priority ?p&:(> ?p 8)))
  =>
  (bind ?move-pos -1)
  (bind ?sides (create$ 2 4 6 8))
  (loop-for-count ?i 4
    (if (and (eq ?move-pos -1) (eq (nth$ (nth$ ?i ?sides) ?board) EMPTY))
      then (bind ?move-pos (- (nth$ ?i ?sides) 1))))
  (if (>= ?move-pos 0)
    then
      (modify ?move (position ?move-pos) (rule-applied "Side: Available position") (priority 8))))

;; Default rule: Take first available position (Priority 9)
(defrule rule-default
  (declare (salience 20))
  ?state <- (board-state (cells ?board) (turn O))
  ?move <- (move-decision (priority ?p&:(> ?p 9)))
  =>
  (bind ?move-pos -1)
  (loop-for-count ?i 9
    (if (and (eq ?move-pos -1) (eq (nth$ ?i ?board) EMPTY))
      then (bind ?move-pos ?i)))
  (if (>= ?move-pos 0)
    then
      (modify ?move (position ?move-pos) (rule-applied "Default move") (priority 9))))

;; Initialize move decision fact
(defrule initialize-move
  (board-state (turn O))
  (not (move-decision))
  =>
  (assert (move-decision (position -1) (rule-applied "") (priority 10))))

;; Clean up move decision after use
(defrule cleanup-move
  ?state <- (board-state (turn X))
  ?move <- (move-decision)
  =>
  (retract ?move))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Usage Example (to be integrated with Java/Python wrapper):
;;
;; 1. Initialize board state:
;;    (assert (board-state (cells EMPTY EMPTY EMPTY EMPTY EMPTY EMPTY EMPTY EMPTY EMPTY) (turn O)))
;;
;; 2. Run the inference engine:
;;    (run)
;;
;; 3. Check the move decision:
;;    (facts move-decision)
;;
;; 4. Apply the move and update board state
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

