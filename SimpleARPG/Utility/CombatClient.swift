//
//  CombatClient.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/18/22.
//

import ComposableArchitecture
import Foundation
import GameplayKit

struct Success: Equatable { }

enum CombatMove {
    case attack(damage: Damage)
    case heal(Food, InventorySlot)
}

class CombatClient {
    struct Error: Swift.Error, Equatable {
        var description: String = ""
    }

    var gameModel: GameModel!
    var strategist: GKMinmaxStrategist!

    init() { }

    func resetModel(gameModel: GameModel) -> Effect<Success, CombatClient.Error> {
        self.gameModel = gameModel
        self.strategist = .init()
        self.strategist.maxLookAheadDepth = 7
        self.strategist.randomSource = GKRandomSource()
        self.strategist.gameModel = self.gameModel
        return .init(value: .init())
    }

    func updateGameState(_ gameState: GameState) -> Effect<Success, CombatClient.Error> {
        gameModel.gameState = gameState
        return .init(value: .init())
    }

    func updateActivePlayer(_ player: PlayerIdentifiable) -> Effect<Success, CombatClient.Error> {
        gameModel.updateActivePlayer(player)
        return .init(value: .init())
    }

    func bestMoveForActivePlayer() -> Effect<GameModelMove?, CombatClient.Error> {
        Effect.future { callback in
            DispatchQueue.main.async { [unowned self] in
                callback(.success(self.strategist.bestMoveForActivePlayer() as? GameModelMove))
            }
        }
    }
}

/// Used just for identifying players in the GameModel
class GameModelPlayer: NSObject, GKGameModelPlayer {
    var playerId: Int
    init(playerId: Int) { self.playerId = playerId }
}

class GameModelMove: NSObject, GKGameModelUpdate {
    var value: Int = 0
    var move: CombatMove
    var playerId: Int

    init(move: CombatMove, playerId: Int) {
        self.move = move
        self.playerId = playerId
    }
}

class GameModel: NSObject, GKGameModel {
    var players: [GKGameModelPlayer]?
    var activePlayer: GKGameModelPlayer?

    var gameState: GameState

    init(
        players: [GKGameModelPlayer],
        gameState: GameState
    ) {
        self.players = players
        self.gameState = gameState

        // Player is the first active
        self.activePlayer = players.first(where: { $0.playerId == gameState.player.playerId })
        super.init()
    }

    func updateActivePlayer(_ player: PlayerIdentifiable) {
        self.activePlayer = players?.first(where: { $0.playerId == player.playerId })
    }

    func setGameModel(_ gameModel: GKGameModel) {
        if let gameModel = gameModel as? GameModel {
            players = gameModel.players
            activePlayer = gameModel.activePlayer
            gameState = gameModel.gameState
        }
    }

    func getPlayerIdentifiable(from player: GKGameModelPlayer) -> PlayerIdentifiable? {
        var playerIdentifiable: PlayerIdentifiable?
        if player.playerId == gameState.player.playerId {
            playerIdentifiable = gameState.player
        } else if player.playerId == gameState.encounter!.monster.playerId {
            playerIdentifiable = gameState.encounter!.monster
        }
        return playerIdentifiable
    }

    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        guard let playerIdentifiable = getPlayerIdentifiable(from: player),
              let opponent = opponent(for: player)
        else { return nil }

        if isWin(for: player) || isWin(for: opponent) || isLoss(for: player) || isLoss(for: opponent) {
            return nil
        }

        var moves = [GameModelMove]()
        let attackMove = GameModelMove.init(move: .attack(damage: playerIdentifiable.damagePerAttack), playerId: player.playerId)

        // If the player has food and eating food would put them at or below their max health,
        // then register eating as a valid move...
        if let slot = playerIdentifiable.inventory.first(where: {
            if case .food = $0.item {
                return true
            }
            return false
        }), case let .food(food) = slot.item, playerIdentifiable.currentLife + food.restoreAmount <= playerIdentifiable.maxLife {
            moves.append(.init(move: .heal(food, slot), playerId: player.playerId))
        }

        moves.append(attackMove)
        return moves
    }

    func opponent(for playerIdentifiable: PlayerIdentifiable) -> PlayerIdentifiable? {
        if isPlayer(playerId: playerIdentifiable.playerId){
            return gameState.encounter!.monster
        } else if isCurrentMonster(playerId: playerIdentifiable.playerId) {
            return gameState.player
        } else {
            return nil
        }
    }

    func opponent(for player: GKGameModelPlayer) -> GKGameModelPlayer? {
        if isPlayer(playerId: player.playerId) {
            return players?.first(where: { $0.playerId == gameState.encounter!.monster.playerId })
        } else if isCurrentMonster(playerId: player.playerId) {
            return players?.first(where: { $0.playerId == gameState.player.playerId })
        } else {
            return nil
        }
    }

    func isWin(for player: GKGameModelPlayer) -> Bool {
        if isPlayer(playerId: player.playerId) {
            return gameState.encounter!.monster.isDead
        } else if isCurrentMonster(playerId: player.playerId) {
            return gameState.player.isDead
        } else {
            return false
        }
    }

    func isLoss(for player: GKGameModelPlayer) -> Bool {
        if isPlayer(playerId: player.playerId) {
            return gameState.player.isDead
        } else if isCurrentMonster(playerId: player.playerId) {
            return gameState.encounter!.monster.isDead
        } else {
            return false
        }
    }

    func score(for player: GKGameModelPlayer) -> Int {
        guard let player = getPlayerIdentifiable(from: player), let opponent = opponent(for: player) else { return 0 }
        var score: Double = 0

        if player.currentLife/player.maxLife > opponent.currentLife/opponent.maxLife {
            score += 10
        }

        if player.damagePerAttack.rawAmount >= opponent.currentLife {
            score += 30
        }

        score += player.currentLife/player.maxLife * 10

        return Int(score)
    }

    func isPlayer(playerId: Int) -> Bool {
        playerId == gameState.player.playerId
    }

    func isCurrentMonster(playerId: Int) -> Bool {
        playerId == gameState.encounter!.monster.playerId
    }

    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        if let gameModelUpdate = gameModelUpdate as? GameModelMove, let player = activePlayer {

            switch gameModelUpdate.move {
            case let .attack(damagePacket):
                isPlayer(playerId: player.playerId)
                    ? damage(
                        player: &gameState.encounter!.monster,
                        damage: damagePacket
                    )
                    : damage(
                        player: &gameState.player,
                        damage: damagePacket
                    )
            case let .heal(food, slot):
                isPlayer(playerId: player.playerId)
                    ? heal(player: &gameState.player, food: food, slot: slot)
                    : heal(player: &gameState.encounter!.monster, food: food, slot: slot)
            }

            activePlayer = opponent(for: (activePlayer as! GameModelPlayer))
        }
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = GameModel(players: players ?? [], gameState: gameState)
        copy.setGameModel(self)
        return copy
    }
}
