//
//  ContentView.swift
//  ChessGame
//
//  Created by Caleb Marquart on 2022-12-23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var game = Gameboard()
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    Rectangle()
                        .fill(game.playerTurn == .white ? Color.brown : Color.clear)
                        .cornerRadius(10)
                    Text("White")
                        .font(.headline)
                        .bold()
                }
                .frame(width: 80, height: 32)
                
                Spacer()
                Text("Chess Game")
                    .font(.title)
                    .bold()
                Spacer()
                ZStack {
                    Rectangle()
                        .fill(game.playerTurn == .black ? Color.brown : Color.clear)
                        .cornerRadius(10)
                    Text("Black")
                        .font(.headline)
                        .bold()
                }
                .frame(width: 80, height: 32)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 8)
            
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    ForEach(0..<8) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<8)  { col in
                                ZStack {
                                    Rectangle()
                                        .fill(row % 2 == col % 2 ? Color.gray : Color.brown)
                                        .frame(width: 64, height: 64)
                                    if let piece = game.board[row][col {]
                                        if game.isKingInCheck(for: game.playerTurn, on: game.board) && piece.name == .king && game.playerTurn == piece.player {
                                            Rectangle()
                                                .fill(Color.orange)
                                                .frame(width: 64, height: 64)
                                        }
                                    }
                                    
                                    
                                    if let wrapRow = game.selectedRow, let wrapCol = game.selectedCol {
                                        if row == wrapRow && col == wrapCol {
                                            Rectangle()
                                                .fill(Color.yellow)
                                                .frame(width: 64, height: 64)
                                        }
                                        
                                    }
                                    
                                    if let square = game.board[row][col] {
                                        Image(square.icon)
                                    }
                                }
                                .onTapGesture {
                                    if game.readyToMove {
                                        game.movePiece(fromRow: game.selectedRow!, fromCol: game.selectedCol!, toRow: row, toCol: col)
                                        game.selectedRow = nil
                                        game.selectedCol = nil
                                        game.readyToMove = false
                                    } else {
                                        if game.board[row][col] != nil {
                                            if game.board[row][col]!.player == game.playerTurn {
                                                if game.selectedRow != row || game.selectedCol != col {
                                                    game.selectedRow = row
                                                    game.selectedCol = col
                                                } else {
                                                    game.selectedRow = nil
                                                    game.selectedCol = nil
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: 512, height: 512)
        }
        .frame(width: 512)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




