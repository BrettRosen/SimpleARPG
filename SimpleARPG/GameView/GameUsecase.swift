//
//  GameUsecase.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/27/22.
//

import ComposableArchitecture

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
    player.combatLockDetails.animation = .eating(food)
    player.combatLockDetails.actionLocked = true

    if let index = player.inventory.firstIndex(where: { $0 == slot }) {
        player.inventory[index].item = nil
    }
}

func damage<S: PlayerIdentifiable>(
    player: inout S,
    damage: Damage
) {
    player.currentLife = max(0, player.currentLife - damage.rawAmount)
    player.damageLog.append(.init(damage: damage, show: false))
}

func message<S: PlayerIdentifiable>(
    player: inout S,
    message: Message
) {
    player.currentMessage = message
}

// --

struct GameState: Equatable {
    var player = Player()
    var pastEncounters: [PastEncounterState] = []
    var encounter: Encounter?

    var vendor: Vendor = .init()

    var selectedTab: Tab = .inventory

    var currentPreviewingItem: Item?
    var previewingEncounter: PreviewingEncounter?

    var inventoryLocalState: InventoryLocalState = .init()
    var statsViewLocalState: StatsViewLocalState = .init()

    /// This is so that `onAppear` action is only executed once as it'll be used for
    /// some initialization
    var didAppear: Bool = false
}

enum GameAction: Equatable {
    case onAppear
    case updateTab(Tab)

    case combatBeginTimerTicked
    case combatTimerTicked
    case showDamageLogEntry(DamageLogEntry)
    case hideDamageLogEntry(DamageLogEntry)

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
    var combatClient: CombatClient
    var inventory: InventoryEnvironment

    static let live: Self = .init(mainQueue: .main, combatClient: .init(), inventory: .live)
}

let gameReducer = Reducer<GameState, GameAction, GameEnvironment>.combine(
    .init { state, action, env in
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

            // Player's attack
            if state.player.canAttack,
               !encounter.monster.isDead,
               encounter.tickCount % state.player.ticksPerAttack == 0 {

                print("Player attacking")
                for dam in state.player.damagePerAttack {
                    damage(player: &state.encounter!.monster, damage: dam)

                    state.player.combatLockDetails.animation = .attacking

                    state.player.currentLevelExperience += dam.rawAmount * 4
                    state.player.totalExperience += dam.rawAmount * 4
                }

                if state.player.currentLevelExperience >= state.player.expForNextLevel {
                    state.player.currentLevelExperience = 0
                    state.player.level += 1
                }

                effects.append(clearAnimation(for: .player, delay: 0.2, cancelId: state.player.combatLockDetails.animationEffectCancelId))
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

                state.encounter!.monster.combatLockDetails.animation = .attacking
                effects.append(clearAnimation(for: .monster, delay: 0.2, cancelId: encounter.monster.combatLockDetails.animationEffectCancelId))
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
                        print("Monster wants to attack")
                        break // Actually don't need to do anything here, since monsters attack on a timer similar as the Player
                    case let .heal(food, slot):


                        if !state.player.combatLockDetails.actionLocked {
                            print("Monster wants to eat")
                            heal(player: &state.encounter!.monster, food: food, slot: slot)

                            effects.append(clearAnimation(for: .monster, delay: tickUnit * 3, cancelId: monster.combatLockDetails.animationEffectCancelId))
                            effects.append(clearMonsterActionLock(tickUnits: 1))
                        }
                    }

                    effects.append(updateCombatClientActivePlayer(state.player))
                }

                effects.append(updateCombatClientGameState())
                return Effect.merge(effects)
            }
        case let .clearAnimation(combatPlayer):
            switch combatPlayer {
            case .player:
                state.player.combatLockDetails.animation = .none
            case .monster:
                state.encounter?.monster.combatLockDetails.animation = .none
            }
        case .clearMonsterActionLock:
            state.encounter?.monster.combatLockDetails.actionLocked = false
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
                for stat in equipment.stats {
                    state.player.stats[stat.key]! -= stat.value
                }
            }
        case let .attemptLoot(slot):
            // If the slot has an item and the player has an open inventory slot...
            if let encounter = state.encounter,
                let item = slot.item,
                let playerInvIndex = state.player.firstOpenInventorySlotIndex,
                let monsterInvIndex = state.encounter!.monster.inventory.firstIndex(where: { $0 == slot }) {

                state.encounter!.monster.inventory[monsterInvIndex].item = nil
                state.player.inventory[playerInvIndex].item = item
            }
        case .reviveTapped, .exitEncounterTapped:
            guard let encounter = state.encounter else { return .none }
            let pastEncounter = PastEncounterState(encounter: encounter, playerDamageLog: state.player.damageLog)
            state.encounter = nil
            state.player.damageLog = []
            state.player.currentLife = state.player.maxLife
            return .cancel(id: CombatTimerId.self)
        case .closePreview:
            state.currentPreviewingItem = nil
            state.previewingEncounter = nil
        case let .updateTab(tab):
            state.selectedTab = tab
        case .onAppear:
            guard !state.didAppear else { return .none }
            state.vendor = Vendor(name: "Nathaniel", icon: "🥸", level: state.player.level)
            state.didAppear = true
        case .inventoryAction,
            .statsViewAction,
            .messageAction,
            .vendorViewAction,
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
        })
)

