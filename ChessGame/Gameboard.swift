//
//  Gameboard.swift
//  ChessGame
//
//  Created by Caleb Marquart on 2022-12-23.
//

import SwiftUI

class Gameboard: ObservableObject {
    @Published var board = [[Piece?]]()
    @Published var selectedRow: Int? { didSet {
        attemptMove()
    }}
    @Published var selectedCol: Int? { didSet {
        attemptMove()
    }}
    @Published var readyToMove = false
    @Published var playerTurn = Player.white
    var checkKingForCheck = true
    
    init() {
        createNewGame()
    }
    
    func createNewGame() {
        board.removeAll()
        
        
        var blackPons = [Piece]()
        var whitePons = [Piece]()
        
        let nilRow: [Piece?] = [nil,nil,nil,nil,nil,nil,nil,nil]
        
        for _ in 0..<8 {
            blackPons.append(Piece(name: .pon, player: .black))
            whitePons.append(Piece(name: .pon, player: .white))
        }
        
        var whitePowerRow = [Piece]()
        var blackPowerRow = [Piece]()
        
        whitePowerRow.append(Piece(name: .rook, player: .white))
        whitePowerRow.append(Piece(name: .knight, player: .white))
        whitePowerRow.append(Piece(name: .bishop, player: .white))
        whitePowerRow.append(Piece(name: .queen, player: .white))
        whitePowerRow.append(Piece(name: .king, player: .white))
        whitePowerRow.append(Piece(name: .bishop, player: .white))
        whitePowerRow.append(Piece(name: .knight, player: .white))
        whitePowerRow.append(Piece(name: .rook, player: .white))
        
        blackPowerRow.append(Piece(name: .rook, player: .black))
        blackPowerRow.append(Piece(name: .knight, player: .black))
        blackPowerRow.append(Piece(name: .bishop, player: .black))
        blackPowerRow.append(Piece(name: .queen, player: .black))
        blackPowerRow.append(Piece(name: .king, player: .black))
        blackPowerRow.append(Piece(name: .bishop, player: .black))
        blackPowerRow.append(Piece(name: .knight, player: .black))
        blackPowerRow.append(Piece(name: .rook, player: .black))
        
        board.append(blackPowerRow)
        board.append(blackPons)
        board.append(nilRow); board.append(nilRow); board.append(nilRow); board.append(nilRow)
        board.append(whitePons)
        board.append(whitePowerRow)
    }
    
    func movePiece(fromRow: Int, fromCol: Int, toRow: Int, toCol: Int) {
        guard let pieceToMove = board[fromRow][fromCol] else { return }
        let landingSquare = board[toRow][toCol]
        
        if landingSquare != nil {
            guard pieceToMove.player != landingSquare!.player else { return }
        }
        
        let move = Move(fromRow: fromRow, fromCol: fromCol, toRow: toRow, toCol: toCol)
        
        guard isValidMove(for: pieceToMove, fromRow: fromRow, fromCol: fromCol, toRow: toRow, toCol: toCol) else { return }
        guard !putsOwnKingInCheck(for: pieceToMove.player, with: move) else { return }
        
        
        // Move the piece is the move is valid and king is not in check
        board[fromRow][fromCol] = nil
        board[toRow][toCol] = pieceToMove
        
        // Switch player turns
        if playerTurn == .white {
            playerTurn = .black
        } else {
            playerTurn = .white
        }
        
    }
    
    func attemptMove() {
        if !readyToMove {
            if let row = selectedRow, let col = selectedCol {
                if board[row][col] != nil {
                    readyToMove = true
                }
            }
        }
    }
    
    func isValidMove(for piece: Piece, fromRow: Int, fromCol: Int, toRow: Int, toCol: Int) -> Bool {
        let move = Move(fromRow: fromRow, fromCol: fromCol, toRow: toRow, toCol: toCol)
        
        if piece.name == .pon {
            guard validPonMove(for: piece.player, with: move) else { return false }
        }
        
        if piece.name == .rook {
            guard isValidLine(direction: .horizontal, move: move) || isValidLine(direction: .vertial, move: move) else { return false }
        }
        
        if piece.name == .bishop {
            guard isValidLine(direction: .diagonal, move: move) else { return false}
        }
        
        if piece.name == .queen {
            guard isValidLine(direction: .horizontal, move: move) || isValidLine(direction: .vertial, move: move) || isValidLine(direction: .diagonal, move: move) else { return false }
        }
        
        if piece.name == .knight {
            guard validKnightMove(move: move) else { return false }
        }
        
        if piece.name == .king {
            guard validKingMove(move: move) else { return false }
        }
        
        return true
    }
    
