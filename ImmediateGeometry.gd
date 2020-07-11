extends ImmediateGeometry

var points = Array()

func _process(delta):
	begin(Mesh.PRIMITIVE_LINE_STRIP)
	set_color(Color(1,1,1))
	for p in points:
		add_vertex(p)
	end()
	
	# Clear the array every frame.
	# Anyone who wants to debug draw must explicity draw every frame.
	points.clear()

func drawline(a: Vector3, b: Vector3):
	points.push_back(a)
	points.push_back(b)
