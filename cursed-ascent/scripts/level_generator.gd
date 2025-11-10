# class_name lets it be accessible globally in case I want to delete the level_generator node
# not sure what the best practice is rn, kind of just experimenting here
class_name LevelGenerator

# the room types
const spawn_room = 0
const normal_room = 1
const hard_room = 2
const dangerous_room = 3
const exit_room = 4

static func generate_level(height: int, width: int):
	var grid := []
	
	var rooms = [spawn_room, normal_room, hard_room, dangerous_room]
	
	for y in range(height):
		grid.append([null, null, null])	

		for x in range(width):
			var room = 1
			# guarentees first row are safe rooms
			if (y != 0):
				room = randi_range(1, 3)
				
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
	
	return grid