    func isValidLine(direction: Line, move: Move) -> Bool {
        switch direction {
        case .horizontal:
            
            guard move.fromRow == move.toRow else { return false }
            
            if abs(move.toCol - move.fromCol) <= 1 {
                return true
            }
            
            if move.fromCol < move.toCol {
                for i in move.fromCol + 1 ..< move.toCol {
                    guard board[move.fromRow][i] == nil else { return false}
                }
            } else {
                for i in move.toCol + 1 ..< move.fromCol {
                    guard board[move.fromRow][i] == nil else { return false}
                }
            }
            
            return true
            
        case .vertial:
            guard move.fromCol == move.toCol else { return false }
            
            if abs(move.toRow - move.fromRow) <= 1 { return true }
            
            if move.fromRow < move.toRow {
                for i in move.fromRow + 1 ..< move.toRow {
                    guard board[i][move.fromCol] == nil else { return false}
                }
            } else {
                for i in move.toRow + 1 ..< move.fromRow {
                    guard board[i][move.fromCol] == nil else { return false}
                }
            }
            
            return true
            
        case .diagonal:
            guard abs(move.fromRow - move.toRow) == abs(move.fromCol - move.toCol) else { return false }
            
            if abs(move.toRow - move.fromRow) <= 1 { return true }
            
            if move.fromRow < move.toRow && move.fromCol < move.toCol { // right and down
                for i in move.fromRow + 1 ..< move.toRow {
                    guard board[i][move.fromCol + (i - move.fromRow)] == nil else { return false }
                }
            } else if move.fromRow < move.toRow && move.fromCol > move.toCol { // down and left
                for i in move.fromRow + 1 ..< move.toRow {
                    guard board[i][move.fromCol - (i - move.fromRow)] == nil else { return false }
                }
            } else if move.fromRow > move.toRow && move.fromCol < move.toCol { // up and right
                for i in move.toRow + 1 ..< move.fromRow {
                    guard board[i][move.toCol - (i - move.toRow)] == nil else { return false }
                }
            } else if move.fromRow > move.toRow && move.fromCol > move.toCol { // up and left
                for i in move.toRow + 1 ..< move.fromRow {
                    guard board[i][move.toCol + (i - move.toRow)] == nil else { return false }
                }
            }
            
            return true
            
        }
    }
    
    func validKnightMove(move: Move) -> Bool {
        
        let rowChange = abs(move.fromRow - move.toRow)
        let colChange = abs(move.fromCol - move.toCol)
        
        if rowChange == 2 && colChange == 1 { return true }
        if rowChange == 1 && colChange == 2 { return true }
        
        return false
    }
    
    func validKingMove(move: Move) -> Bool {
        let rowChange = abs(move.toRow - move.fromRow)
        let colChange = abs(move.toCol - move.fromCol)
        
        guard rowChange <= 1 else { return false }
        guard colChange <= 1 else { return false }
        
        return true
    }
    
    func putsOwnKingInCheck(for player: Player, with move: Move) -> Bool {
        var copy: [[Piece?]] = board
        let pieceToMove = copy[move.fromRow][move.fromCol]
        copy[move.toRow][move.toCol] = pieceToMove
        copy[move.fromRow][move.fromCol] = nil
        
        return isKingInCheck(for: player, on: copy)
    }
    
    func validPonMove(for player: Player, with move: Move) -> Bool {
        switch player {
        case .white:
            
            if (move.fromRow - move.toRow < 0 || move.fromRow - move.toRow > 1) && move.fromRow != 6 {
                return false
            }
            
            guard abs(move.fromRow - move.toRow) <= 2 else { return false }
            
            if abs(move.fromCol - move.toCol) > 1 {
                return false
            }
            
            if abs(move.fromCol - move.toCol) == 1 && move.fromRow == move.toRow {
                return false
            }
            
            if move.toCol == move.fromCol && board[move.toRow][move.fromCol] != nil {
                return false
            }
            
            if move.fromCol != move.toCol {
                guard board[move.toRow][move.toCol] != nil else { return false }
            }
            
            if move.toRow > 0 {
                if move.fromRow == 6 && board[move.toRow - 1][move.toCol] != nil {
                    return false
                }
            }
            
            return true
            
        case .black:
            if (move.toRow - move.fromRow < 0 || move.toRow - move.fromRow > 1) && move.fromRow != 1 {
                return false
            }
            
            guard abs(move.fromRow - move.toRow) <= 2 else { return false }
            
            if abs(move.fromCol - move.toCol) > 1 {
                return false
            }
            
            if abs(move.fromCol - move.toCol) == 1 && move.fromRow == move.toRow {
                return false
            }
            
            if move.toCol == move.fromCol && board[move.toRow][move.fromCol] != nil {
                return false
            }
            
            if move.fromCol != move.toCol {
                guard board[move.toRow][move.toCol] != nil else { return false }
            }
            
            if move.toRow < 7 {
                
                if move.fromRow == 1 && board[move.toRow + 1][move.toCol] != nil {
                    return false
                }
            }
            
            return true
        }
    }
    
    func isKingInCheck(for player: Player, on board: [[Piece?]]) -> Bool {
        // Determine first where there king is
        var kingRow = 0
        var kingCol = 0
        
        // Loop through the board and find where there is a piece that exists, matches the player, and is a king
        // *There should always be one king for each player so get it's coordinates*
        for row in 0..<board.count {
            for col in 0..<board[row].count {
                if let piece = board[row][col] {
                    if piece.player == player && piece.name == .king {
                        kingRow = row
                        kingCol = col
                        break
                    }
                }
            }
        }
        
        // Show where the king is
        print("The king for \(player == .white ? "white" : "black") is in row \(kingRow), column \(kingCol)")
        
        // Loop through the board to see if any of the oppoents pieces put the king in check
        for row in 0..<board.count {
            for col in 0..<board[row].count {
                
                if let piece = board[row][col] {
                    if piece.player != player {
                        let isInCheck = isValidMove(for: piece, fromRow: row, fromCol: col, toRow: kingRow, toCol: kingCol)
                        if isInCheck {
                            print("The \(player.string) king is in check by piece \(piece.name.string) on (\(row),\(col))")
                            return true
                        }
                    }
                }
                
            }
        }
        
        // If none of the pieces put the king in check, the king is not in check and return false
        return false
        
    }
    
}


