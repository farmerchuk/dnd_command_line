# action_handler.rb

require_relative 'dnd'

class ActionHandler
  attr_accessor :players, :current_player, :locations

  def initialize(players, locations)
    @players = players
    @current_player = players.current
    @locations = locations
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
