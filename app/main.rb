$dragon.require('app/game.rb')

class Runner
  attr_accessor :game, :grid, :outputs, :inputs

  def tick
    process_inputs
    update_state
    render
  end

  def process_inputs
    if inputs.keyboard.key_down.space && !game.state.player.jumping
      game.state.player.jumping = true
      game.state.player.dy = 15
    end
  end

  def update_state
    ### set default values
    # obstacles
    game.state.obstacles ||= []
    game.state.obstacle_countdown ||= 100

    # player
    game.state.player.x ||= grid.left + 60
    game.state.player.y ||= grid.bottom + 60
    game.state.player.dy ||= 0 # this will be used to calculate player movement on the y axis
    game.state.player.jumping ||= false

    ### calculate new state on each tick
    # handle jumps
    if game.state.player.jumping
      # update y coordinate
      game.state.player.y += game.state.player.dy
      # update the dy value
      game.state.player.dy -= 0.9 # gravity!
      # hit the floor?
      if game.state.player.y <= grid.bottom + 60
        game.state.player.dy = 0
        game.state.player.jumping = false
        game.state.player.y = 60
      end
    end
    
    # decrement countdown
    game.state.obstacle_countdown -= 1

    # move the obstacles left 8 pixels each frame
    game.state.obstacles.each { |w| w.x -= 8 }
    
    # remove the obstacles if they leave the screen
    game.state.obstacles.reject! { |w| w.x < -w.width }

    # generate a new obstacle each 100 ticks
    if game.state.obstacle_countdown == 0
      # reset the countdown
      new_countdown = rand(50) + 100
      game.state.obstacle_countdown = new_countdown
      # create a new game object
      obstacle = game.new_entity(:obstacle) do |o|
        # set position for new obstacle
        o.x = grid.right
        o.y = grid.bottom + 60
        o.width = 40
        o.height = 80
      end
      
      # add it to our game state
      game.state.obstacles << obstacle
    end

  end

  def render
    # draw a black background
    outputs.solids << grid.rect # grid.rect == [grid.left, grid.top, grid.bottom, grid.right]
    # draw the floor
    outputs.solids << [grid.left, grid.bottom, grid.right, 60, 255, 0, 0, 255]

    # draw the obstacles
    game.state.obstacles.each do |obstacle| 
      outputs.solids << [obstacle.x, obstacle.y, obstacle.width, obstacle.height, 255, 0, 0, 255]
    end

    # draw the player
    outputs.solids << [game.state.player.x, game.state.player.y, 60, 60, 0, 0, 255, 255]
  end
end

# create our game instance
$runner = Runner.new

# main DragonRuby game loop
def tick args
  # pass info from DragonRuby tick to game instance
  $runner.game    = args.game
  $runner.grid    = args.grid
  $runner.outputs = args.outputs
  $runner.inputs = args.inputs

  # invoke tick on the game
  $runner.tick
end