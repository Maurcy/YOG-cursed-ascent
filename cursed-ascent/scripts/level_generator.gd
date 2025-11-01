# class_name lets it be accessible globally in case I want to delete the level_generator node
# not sure what the best practice is rn, kind of just experimenting here
class_name LevelGenerator

# the room types
const spawn_room = 0
const normal_room = 1
const hard_room = 2
const dangerous_room = 3
const treasure_room = 4
const exit_room = 5

static func generate_level(height: int, width: int):
	var grid := []
	
	var rooms = [spawn_room, normal_room, hard_room, dangerous_room, treasure_room]
	
	for y in range(height):
		grid.append([null, null, null])	
		
		# if the y == 0, then  it won't spawn dangerous rooms (room = 3)
		var max_room = 3
		if y == 0:
			max_room = 2

		for x in range(width):
			var room = randi_range(1, max_room)
			
			# checks for spawn room coordinates, needs to be changed if we want level width to be adjustable
			if y == 0 and x == 1 :
				room = 0	
			grid[y][x] = rooms[room]

		
		# checks if there aren't any normal rooms in row
		# needs to be expanded so it doesnt overwrite spawn room
		if normal_room not in grid[y]:
			var x = randi_range(0, 2)
			
			# check to prevent the spawn room from being overwritten, needs to be changed if we want level width to be adjustable
			if y == 0 and x == 1:
				var overwrites_left = randi_range(0, 1)
				if overwrites_left == 1:
					x = 0;
				else:
					x = 2;
					
			grid[y][x] = normal_room
			
	# treasure check
	# treasure can't spawn on the start of the level
			if (y != 0):
				# if room below are dangerous or hard
				if grid[y-1][x] == dangerous_room or grid[y-1][x] == hard_room:
					# checks if it's in the left or right row, needs to be changed if we want level width to be adjustable
					# the way it's currently implemented, has slight bias for the right side to spawn treasure
					if (x == 1):
						if grid[y][x-1] == dangerous_room or grid[y][x-1] == hard_room:
							if grid[y][x+1] == dangerous_room or grid[y][x+1] == hard_room:
								grid[y][x] = treasure_room
					if (x == 2):
						if grid[y][x-1] == dangerous_room or grid[y][x-1] == hard_room:
							grid[y][x-1] = treasure_room
					if (x == 0):
						if grid[y][x+1] == dangerous_room or grid[y][x+1] == hard_room:
							grid[y][x] = treasure_room
	
	return grid
