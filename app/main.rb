$dragon.require('app/game.rb')

class Runner
  attr_accessor :game, :grid, :outputs

  def tick
    update_state
    render
  end

  def update_state
    ### set default values
    # obstacles
    game.state.obstacles ||= []
    game.state.obstacle_countdown ||= 100
    
    ### calculate new state on each tick
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

  # invoke tick on the game
  $runner.tick
end

# def tick args

#   # pass info from game tick to runner instance
#   $runner.grid    = args.grid
#   $runner.inputs  = args.inputs
#   $runner.game    = args.game
#   $runner.outputs = args.outputs

#   # invoke tick on the runner
#   $runner.tick
# end