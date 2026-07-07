class Battle::Battler
  alias BB_pbFaint pbFaint

  def pbFaint(showMessage = true)
    if @pokemon
      preevo = GameData::Species.get(@pokemon.species).get_previous_species
      if preevo != @pokemon.species
        @battle.pbDisplay(_INTL("{1} devolved!", pbThis))
        @pokemon.species = preevo
        if !@pokemon.nicknamed?
          @pokemon.name = GameData::Species.get(preevo).name
        end
        @pokemon.calc_stats
        @pokemon.hp = @pokemon.totalhp
        pbInitialize(@pokemon, @index)
        @hp = @totalhp
        @pokemon.hp = @hp
        @battle.scene.pbChangePokemon(self, @pokemon)
        @battle.scene.pbRefreshOne(@index) if @battle.scene.respond_to?(:pbRefreshOne)
        @damageState.reset
        return false
      end
    end
    BB_pbFaint(showMessage)
  end
end