extends StaticBody

export var planet_scale = 20.0

var noise = OpenSimplexNoise.new()

func init_noise():
	noise.seed = randi()
	noise.octaves = 7
	noise.period = 20.0
	noise.persistence = 0.8


func _on_Emitter_surface_missile_impact(impact_site, blast_radius):
	print("surface impact: ", impact_site, " ", blast_radius)
	
	#print("impact_site ", impact_site, " blast_raduis ", blast_radius)
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh_inst.mesh, 0)
	var magnitude = rand_range(0.1,0.2)*25
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		var dir = vertex.normalized()
		
		var dist = (impact_site - vertex).length()
		var factor = 3
		var normdist = 1 - (dist/(blast_radius*factor))
		if dist < blast_radius*factor:
			vertex -= (dir * normdist * magnitude)
			mdt.set_vertex(i, vertex)
	
	mesh_inst.mesh.surface_remove(0)
	mdt.commit_to_surface(mesh_inst.mesh)
	buildConcavePolygonShape(mesh_inst.mesh)

	
	trigger_impact_ripple(impact_site)

#TODO: Optionally create a hexasphere by starting with a vertex and turning all connected triangles into a hex
#TODO: I think the winding direction is wrong and I'm seeing it's insides lol....

#TODO:
# Method to determine triangle based on point on surface
# Method to remove triangle from mesh and shape
#
#func pointToTriangleIndex(p: Vector3):

class Octree:
	var aabb: AABB
	var center: Vector3
	var half_size: Vector3
	var max_points: int
	var points = []
	var children = []
	
	func _init(center: Vector3, half_size: Vector3, max_points: int):
		self.center = center
		self.half_size = half_size
		aabb = AABB(center-half_size, half_size*2)
		self.max_points = max_points
	
	# Returns true if point was successfully added
	func add(point: Vector3, data):
		if !aabb.has_point(point):
			return
		
		# Do we have children? They hold all our points.
		if children:
			for child in children:
				if child.add(point, data):
					return true
			print("Your point is outside of the octree bounds?!")
			return false
		
		# Is there space left?
		if points.size() < max_points:
			points.push_back([point, data])
			return true
		
		# Dang, we need to subdivide and share the load
		# https://www.youtube.com/watch?v=wlJgD4GuDVs
		
		# Create children
		var child_size = aabb.size / 2
		for x in range(2):
			for y in range(2):
				for z in range(2):
					var child = Octree.new(aabb.position + Vector3(child_size.x*x, child_size.y*y, child_size.z*z), child_size, max_points)
					children.push_back(child)

		# Distribute amongst children -- just call ourself again!
		for this_point in points:
			add(this_point[0], this_point[1])
		points.clear()
		
		return add(point, data)
	
	# Non-recursive!
	func knn(point: Vector3, k: int):
		var voxel = self
		
		while true:
			if voxel.aabb.has_point(point):
				# Search children, if any.
				if voxel.children:
						for child in voxel.children:
							if child.aabb.has_point(point):
								voxel = child
								continue
						break
				
				# No children -- check all the points in this voxel
				var sorter = MyCustomSorter.new(point)
				points.sort_custom(sorter, "sort_ascending")
				return voxel.points.slice(0, k)
		
		return []

class MyCustomSorter:
	var point: Vector3
	func _init(point: Vector3):
		self.point = point
	func sort_ascending(a, b):
		if (a - point).length() < (b - point).length():
			return true
		return false

var octree = Octree.new(Vector3(), Vector3(40,40,40), 256)

var owner_id: int = -1

func buildConcavePolygonShape(mesh):
	var shape = ConcavePolygonShape.new()
	shape.set_faces(mesh.get_faces())
	
	if owner_id == -1:
		owner_id = create_shape_owner(self)
	shape_owner_clear_shapes(owner_id)
	shape_owner_add_shape(owner_id, shape)


func _ready():
	init_noise()
	
	var mesh = generate_mesh_instance()
	
	# Generate collision shape
	buildConcavePolygonShape(mesh)

func add_surface(st: SurfaceTool, p: Vector3):
	st.add_color(Color(1, 0, 0))
	#st.add_color(Color(rand_range(0.5, 1.0), 0, 0))
	st.add_uv(Vector2(0, 0))
	st.add_vertex(p)

var mesh_inst: MeshInstance

func get_bounding_box():
	return mesh_inst.get_aabb()

var material

func generate_mesh_instance():
	#var material = SpatialMaterial.new()
	#material.albedo_color = Color(0.8, 0.0, 0.0)
	material = load("res://ShaderTest.tres")
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	
	var faces = create()
	
	# done, now add triangles to mesh
	for tri in faces:
		add_surface(st, positions[tri.v1])
		add_surface(st, positions[tri.v2])
		add_surface(st, positions[tri.v3])
		
		var center = (positions[tri.v1] + positions[tri.v2] + positions[tri.v3]) / 3
		#octree.add(center, tri)
	
	st.generate_normals()
	
	var array_mesh = st.commit()
	
	mesh_inst = MeshInstance.new()
	mesh_inst.mesh = array_mesh
	add_child(mesh_inst)
	
	return array_mesh

var active_impacts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
func find_free_impact_site():
	var effect_length = 2.0
	var time = float(OS.get_ticks_msec()) / 1000.0
	for i in range(active_impacts.size()):
		var start_time = active_impacts[i]
		if time > start_time + effect_length:
			# It's complete, free slot!
			return i
	return -1

