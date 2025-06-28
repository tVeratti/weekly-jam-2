class_name Ball
extends RigidBody2D

const COLLISION_FORCE:float = 200.0
const HIGH_SPEED_VELOCITY:float = 300.0

var is_colliding:bool = false


var contact_velocity:Vector2 = Vector2.ZERO
var contact_point_previous:Vector2 = Vector2.ZERO


@onready var trail_line:TrailLine = %TrailLine
@onready var speed_trail:GPUParticles2D = %SpeedTrail


func _physics_process(_delta):
	var speed_length: = linear_velocity.length()
	var is_high_speed:bool = speed_length > HIGH_SPEED_VELOCITY
	
	speed_trail.emitting = is_high_speed
	if is_high_speed:
		var trail_material:ParticleProcessMaterial = speed_trail.process_material
		trail_material.direction = Vector3(linear_velocity.x, linear_velocity.y, 0)
	
	trail_line.is_active = is_high_speed


func _on_area_2d_body_entered(_body):
	# If the body is overlapping with the floor, that means its shape has
	# change in such a way that it should apply a strong force in that direction.
	is_colliding = true


func _integrate_forces(state):
	if linear_velocity.y > 0:
		apply_force(linear_velocity * 0.2)
	
	if is_colliding:
		var contact_centroid: = Vector2.ZERO
		var contact_normal_centroid: = Vector2.ZERO
		var contact_count = state.get_contact_count()
		
		if contact_count == 0: return
		
		for i in range(contact_count):
			var contact_point = state.get_contact_local_position(i)
			var contact_normal = state.get_contact_local_normal(i)
			contact_centroid += contact_point
			contact_normal_centroid += contact_normal
		
		contact_centroid /= contact_count
		contact_normal_centroid /= contact_count
		
		contact_velocity = contact_point_previous - contact_centroid
		contact_point_previous = contact_centroid
		
		var impulse_velocity: = contact_velocity
		var clamped_velocity = Vector2(
			clamp(contact_normal_centroid.x * 120, -COLLISION_FORCE, COLLISION_FORCE),
			clamp(impulse_velocity.y * -110, -COLLISION_FORCE, COLLISION_FORCE))
		
		state.apply_central_impulse(clamped_velocity)
		
		#var collider:Node2D = state.get_contact_collider_object(0)
			#var normal:Vector2 = state.get_contact_local_normal(i)
			#var clamped_velocity = clamp(normal * COLLISION_FORCE, Vector2(-COLLISION_FORCE, -COLLISION_FORCE), Vector2(COLLISION_FORCE, COLLISION_FORCE))
			#apply_central_impulse(clamped_velocity)
			#print(collider)


func _on_area_2d_body_exited(_body):
	is_colliding = false
