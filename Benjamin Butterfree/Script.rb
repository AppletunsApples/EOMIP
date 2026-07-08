class Battle::Battler
  alias BB_pbInitialize pbInitialize
  def pbInitialize(pokemon, idx, *args)
    BB_pbInitialize(pokemon, idx, *args)
    return if !pokemon
    @battle_start_species = pokemon.species
    @battle_start_moves = pokemon.moves.clone
  end

  alias BB_pbFaint pbFaint
  def pbFaint(showMessage = true)
    if @pokemon
      preevo = GameData::Species.get(@pokemon.species).get_previous_species
      if preevo != @pokemon.species
        @battle.pbDisplay(_INTL("{1} devolved!", pbThis))
        @pokemon.species = preevo
        @pokemon.name = GameData::Species.get(preevo).name if !@pokemon.nicknamed?
        @pokemon.calc_stats
        @pokemon.hp = @pokemon.totalhp
        pbInitialize(@pokemon, @index)
        @hp = @totalhp
        @battle.scene.pbChangePokemon(self, @pokemon)
        @battle.scene.pbRefreshOne(@index) if @battle.scene.respond_to?(:pbRefreshOne)
        @damageState.reset
        return false
      end
    end
    BB_pbFaint(showMessage)
  end
end

# Event Handlers for post-battle species restoring
class Game_Temp
  attr_accessor :original_battle_species
end

EventHandlers.add(:on_start_battle, :record_original_species,
  proc {
    $game_temp.original_battle_species = []
    $player.party.each_with_index do |pkmn, i|
      $game_temp.original_battle_species[i] = pkmn.species
    end
  }
)

EventHandlers.add(:on_end_battle, :restore_devolved_species,
  proc { |_decision, _canLose|
    next if !$game_temp.original_battle_species
    $player.party.each_with_index do |pkmn, i|
      next if !pkmn
      next if !$game_temp.original_battle_species[i]

      pkmn.species = $game_temp.original_battle_species[i]
      pkmn.calc_stats
    end
    $game_temp.original_battle_species = nil
  }
)