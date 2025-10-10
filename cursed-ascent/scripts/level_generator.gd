# class_name lets it be accessible globally in case I want to delete the level_generator node
# not sure what the best practice is rn, kind of just experimenting here
class_name LevelGenerator

# the room types
const spawn_room = 0
const normal_room = 1
const hard_room = 2
const dangerous_room = 3
const treasure_room = 4

static func generate_level(height: int):
	var grid := []
	
	var rooms = [spawn_room, normal_room, hard_room, dangerous_room]
	
	for y in range(height):
		grid.append([null, null, null])	
		
		# if the y == 0, then  it won't spawn dangerous rooms
		var max_room = 3
		if y == 0:
			max_room = 2

		for x in range(3):
			var room = randi_range(1, max_room)
			# checks for spawn room coordinates
			
			if y == 0 and x == 1 :
				room = 0	
			grid[y][x] = rooms[room]

		
		# checks if there aren't any normal rooms in row
		# needs to be expanded so it doesnt overwrite spawn room
		if normal_room not in grid[y]:
			var x = randi_range(0, 2)
			
			# check to prevent the spawn room from being overwritten
			if y == 0 and x == 1:
				var overwrites_left = randi_range(0, 1)
				if overwrites_left == 1:
					x = 0;
				else:
					x = 2;
					
			grid[y][x] = normal_room
			
	# treasure check still needs to be implemented
	
	return grid
