# DragonRuby Tutorial: Creating an Endless Runner

The game we're making is an endless runner, similar to Chrome's offline minigame: http://www.trex-game.skipser.com/. We'll have a player, some obstacles, and the ability to have the player jump over the obstacles. It'll be super cool.

## 00. Project Setup

Create a main directory for your game called `game-demo` inside the dragonruby directory. Inside the `game-demo` directory, create a directory called `app` and within that directory make a file called `main.rb`. Inside `main.rb`, write a method `tick`: 

```ruby
def tick args
  ...
end
```

DragonRuby will call this method every 'tick' of the game loop (https://gamedev.stackexchange.com/questions/651/how-should-i-write-a-main-game-loop). It will be called with an arguments hash that provides high-level details on the application state.

For example, the following code will create a new label on the screen and outupt the current `tick_count`:

```ruby
def tick args
  args.outputs.labels << [640, 380, args.game.tick_count, 0, 1]
end
```

You should have a directory structure that looks like: `~/dragonruby-macos/game-demo/app/main.rb`. To run the example enter the following (you should be in the main DragonRuby directory to run the DragonRuby executable): 

```bash
$ ./dragonruby game-demo
```

The DragonRuby game window will run and display the current tick count in the middle of the screen. Congrats!

Now that we've got the project set up, we'll work on separating out our game logic from the `tick` method to give our project some structure. Create a new class in the `main.rb` file:

```ruby
class Runner
  attr_accessor :game, :grid, :outputs

  # this will run on each tick
  def tick
    outputs.labels << [grid.right / 2, grid.top / 2, game.tick_count, 0, 1]
  end
end
```

Create a new instance of our newly created Runner class and pass it the arguments from our game's `tick` method. The `main.rb` file should now look like this:

```ruby
class Runner
  attr_accessor :game, :grid, :outputs

  # this will run on each tick
  def tick
    outputs.labels << [grid.right / 2, grid.top / 2, game.tick_count, 0, 1]
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
```

## 01. Platforms

Now we'll work on drawing out our platforms and creating the game screen. In `game.rb`, create a method called `render` and invoke it from the `tick` method:

```ruby
class Runner
...
  def tick
    # Redraw the game graphics
    render
  end

  def render
    # draw a black background
    outputs.solids << grid.rect # grid.rect == [grid.left, grid.top, grid.bottom, grid.right]
    # draw the floor
    outputs.solids << [grid.left, grid.bottom, grid.right, 60, 255, 0, 0, 255]
  end
```

Your game should now look something like this:
![01](./assets/01.png?raw=true "Floor")

Now we'll add some obstacles to our game state. We'll set a counter to check when we need to add a new obstacle, and an array to keep track of all the obstacles on the screen. Each tick of the game, we'll recalculate the state for these obstacles:

```ruby
  def tick
    update_state # each tick, update the game state
    render
  end

  def update_state
    ### set default values
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
```

After creating the obstacles in our game state, we need to render them:

```ruby
def render
    ...
    # draw the obstacles
    game.state.obstacles.each do |obstacle| 
      outputs.solids << [obstacle.x, obstacle.y, obstacle.width, obstacle.height, 255, 0, 0, 255]
    end
  end
```


# Extras
## Requiring Files
Create a new file called `game.rb` in the app directory, and move the `Runner` class definition to this file. Back in `main.rb`, add `$dragon.require('app/game.rb')` in `main.rb` to give us access to the code in the `game.rb` file (the normal `require 'game'` syntax won't work). 

_NOTE: DragonRuby's auto-reload feature won't look for changes in files other than `main.rb` so you'll have to restart the DragonRuby instance if you make changes in other files._