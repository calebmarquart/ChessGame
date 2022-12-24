//
//  Models.swift
//  ChessGame
//
//  Created by Caleb Marquart on 2022-12-23.
//

import SwiftUI

struct Piece: Identifiable {
    let id = UUID()
    let icon: String
    let player: Player
    let name: PieceType
    
    init(name: PieceType, player: Player) {
        self.player = player
        self.name = name
        var imageName = ""
        
        switch player {
        case .white:
            imageName += "white"
        case .black:
            imageName += "black"
        }
        
        switch name {
        case .queen:
            imageName += "Queen"
        case .rook:
            imageName += "Rook"
        case .king:
            imageName += "King"
        case .pon:
            imageName += "Pon"
        case .bishop:
            imageName += "Bishop"
        case .knight:
            imageName += "Knight"
        }
        
        self.icon = imageName
    }
}

enum Player {
    case white
    case black
}

enum PieceType {
    case queen
    case rook
    case king
    case pon
    case bishop
    case knight
}

enum Line {
    case horizontal
    case vertial
    case diagonal
}

struct Move {
    let fromRow: Int
    let fromCol: Int
    let toRow: Int
    let toCol: Int
}

extension Player {
    var string: String {
        return self == .black ? "black" : "white"
    }
}

extension PieceType {
    var string: String {
        switch self {
        case .queen:
            return "Queen"
        case .rook:
            return "Rook"
        case .king:
            return "King"
        case .pon:
            return "Pon"
        case .bishop:
            return "Bishop"
        case .knight:
            return "Knight"
        }
    }
}
