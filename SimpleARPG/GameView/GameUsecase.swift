//
//  GameUsecase.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/27/22.
//

import Foundation
import ComposableArchitecture
import BetterCodable

/// On every tick is when combat actions are evaluated
let tickUnit: Double = 0.6 // seconds

enum CombatPlayer: Equatable {
    case player, monster
}

// MARK: Combat Actions
// These are built as global functions instead of living in the reducer
// because the GameClient also needs to run these actions to determine
// the best suggested play for the Monster's AI.

func heal<P: PlayerIdentifiable>(
    player: inout P,
    food: Food,
    slot: InventorySlot
) {
    player.currentLife = min(player.maxLife, player.currentLife + food.restoreAmount)
    player.combatDetails.animation = .eating(food)
    player.combatDetails.actionLocked = true

    if let index = player.inventory.firstIndex(where: { $0 == slot }) {
        player.inventory[index].item = nil
    }
}

func damage<S: PlayerIdentifiable>(
    player: inout S,
    damage: Damage
) {
    player.currentLife = max(0, player.currentLife - damageAfterApplyingArmour(damage: damage, armor: player.totalArmour).rawAmount)
    player.damageLog.append(.init(damage: damage, show: false))
}

func damageAfterApplyingArmour(
    damage: Damage,
    armor: Double
) -> Damage {
    guard damage.type.isPhysical else { return damage }
    let reduction = armor / (armor + 50 * damage.rawAmount)
    let newDamage = damage.rawAmount - (damage.rawAmount * reduction)
    return Damage(type: damage.type, rawAmount: newDamage)
}

func message<S: PlayerIdentifiable>(
    player: inout S,
    message: Message
) {
    player.currentMessage = message
}

func attemptLoot<S: PlayerIdentifiable>(
    player: inout S,
    item: Item
) -> Bool {
    if item.stackable,
        let index = player.inventory.firstIndex(where: { $0.item?.key == item.key }),
        let originalItem = player.inventory.first(where: { $0.item?.key == item.key })?.item {

        switch item {
        case let .coins(coins):
            guard case let .coins(coins2) = originalItem else { return false }
            player.inventory[index].item = .coins(coins + coins2)
            return true
        default: return false
        }
    } else if let index = player.inventory.firstIndex(where: { $0.item == nil }) {
        player.inventory[index].item = item
        return true
    }
    return false
}

// --

struct GameState: Equatable, Codable {
    /// This flag controls whether we did the intial loading of the Player/State.
    /// Opted to used this flag instead of having an optional Player.
    @CodableIgnored<DefaultFalseStrategy>
    var didSetup: Bool = false

    var player = Player()
    var pastEncounters: [PastEncounterState] = []
    var encounter: Encounter?

    var vendors: [Vendor] = []

    var selectedTab: Tab = .inventory

    var currentPreviewingItem: Item?
    var previewingEncounter: PreviewingEncounter?

    var inventoryLocalState: InventoryLocalState = .init()
    var statsViewLocalState: StatsViewLocalState = .init()
    var talentTreeLocalState: TalentTreeLocalState = .init()
}

enum GameAction: Equatable {
    case saveGameStateResult(Result<Success, LocalStore.Error>)
    case loadGameStateResult(Result<GameState?, LocalStore.Error>)
    case gameSaveTimerTicked

    case onAppear
    case updateTab(Tab)

    case combatBeginTimerTicked
    case combatTimerTicked
    case showDamageLogEntry(DamageLogEntry)
    case hideDamageLogEntry(DamageLogEntry)
    case executeSpecialAttack(SpecialAttack)

    case clearAnimation(CombatPlayer)
    case clearMonsterActionLock

    case beginEncounter(Encounter)
    case reviveTapped
    case exitEncounterTapped

    case closePreview

    case unequip(Equipment)

    case inventoryAction(InventoryAction)
    case statsViewAction(StatsViewAction)
    case messageAction(MessageAction)
    case vendorViewAction(VendorAction)
    case specialAttack(SpecialAttackAction)
    case talentTreeAction(TalentTreeAction)

    case bestMoveForActivePlayerResult(Result<GameModelMove?, CombatClient.Error>)
    case attemptLoot(InventorySlot)

    // MARK: Debug
    case addRandomEncounter

    // MARK: Noops
    case resetCombatClientModelResult(Result<Success, CombatClient.Error>)
    case updateCombatClientActivePlayerResult(Result<Success, CombatClient.Error>)
    case updateCombatClientGameStateResult(Result<Success, CombatClient.Error>)
}

struct GameEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var localStore: LocalStoreClient
    var combatClient: CombatClient
    var inventory: InventoryEnvironment

    static let live: Self = .init(mainQueue: .main, localStore: .live, combatClient: .init(), inventory: .live)
}