onready var mutex = Mutex.new()
func trigger_impact_ripple(impact_site: Vector3):
	mutex.lock()
	var i = find_free_impact_site()
	if i < 0:
		print("Already at maximum impacts")
		mutex.unlock()
		return
	
	var t = float(OS.get_ticks_msec()) / 1000.0
	material.set_shader_param("site"+str(i), to_local(impact_site))
	material.set_shader_param("start_time_"+str(i), t)
	active_impacts[i] = t
	mutex.unlock()

var time = 0
func _process(delta):
	#rotate_y(delta)
	#rotate_x(delta)
	material.set_shader_param("global_time", time)
	time += delta

class TriangleIndices:
	var v1: int
	var v2: int
	var v3: int
	
	func _init(v1, v2, v3):
		self.v1 = v1
		self.v2 = v2
		self.v3 = v3

var positions = []
var index = 0
var middlePointIndexCache = {}

# add vertex to mesh, fix position to be on unit sphere, return index
func addVertex(p: Vector3):
	
	p = p.normalized()
	var n = noise.get_noise_3d(p.x, p.y, p.z)
	
	var height = (n + 1) / 2
	p *= height
	p *= planet_scale
	positions.push_back(p)
	var i = index
	index += 1
	return i

# return index of point in the middle of p1 and p2
func getMiddlePoint(p1: int, p2: int):
	# first check if we have it already
	var smaller: int = min(p1, p2)
	var greater: int = max(p1, p2)
	var key: int = (smaller << 32) + greater
#	var firstIsSmaller = p1 < p2
#	var smallerIndex: int = p1 if firstIsSmaller else p2
#	var greaterIndex: int = p2 if firstIsSmaller else p1
#	var key: int = (smallerIndex << 32) + greaterIndex

	if middlePointIndexCache.has(key):
		return middlePointIndexCache[key]

	# not in cache, calculate it
	var point1 = positions[p1]
	var point2 = positions[p2]
	var middle = (point1 + point2) * 0.5

	# add vertex makes sure point is on unit sphere
	var i = addVertex(middle)

	# store it, return index
	middlePointIndexCache[key] = i
	return i

# Translated from C# to GDScript using this resource:
#   http://blog.andreaskahler.com/2009/06/creating-icosphere-mesh-in-code.html
func create():
	var t = (1.0 + sqrt(5.0)) / 2.0
	
	# create 12 vertices of a icosahedron
	addVertex(Vector3(-1,  t,  0))
	addVertex(Vector3( 1,  t,  0))
	addVertex(Vector3(-1, -t,  0))
	addVertex(Vector3( 1, -t,  0))
	
	addVertex(Vector3( 0, -1,  t))
	addVertex(Vector3( 0,  1,  t))
	addVertex(Vector3( 0, -1, -t))
	addVertex(Vector3( 0,  1, -t))
	
	addVertex(Vector3( t,  0, -1))
	addVertex(Vector3( t,  0,  1))
	addVertex(Vector3(-t,  0, -1))
	addVertex(Vector3(-t,  0,  1))
	
	# create 20 triangles of the icosahedron
	var faces = []
	
	# 5 faces around point 0
	faces.push_back(TriangleIndices.new(0, 5, 11))
	faces.push_back(TriangleIndices.new(0, 1, 5))
	faces.push_back(TriangleIndices.new(0, 7, 1))
	faces.push_back(TriangleIndices.new(0, 10, 7))
	faces.push_back(TriangleIndices.new(0, 11, 10))
	
	# 5 adjacent faces
	faces.push_back(TriangleIndices.new(1, 9, 5))
	faces.push_back(TriangleIndices.new(5, 4, 11))
	faces.push_back(TriangleIndices.new(11, 2, 10))
	faces.push_back(TriangleIndices.new(10, 6, 7))
	faces.push_back(TriangleIndices.new(7, 8, 1))
	
	# 5 faces around point 3
	faces.push_back(TriangleIndices.new(3, 4, 9))
	faces.push_back(TriangleIndices.new(3, 2, 4))
	faces.push_back(TriangleIndices.new(3, 6, 2))
	faces.push_back(TriangleIndices.new(3, 8, 6))
	faces.push_back(TriangleIndices.new(3, 9, 8))
	
	# 5 adjacent faces 
	faces.push_back(TriangleIndices.new(4, 5, 9))
	faces.push_back(TriangleIndices.new(2, 11, 4))
	faces.push_back(TriangleIndices.new(6, 10, 2))
	faces.push_back(TriangleIndices.new(8, 7, 6))
	faces.push_back(TriangleIndices.new(9, 1, 8))
	
	var recursionLevel = 4
	
	# refine triangles
	
	for i in recursionLevel:
		var faces2 = []
		
		for tri in faces:
			# replace triangle by 4 triangles
			var a = getMiddlePoint(tri.v1, tri.v2)
			var b = getMiddlePoint(tri.v2, tri.v3)
			var c = getMiddlePoint(tri.v3, tri.v1)
			
			faces2.push_back(TriangleIndices.new(tri.v1, a, c))
			faces2.push_back(TriangleIndices.new(tri.v2, b, a))
			faces2.push_back(TriangleIndices.new(tri.v3, c, b))
			faces2.push_back(TriangleIndices.new(a, b, c))
		
		faces = faces2
	
	return faces
