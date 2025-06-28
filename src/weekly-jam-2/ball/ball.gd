class_name Ball
extends RigidBody2D

const COLLISION_FORCE:float = 400.0
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
	if is_colliding:
		var contact_count = state.get_contact_count()
		if contact_count == 0: return
		
		var contact_normal = state.get_contact_local_normal(0)
		var contact_velocity = state.get_contact_local_velocity_at_position(0)
		
		if contact_velocity.y < 0: return
		
		var contact_force:float = min(COLLISION_FORCE, contact_velocity.length() * 20.0)
		var clamped_velocity = Vector2(
				clamp(-contact_normal.x * 100.0, -COLLISION_FORCE, COLLISION_FORCE),
				max(contact_velocity.y * -80.0, -COLLISION_FORCE))
		
		state.apply_central_impulse(clamped_velocity * 2.0)
		var collider:Node2D = state.get_contact_collider_object(0)


func _on_area_2d_body_exited(body):
	pass


func _on_exit_area_body_exited(body):
	contact_point_previous = Vector2.ZERO
	is_colliding = false
