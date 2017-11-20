# status_effect.rb

class StatusEffect
  CONDITION_ACRONYMS = {
    'blinded' => 'BLD',
    'unconscious' => 'UNC',
    'paralyzed' => 'PAR',
    'invisible' => 'INV',
    'poisoned' => 'PSN'
  }

  attr_accessor :turn, :battle, :long_term, :conditions

  def initialize
    @turn = StatusTurn.new
    @battle = StatusBattle.new
    @long_term = StatusLong.new
    @conditions = [] # Array of String
  end

  def add_turn(attribute, factor)
    turn.add(attribute, factor)
  end

  def add_battle(attribute, factor)
    battle.add(attribute, factor)
  end

  def add_long_term(attribute, factor)
    long_term.add(attribute, factor)
  end

  def add_condition(condition)
    case condition
    when 'blinded' then conditions << 'blinded'
    when 'unconscious' then conditions << 'unconscious'
    when 'paralyzed' then conditions << 'paralyzed'
    when 'invisible' then conditions << 'invisible'
    when 'poisoned' then conditions << 'poisoned'
    end
  end

  def clear_condition(condition)
    conditions.reject! { |cond| cond == condition }
  end

  def cond_acronym
    return ['NONE'] if conditions.empty?
    conditions.map { |condition| CONDITION_ACRONYMS[condition] }
  end

  def clear_all_turn
    turn.clear_all
  end

  def clear_all_battle
    battle.clear_all
    conditions.clear
  end

  def clear_all_long_term
    long_term.clear_all
  end

  def max_hp
    turn.max_hp + battle.max_hp + long_term.max_hp
  end

  def armor_class
    turn.armor_class + battle.armor_class + long_term.armor_class
  end
end

class Status
  attr_accessor :max_hp, :armor_class

  def initialize
    @max_hp = 0 # Integer
    @armor_class = 0 # Integer
  end

  def add(attribute, factor)
    case attribute
    when :max_hp then self.max_hp += factor
    when :armor_class then self.armor_class += factor
    end
  end

  def clear_all
    self.max_hp = 0
    self.armor_class = 0
  end
end

class StatusTurn < Status; end

class StatusBattle < Status; end

class StatusLong < Status; end
