extends Spatial


#func sample_parabola(start: Vector3, end: Vector3, height: float, t: float):
#	var parabolicT = t * 2 - 1
#
#	# start and end are not level, gets more complicated
#	var travelDirection = end - start
#	var levelDirection = end - Vector3( start.x, end.y, start.z )
#	var right = travelDirection.cross(levelDirection)
#	var up = right.cross(travelDirection)
#	if end.y > start.y:
#		up = -up;
#	var result = start + t * travelDirection
#	result += ( ( -parabolicT * parabolicT + 1 ) * height ) * up.normalized()
#	return result

func sample_parabola(start: Vector3, end: Vector3, height: float, t: float):
		var mid = start.linear_interpolate(end, t)
		var ft = -4 * height * t * t + 4 * height * t;
		return Vector3(mid.x, ft + lerp(start.y, end.y, t), mid.z)

func sample_parabola_3d(start: Vector3, end: Vector3, height: float, t: float, up: Vector3):
	var point = sample_parabola(start, end, height, t)
	
	var rotation_axis = (end - start).normalized()
	var rotation_point = start.linear_interpolate(end, t)
	
	var height_ray = point - rotation_point
	
	var angle = Vector3.UP.angle_to(up)
	
	point = height_ray.rotated(rotation_axis, angle)
	
	return point

var start = Vector3.ZERO
var end = start + (Vector3.RIGHT * 3) + (Vector3.UP * 3)

var t = 0.0

func _process(delta):
	t += delta
	if t > 1.0:
		t = 1.0
	
	#var pos = sample_parabola_3d(start, end, 3.0, t, Vector3(0,1,-1))
	var pos = sample_parabola(start, end, 3.0, t)
	$MeshInstance.translation = pos

# Vector3 SampleParabola ( Vector3 start, Vector3 end, float height, float t ) {
#        float parabolicT = t * 2 - 1;
#        if ( Mathf.Abs( start.y - end.y ) < 0.1f ) {
#            //start and end are roughly level, pretend they are - simpler solution with less steps
#            Vector3 travelDirection = end - start;
#            Vector3 result = start + t * travelDirection;
#            result.y += ( -parabolicT * parabolicT + 1 ) * height;
#            return result;
#        } else {
#            //start and end are not level, gets more complicated
#            Vector3 travelDirection = end - start;
#            Vector3 levelDirecteion = end - new Vector3( start.x, end.y, start.z );
#            Vector3 right = Vector3.Cross( travelDirection, levelDirecteion );
#            Vector3 up = Vector3.Cross( right, travelDirection );
#            if ( end.y > start.y ) up = -up;
#            Vector3 result = start + t * travelDirection;
#            result += ( ( -parabolicT * parabolicT + 1 ) * height ) * up.normalized;
#            return result;
#        }
#    }
