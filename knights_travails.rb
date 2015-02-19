# Code needs to be refactored by making a board class...
# Need some class structure, otherwise this assignment is done.
# perhaps i can refactor knights_move so it has helper functions.

     class Node

    attr_accessor :value, :visited, :parent, :children

    def initialize(args = {})
      @parent = args.fetch(:parent, nil)
      @visited = false
      @children = []
    end

    def to_s
	  str = ""
	  str += "< Node: #{value} "
	  str += parent.nil? ? "parent: Nil " : "parent: #{parent.value} "
      children_str = ""
      children_str += "Children : "
      children.each_with_index do |child, i| 
        child_value = (child.nil?) ? "Nil" : child.value
        children_str << " Child #{i} = #{child_value}\n" 
      end
      children_str += "\n"
	  str += children.empty? ? "No children\n\n" : children_str
	  str
    end

  end # class Node


# this hash models an 8x8 chess board that will store the Nodes which 
# will contain the visited bits. keeping the Nodes in this data structure allows 
# for a fast access and a simple way of creating all the Nodes in one place.
# which makes it convenient for checking if a Node has been visited.
def init_board
  $board = {}
  8.times do |x|
    8.times do |y|
      $board[ [x,y] ] = Node.new
      $board[ [x,y] ].value = [x,y]
    end
  end
  $board
end

# Returns an array of tuples, [x,y], indicating valid moves on the 8x8 board
# for the knidght piece. Previously visited squares are not returned as valid
def valid_moves(position)
# position is a tuple, [x, y]
  x = position[0] # I could make position into a class/struct and add methods x and y
  y = position[1]
  #puts "X = #{x}, Y = #{y}"
  move = []
  move[0] = [x-1, y+2]
  move[1] = [x-2, y+1]
  move[2] = [x-2, y-1]
  move[3] = [x-1, y-2]
  move[4] = [x+1, y-2]
  move[5] = [x+2, y-1]
  move[6] = [x+2, y+1]
  move[7] = [x+1, y+2]
  result = []
  move.each do |pos| 
  	result << pos if ( pos[0].between?(0, 7) && pos[1].between?(0,7) && $board[ [pos[0],pos[1]] ].visited == false) 
  end
  result
end

# each Node in the game board is the potential start of its own tree.
# The algo should receive a starting position and a final position
# and performs a breadth first search while building the tree by
# adding valid next moves as children to previous moves. 
# The algo will ask possible_moves for a list of valid next moves.
# The algo will check if any of the next moves == final_position.
# If so, then found
# otherwise each of these possible_moves will be made children of the current
# node. Each of these children will be put in the next_node queue
# and the same process will continue.

# How to improve on this algorithm.
# Notice that there are at most eight children at each stage. It is reasonable to
# assume that the children which leads in the direction towards the end position
# is a better solution than those in the opposite direction. 
# 1. Assume closest matching derivative is best guess and put first.
# 2. Sort entire list of next moves based on closest match to derivative
# 3. Perhaps children pointing in the 'wrong' direction can be thrown away. Are there
# any situations where going the 'wrong' direction leads to a correct answer.

# Another thing to try would be using the depth first search algorithm in the
# direction of the derivative. This would be the fastest if using the direction is
# the best method. This would ignore children going the wrong direction and place the
# knight immediately closer to the square. This really does not need to be a depth first
# search and more of a search in the direction of the gradient making sure not to visit
# the same node twice.

# Direction can be
# made using a floating point derivative (perhaps integer).
  def knight_moves(start_pos, end_pos, args = {})
  	init_board
    verbose = args.fetch(:verbose, false)
    root = $board[ start_pos ]
    return nil if !root
    found = false
    next_node = [root]
    i = 0
    while !found && !next_node.empty? #<- safer

      current = next_node.shift
      # following check needed in case same node exists multiple times in next_node
      if current.visited == false
        current_pos = current.value
        current.visited = true       
        puts "Current = #{current}" if verbose
        moves_list = valid_moves(current_pos) # should be called valid_moves
        print moves_list if verbose
        puts if verbose
        found = moves_list.include? end_pos
        puts "found = #{found}" if verbose
        if found
          $board[ end_pos ].parent = current
        else
          moves_list.each do |square| 
          	$board[ square ].parent = current
            current.children << $board[ square ]
            next_node.push $board[ square ]
          end
        end
      end

    end # while !found
    return "ERROR: not found" if !found
    result = []
    current = $board[ end_pos ]
    while current != nil
      result.unshift current.value
      current = current.parent
    end
    result    
  end # def build_tree

  
  print knight_moves([0,0],[6,4],:verbose => true)
  puts
  print knight_moves([0,0],[7,7])
  puts  
  print knight_moves([0,0],[1,2])
  puts
  print knight_moves([0,0],[3,3])
  puts
  print knight_moves([3,3],[0,0])
  puts