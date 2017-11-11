# player_action_handler.rb

require_relative 'dnd'

module PlayerActionHandler
  def run
    display_summary
    current_player.start_turn
    player_choose_first_action

    if current_player.action == 'move'
      run_action
      player_selects_action
      run_action
    else
      player_selects_action
      run_action
      current_player.action = 'move' if player_also_move?
      run_action
    end
    Menu.prompt_for_next_turn
  end

  def player_selects_action
    loop do
      puts "What action would #{current_player.name} like to take?"
      role = current_player.role.to_s

      options = eval "#{role.capitalize}::#{action_type.upcase}_ACTIONS"
      current_player.action = Menu.choose_from_menu(options)

      break if action_possible?(action_type)
      display_summary
      display_action_error
    end
  end

  def execute_player_action
    case current_player.action
    when 'move' then player_move
    when 'wait' then player_wait
    when 'skill' then player_use_skill
    when 'item' then player_use_item
    when 'rest' then player_rest
    when 'equip' then player_equip
    when 'attack' then player_attack
    when 'magic' then player_magic
    end
  end

  def player_choose_first_action
    puts "What action would #{current_player.name} like to take first?"
    choice = Menu.choose_from_menu(['move', 'other action'])
    choice == 'move' ? current_player.action = 'move' : nil
  end

  def player_also_move?
    puts "Would #{current_player.name} also like to move?"
    choice = Menu.choose_from_menu(['yes', 'no'])
    choice == 'yes' ? true : false
  end

  def player_move
    puts "Where would #{current_player.name} like to move to?"
    available_locations = current_player.location.paths
    current_player.location = Menu.choose_from_menu(available_locations)

    puts "#{current_player} is now at the #{current_player.location.display_name}"
    puts
  end

  def player_wait
    puts "#{current_player} is on alert!"
    puts
  end

  def player_use_skill
    puts "#{current_player} uses a skill."
    puts
  end

  def player_use_item
    puts "#{current_player} uses an item."
    puts
  end

  def player_rest
    puts "#{current_player} rests."
    puts
  end

  def player_magic
    puts "What spell would #{current_player.name} like to use?"
    choose_and_equip_spell
    spell = current_player.equipped_spell
    target = choose_spell_target

    display_summary
    eval(spell.script)
  end

  def choose_and_equip_spell
    available_spells =
      current_player.spells.select { |spell| spell.when == action_type }

    available_spells.each_with_index do |spell, idx|
      puts "#{idx}. #{spell.display_name} - " +
           "#{spell.stat_desc}"
    end

    choice = nil
    loop do
      choice = Menu.prompt.to_i
      break if (0..available_spells.size - 1).include?(choice)
      puts 'Sorry, that is not a valid choice...'
    end
    current_player.equipped_spell = available_spells[choice]
  end

  def choose_spell_target
    if current_player.equipped_spell.target == 'enemy'
      select_enemy_to_attack
    elsif current_player.equipped_spell.target == 'player'
      select_player_to_cast_on
    end
  end

  def select_player_to_cast_on
    puts "Which player would #{current_player.name} like to cast on?"
    targets = targets_in_range(players.to_a)
    choose_target_menu_with_location(targets)
  end

  def targets_in_range(targets)
    targets.select do |target|
      if current_player.action == 'attack'
        action_range = current_player.equipped_weapon.range
      elsif current_player.action == 'magic'
        action_range = current_player.equipped_spell.range
      end
      distance = current_player.location.distance_to(target.location)
      action_range >= distance && !target.dead?
    end
  end

  def choose_target_menu_with_location(targets)
    targets.each_with_index do |target, idx|
      puts "#{idx}. #{target} at #{target.location.display_name} " +
           "(#{target.current_hp} HP)"
    end

    choice = nil
    loop do
      choice = Menu.prompt.to_i
      break if (0..targets.size - 1).include?(choice)
      puts 'Sorry, that is not a valid choice...'
    end
    enemies[choice]
  end

  def action_possible?(current_action_context)
    if current_player.action == 'magic'
      return false unless current_player.spells.any? do |spell|
        spell.when == current_action_context
      end
    end

    if current_player.action == 'attack'
      return false if targets_in_range(enemies).empty?
    end

    true
  end

  def display_action_error
    case current_player.action
    when 'magic'
      puts 'None of your spells would be effective right now.'
    when 'attack'
      puts "No enemies are within range. Try moving closer first or"
      puts "equipping a weapon with greater range."
    end

    puts
    puts 'Please select another option...'
    puts
  end

  def player_equip
    available_equipment = current_player.backpack.all_unequipped_equipment

    if available_equipment.empty?
      puts 'Sorry, all equipment is currently in use...'
    else
      current_player.backpack.view_equippable

      puts "Select the item to equip:"
      choice = Menu.choose_from_menu(available_equipment)

      if choice.instance_of?(Weapon)
        current_player.unequip(current_player.equipped_weapon)
      elsif choice.instance_of?(Armor) && choice.type == 'shield'
        current_player.unequip(current_player.equipped_shield)
      elsif choice.instance_of?(Armor)
        current_player.unequip(current_player.equipped_armor)
      end

      current_player.equip(choice.id)
    end
  end
end
