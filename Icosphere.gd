extends StaticBody

var noise = OpenSimplexNoise.new()

func init_noise():
	noise.seed = randi()
	noise.octaves = 7
	noise.period = 20.0
	noise.persistence = 0.8

#TODO: Optionally create a hexasphere by starting with a vertex and turning all connected triangles into a hex
#TODO: I think the winding direction is wrong and I'm seeing it's insides lol....

func _ready():
	init_noise()
	
	var mesh = generate_mesh_instance()
	
	# Generate collision shape
	var shape = ConcavePolygonShape.new()
	shape.set_faces(mesh.get_faces())
	
	var id = create_shape_owner(self)
	shape_owner_add_shape(id, shape)

func add_surface(st: SurfaceTool, p: Vector3):
	st.add_color(Color(1, 0, 0))
	st.add_uv(Vector2(0, 0))
	st.add_vertex(p)

func generate_mesh_instance():
	var material = SpatialMaterial.new()
	material.albedo_color = Color(0.8, 0.0, 0.0)
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	
	var faces = create()
	
	# done, now add triangles to mesh
	for tri in faces:
		add_surface(st, positions[tri.v1])
		add_surface(st, positions[tri.v2])
		add_surface(st, positions[tri.v3])
	
	st.generate_normals()
	
	var array_mesh = st.commit()
	
	var mesh_inst = MeshInstance.new()
	mesh_inst.mesh = array_mesh
	add_child(mesh_inst)
	
	return array_mesh

func _process(delta):
	rotate_y(delta)
	rotate_x(delta)

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
	faces.push_back(TriangleIndices.new(0, 11, 5))
	faces.push_back(TriangleIndices.new(0, 5, 1))
	faces.push_back(TriangleIndices.new(0, 1, 7))
	faces.push_back(TriangleIndices.new(0, 7, 10))
	faces.push_back(TriangleIndices.new(0, 10, 11))
	
	# 5 adjacent faces 
	faces.push_back(TriangleIndices.new(1, 5, 9))
	faces.push_back(TriangleIndices.new(5, 11, 4))
	faces.push_back(TriangleIndices.new(11, 10, 2))
	faces.push_back(TriangleIndices.new(10, 7, 6))
	faces.push_back(TriangleIndices.new(7, 1, 8))
	
	# 5 faces around point 3
	faces.push_back(TriangleIndices.new(3, 9, 4))
	faces.push_back(TriangleIndices.new(3, 4, 2))
	faces.push_back(TriangleIndices.new(3, 2, 6))
	faces.push_back(TriangleIndices.new(3, 6, 8))
	faces.push_back(TriangleIndices.new(3, 8, 9))
	
	# 5 adjacent faces 
	faces.push_back(TriangleIndices.new(4, 9, 5))
	faces.push_back(TriangleIndices.new(2, 4, 11))
	faces.push_back(TriangleIndices.new(6, 2, 10))
	faces.push_back(TriangleIndices.new(8, 6, 7))
	faces.push_back(TriangleIndices.new(9, 8, 1))
	
	var recursionLevel = 3
	
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