let gameReducer = Reducer<GameState, GameAction, GameEnvironment>.combine(
    .init { state, action, env in
        enum GameSaveTimerId {}
        enum CombatBeginTimerId {}
        enum CombatTimerId {}
        enum MonsterCombatLockedCancelId {}

        // MARK: Reusable Effects
        func updateCombatClientGameState() -> Effect<GameAction, Never> {
            env.combatClient.updateGameState(state)
                .catchToEffect()
                .map(GameAction.updateCombatClientGameStateResult)
        }

        func updateCombatClientActivePlayer(_ playerIdentifiable: PlayerIdentifiable) -> Effect<GameAction, Never> {
            env.combatClient.updateActivePlayer(playerIdentifiable)
                .catchToEffect()
                .map(GameAction.updateCombatClientActivePlayerResult)
        }

        func clearMonsterActionLock(tickUnits: Double) -> Effect<GameAction, Never> {
            Effect(value: .clearMonsterActionLock)
                .delay(for: .init(floatLiteral: tickUnit * tickUnits), scheduler: env.mainQueue)
                .eraseToEffect()
                .cancellable(id: MonsterCombatLockedCancelId.self, cancelInFlight: true)
        }

        func clearAnimation(for combatPlayer: CombatPlayer, delay: Double, cancelId: UUID) -> Effect<GameAction, Never> {
            Effect(value: .clearAnimation(combatPlayer))
                .delay(for: .init(floatLiteral: delay), scheduler: env.mainQueue)
                .eraseToEffect()
                .cancellable(id: cancelId)
        }

        func executeSpecialAttack(special: SpecialAttack, delay: Double) -> Effect<GameAction, Never> {
            Effect(value: .executeSpecialAttack(special))
                .delay(for: .init(floatLiteral: delay), scheduler: env.mainQueue)
                .eraseToEffect()
        }
        // --

        switch action {
        // MARK: Began Encounter
        case let .beginEncounter(encounter):
            state.encounter = encounter

            // Clear the preview and the encounter from the inventory
            if let item = state.previewingEncounter?.slot.item,
               let index = state.player.inventory.firstIndex(where: { $0 == state.previewingEncounter?.slot }) {
                state.player.inventory[index].item = nil
                state.previewingEncounter = nil
            }

            let combatGameModel = GameModel(
                players: [GameModelPlayer(playerId: state.player.playerId), GameModelPlayer(playerId: encounter.monster.playerId)],
                gameState: state
            )

            return Effect.merge(
                Effect.timer(id: CombatBeginTimerId.self, every: 1, on: env.mainQueue)
                    .animation(.spring())
                    .map { _ in .combatBeginTimerTicked },
                env.combatClient.resetModel(gameModel: combatGameModel)
                    .catchToEffect()
                    .map(GameAction.resetCombatClientModelResult)
            )

        // MARK: Combat Countdown
        case .combatBeginTimerTicked:
            state.encounter?.combatBeginTimerCount -= 1

            if state.encounter?.combatBeginTimerCount == -1 {
                return Effect.merge([
                    Effect.cancel(id: CombatBeginTimerId.self),
                    Effect.timer(id: CombatTimerId.self, every: .init(floatLiteral: tickUnit), on: env.mainQueue).map { _ in .combatTimerTicked }
                ])
            }

        // MARK: Combat Timer Ticked
        case .combatTimerTicked:
            guard let encounter = state.encounter, !encounter.isOver else { return .none }
            var effects: [Effect<GameAction, Never>] = [
                env.combatClient.bestMoveForActivePlayer()
                    .receive(on: env.mainQueue)
                    .catchToEffect()
                    .map(GameAction.bestMoveForActivePlayerResult)
                    .animation(.default),

                updateCombatClientGameState()
            ]

            state.encounter?.tickCount += 1
            // Apply life regen
            state.player.currentLife = min(state.player.maxLife, state.player.currentLife + state.player.lifeRegenPerTick)
            print(state.player.currentLife)

            // Restore special attack resource
            if encounter.tickCount % Int(SpecialAttack.ticksPerRestore) == 0 {
                state.player.specialResource = min(SpecialAttack.maxSpecialResource, state.player.specialResource + SpecialAttack.restoreAmount)
                state.encounter?.monster.specialResource = min(SpecialAttack.maxSpecialResource, encounter.monster.specialResource + SpecialAttack.restoreAmount)
            }

            if let special = state.player.combatDetails.queuedSpecialAttack {
                state.player.combatDetails.queuedSpecialAttack = nil
                state.player.combatDetails.animation = .specialAttacking
                state.player.specialResource -= special.resourcePerUse

                effects.append(executeSpecialAttack(special: special, delay: special.animationTimeOffsets.reduce(0, +)))

            } else if state.player.canAttack, // Player attack
               !encounter.monster.isDead,
               encounter.tickCount % state.player.ticksPerAttack == 0 {

                for dam in state.player.damagePerAttack {
                    damage(player: &state.encounter!.monster, damage: dam)

                    if !state.player.combatDetails.isSpecialAttacking {
                        state.player.combatDetails.animation = .attacking
                    }

                    state.player.currentLevelExperience += dam.rawAmount * 4
                    state.player.totalExperience += dam.rawAmount * 4
                }

                if state.player.currentLevelExperience >= state.player.expForNextLevel {
                    state.player.currentLevelExperience = 0
                    state.player.level += 1
                    state.player.talentPoints += 1
                }

                effects.append(clearAnimation(for: .player, delay: 0.2, cancelId: state.player.combatDetails.animationEffectCancelId))
            }

            // Monster's attack
            if encounter.monster.canAttack,
               !state.player.isDead,
               encounter.tickCount % encounter.monster.ticksPerAttack == 0 {

                #if os(iOS)
                    Haptics.error()
                #endif

                for dam in encounter.monster.damagePerAttack {
                    damage(
                        player: &state.player,
                        damage: dam
                    )
                }

                state.encounter!.monster.combatDetails.animation = .attacking
                effects.append(clearAnimation(for: .monster, delay: 0.2, cancelId: encounter.monster.combatDetails.animationEffectCancelId))
            }

            if state.player.isDead {
                state.player.allEquipment = []
                state.encounter?.winLossState = .loss

                effects.append(.cancel(id: CombatTimerId.self))
            } else if encounter.monster.isDead {
                state.encounter?.winLossState = .win
                for equipment in encounter.monster.allEquipment {
                    let inventorySlot = InventorySlot(item: .equipment(equipment))
                    state.encounter?.monster.inventory.append(inventorySlot)
                }

                effects.append(.cancel(id: CombatTimerId.self))
            }

            return Effect.merge(effects)
        case let .bestMoveForActivePlayerResult(result):
            var effects: [Effect<GameAction, Never>] = []

            if case let .success(move) = result {
                guard let move = move, let monster = state.encounter?.monster else { return .none }

                // Player's suggested move
                if move.playerId == state.player.playerId {
                    effects.append(updateCombatClientActivePlayer(monster))
                }
                // Monster's suggested move
                else if move.playerId == monster.playerId {

                    // The AI thinks attacking is a valid move even though the monster attacks on a timer.
                    // When it thinks a non-attack move is the best, it likely will sacrifice an attack from being combat-locked
                    switch move.move {
                    case let .attack(damage):
                        break // Actually don't need to do anything here, since monsters attack on a timer similar as the Player
                    case let .heal(food, slot):


                        if !state.player.combatDetails.actionLocked {
                            heal(player: &state.encounter!.monster, food: food, slot: slot)

                            effects.append(clearAnimation(for: .monster, delay: tickUnit * 3, cancelId: monster.combatDetails.animationEffectCancelId))
                            effects.append(clearMonsterActionLock(tickUnits: 1))
                        }
                    case let .specialAttack(special):
                        break
                    }

                    effects.append(updateCombatClientActivePlayer(state.player))
                }

                effects.append(updateCombatClientGameState())
                return Effect.merge(effects)
            }
        case let .executeSpecialAttack(special):
            guard let encounter = state.encounter else {
                return .none
            }

            state.player.combatDetails.animation = .none

            switch special {
            case .darkBow:
                darkBow(damager: state.player, player: &state.encounter!.monster)
            }

        case let .clearAnimation(combatPlayer):
            switch combatPlayer {
            case .player:
                state.player.combatDetails.animation = .none
            case .monster:
                state.encounter?.monster.combatDetails.animation = .none
            }
        case .clearMonsterActionLock:
            state.encounter?.monster.combatDetails.actionLocked = false
        case let .showDamageLogEntry(entry):
            guard let encounter = state.encounter else { return .none }

            if let playerIndex = state.player.damageLog.firstIndex(where: { $0.id == entry.id }) {
                state.player.damageLog[playerIndex].show = true
            } else if let monsterIndex = encounter.monster.damageLog.firstIndex(where: { $0.id == entry.id }) {
                state.encounter?.monster.damageLog[monsterIndex].show = true
            }

            return Effect(value: .hideDamageLogEntry(entry))
                .delay(for: .init(floatLiteral: tickUnit * 2), scheduler: env.mainQueue)
                .eraseToEffect()

        case let .hideDamageLogEntry(entry):
            guard let encounter = state.encounter else { return .none }

            if let playerIndex = state.player.damageLog.firstIndex(where: { $0.id == entry.id }) {
                state.player.damageLog[playerIndex].show = false
            } else if let monsterIndex = encounter.monster.damageLog.firstIndex(where: { $0.id == entry.id }) {
                state.encounter?.monster.damageLog[monsterIndex].show = false
            }
        case let .unequip(equipment):
            // If there's a slot that has no item...
            if let index = state.player.firstOpenInventorySlotIndex {
                state.player.inventory[index].item = .equipment(equipment)
                state.player.allEquipment.removeAll(where: { $0.base.slot == equipment.base.slot })
                state.player.stats.merge(equipment.stats, uniquingKeysWith: -)
            }
        case let .attemptLoot(slot):
            // If the slot has an item and the player has an open inventory slot...
            if let encounter = state.encounter,
                let item = slot.item,
                let monsterInvIndex = state.encounter!.monster.inventory.firstIndex(where: { $0 == slot }) {

                if attemptLoot(player: &state.player, item: item) {
                    state.encounter!.monster.inventory[monsterInvIndex].item = nil
                }
            }
        case .reviveTapped, .exitEncounterTapped:
            guard let encounter = state.encounter else { return .none }
            state.pastEncounters.append(PastEncounterState(encounter: encounter, playerDamageLog: state.player.damageLog))
            state.encounter = nil
            state.player.damageLog = []
            state.player.currentLife = state.player.maxLife
            state.player.specialResource = SpecialAttack.maxSpecialResource

            state.vendors = .init([
                .init(
                    type: .items,
                    level: state.player.level,
                    player: state.player
                ),
                .init(
                    type: .encounters(state.pastEncounters.filter { $0.encounter.winLossState == .win }.map(\.encounter)),
                    level: state.player.level,
                    player: state.player
                )
            ])

            return .cancel(id: CombatTimerId.self)
        case .closePreview:
            state.currentPreviewingItem = nil
            state.previewingEncounter = nil
        case let .updateTab(tab):
            state.selectedTab = tab
        case .onAppear:
            if !state.didSetup {
                state.vendors = .init([
                    .init(
                        type: .items,
                        level: state.player.level,
                        player: state.player
                    ),
                    .init(
                        type: .encounters(state.pastEncounters.filter { $0.encounter.winLossState == .win }.map(\.encounter)),
                        level: state.player.level,
                        player: state.player
                    )
                ])

                return Effect.merge([
                    env.localStore
                        .loadGameState()
                        .catchToEffect()
                        .map(GameAction.loadGameStateResult),
                    Effect.timer(id: GameSaveTimerId.self, every: 1, on: env.mainQueue)
                        .animation(.spring())
                        .map { _ in .gameSaveTimerTicked }
                ])
            }
        case let .loadGameStateResult(result):
            switch result {
            case let .success(gameState):
                if let gameState = gameState {
                    state = gameState
                    if state.encounter != nil {
                        state.encounter = nil
                        state.player.currentLife = state.player.maxLife
                        state.player.specialResource = SpecialAttack.maxSpecialResource
                    }
                }
                state.didSetup = true
            case let .failure(error):
                print(error)
            }
        case .gameSaveTimerTicked:
            return env.localStore
                .saveGameState(state)
                .catchToEffect()
                .map(GameAction.saveGameStateResult)
        case .saveGameStateResult:
            return .none
        case .inventoryAction,
            .statsViewAction,
            .messageAction,
            .vendorViewAction,
            .specialAttack,
            .talentTreeAction,
            .resetCombatClientModelResult,
            .updateCombatClientGameStateResult,
            .updateCombatClientActivePlayerResult:
            break
        case .addRandomEncounter:
            let encounter = Encounter.generate(level: state.player.level, rarity: Encounter.Rarity.rarity(), player: state.player)
            guard let firstEmptyIndex = state.player.firstOpenInventorySlotIndex
            else { return .none }

            state.player.inventory[firstEmptyIndex].item = .encounter(encounter)
        }
        return .none
    },

    inventoryReducer
        .pullback(state: \.inventoryState, action: /GameAction.inventoryAction, environment: \.inventory),

    statsViewReducer
        .pullback(state: \.statsViewState, action: /GameAction.statsViewAction, environment: { _ in
            .init()
        }),

    messageReducer
        .pullback(state: \.messageState, action: /GameAction.messageAction, environment: { env in
            .init(mainQueue: env.mainQueue)
        }),

    vendorReducer
        .pullback(state: \.vendorViewState, action: /GameAction.vendorViewAction, environment: { env in
            .init()
        }),

    specialAttackReducer
        .pullback(state: \.specialAttack, action: /GameAction.specialAttack, environment: { env in
            .init(mainQueue: env.mainQueue)
        }),

    talentTreeReducer
        .pullback(state: \.talentTreeState, action: /GameAction.talentTreeAction, environment: { env in
            .init()
        })
)

