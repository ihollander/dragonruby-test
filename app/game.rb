# class Runner
#   attr_accessor :grid, :inputs, :game, :outputs

#   # this will run on each tick
#   def tick
#     defaults
#     calc
#     render
#   end

#   # set default values on each tick
#   def defaults
#     game.walls ||= []
#     game.wall_countdown ||= 100
#   end

#   # generate game objects
#   def calc
#     calc_walls
#   end

#   def calc_walls
#     # decrement countdown
#     game.wall_countdown -= 1

#     # move the walls left each frame
#     game.walls.each { |w| w.move }
    
#     # remove the walls if they leave the screen
#     game.walls.reject! { |w| w.x < -w.width }

#     # generate a new wall each 100 frames
#     if game.wall_countdown == 0
#       # reset the countdown
#       game.wall_countdown = 100
#       # create a new game object
#       wall = game.new_entity(:wall) do |w|
#         w.x = grid.right
#         w.y = grid.bottom + 60
#         w.width = 40
#         w.height = 80
#       end
      
#       game.walls << wall
#     end

#   end

#   # draw things
#   def render
#     render_background
#     render_floor
#     render_walls
#   end

#   def render_background
#     outputs.solids << grid.rect # grid.rect == [grid.left, grid.top, grid.bottom, grid.right]
#   end

#   def render_floor
#     outputs.solids << [grid.left, grid.bottom, grid.right, 60, 255, 0, 0, 255]
#   end

#   def render_walls
#     game.walls.each do |wall| 
#       outputs.solids << [wall.x, wall.y, wall.width, wall.height, 255, 0, 0, 255]
#     end
#   end

# end