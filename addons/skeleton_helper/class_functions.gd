extends Node
class_name SkeletonHelper

static func get_proximity():
	return 0.1

static func _set_positions(scene):
	var skeleton = scene.get_node('Skeleton')
	var bone_node = scene.get_node('bones')
	var body_mesh = scene.get_node('bodyMesh')
	var skin = body_mesh.skin
	skin.set_bind_count(0)
	add_bones(scene, bone_node, body_mesh, skeleton, -1, Transform.IDENTITY)
	
	skeleton.hide()
	skeleton.show()
	print(skin.get_bind_count(), "  bindings adjusted for mesh")



static func add_bones(scene, node, body_mesh, skeleton, parentIndex, parentTransform):
	var skin = body_mesh.skin
	var bone_attachments = node.get_tree().get_nodes_in_group("BoneAttachments")

	for child in bone_attachments:
		if child is BoneAttachment:
			child.add_to_group('BoneAttachments')
			var bone_name = child.get_name()
			var parent_name = child.get_parent().get_name()
			var transform = child.global_transform  # Use global transform of the bone attachment

			scene.transforms.append(transform)

			# FIND THE BONES IN THE SKELETON AND UPDATE THEIR RESTS AND POSES
			var bone_exists = false
			var existing_bind_index = -1
			var bind_count = skin.get_bind_count()

			# Check if the bone name already exists in the bindings
			for j in range(bind_count):
				if skin.get_bind_name(j) == bone_name:
					bone_exists = true
					existing_bind_index = j
					break

			# If bone exists, update the existing binding
			var inv_transform = transform.affine_inverse()
			if bone_exists:
				skin.set_bind_pose(existing_bind_index, inv_transform)  # Update existing binding's pose
			else:
				# Add a new binding
				skin.set_bind_count(bind_count + 1)
				skin.set_bind_name(bind_count, bone_name)
				skin.set_bind_pose(bind_count, inv_transform)
				skin.set_bind_bone(bind_count, bind_count)

			# Iterate over the skeleton bones
			for bone_index in range(skeleton.get_bone_count()):
				skeleton.set_bone_rest(skeleton.find_bone(bone_name), child.transform)



static func _clear_skeleton(scene):
	var skeleton = scene.get_node('Skeleton').clear_bones()


static func _attach_mesh(scene):
	var skeleton = scene.get_node('Skeleton')
	var mesh = scene.get_node('bodyMesh')
	mesh.skeleton = ''
	if mesh.skeleton != skeleton.get_path():
		mesh.skeleton = skeleton.get_path()
	else:
		print("SKELETON MESH ALREADY SET!")
	
	
	
	
static func _assign_bones_weights(scene):
	var skeleton = scene.get_node('Skeleton')
	var bone_count = skeleton.get_bone_count()
	var verts = PoolVector3Array()
	var uvs = PoolVector2Array()
	var normals = PoolVector3Array()
	var indices = PoolIntArray()
	var newBones = PoolIntArray()
	var newWeights = PoolRealArray()
	var arraymesh = scene.get_node('bodyMesh')
	var mesh = arraymesh.mesh
	var array_mesh = ArrayMesh.new()
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	# Check if mesh exists and has surfaces
	if mesh and mesh.surface_get_array_len(0) > 0:
		# Get mesh surface arrays
		var data = mesh.surface_get_arrays(0)
		verts = data[ArrayMesh.ARRAY_VERTEX]
		uvs = data[ArrayMesh.ARRAY_TEX_UV]
		normals = data[ArrayMesh.ARRAY_NORMAL]
		indices = data[ArrayMesh.ARRAY_INDEX]

		# Gather rest positions for each bone in the skeleton
		var rest_positions = []

		for bone_index in range(bone_count):
			var rest_position = skeleton.get_bone_rest(bone_index).origin
			rest_positions.append(rest_position)
			
			
		# Assign weights for each vertex and bone
		for vertex_index in range(verts.size()):
			# Calculate distances between the vertex and each bone's rest position
			var bone_weights = []  # List to store bone weights for this vertex

			for bone_index in range(bone_count):
				# Retrieve BoneAttachment by name
				var bone_name = skeleton.get_bone_name(bone_index)  # Assuming bone names are the same as BoneAttachment names
				var bone_attachment = scene.find_node(bone_name)  # Find the BoneAttachment by name
				
				if bone_attachment and bone_attachment is BoneAttachment:
					var bone_transform = bone_attachment.global_transform
					var distance = verts[vertex_index].distance_to(bone_transform.origin)

					# Define the radius of influence for the bone (adjust as needed)
					var influence_radius = 1.0  # Example radius

					# Calculate weight based on spherical falloff
					var weight = clamp(1.0 - (distance / influence_radius), 0.0, 1.0)
					bone_weights.append(weight)
				else:
					bone_weights.append(0.0)  # No attachment found, assign zero weight

			# Normalize bone weights so that they sum up to 1.0
			var total_weight = 0.0
			for i in range(len(bone_weights)):
				total_weight += bone_weights[i]

			if total_weight != 0.0:
				for i in range(len(bone_weights)):
					bone_weights[i] /= total_weight

			# Assign bone indices and weights to the vertex based on calculated distances
			for i in range(4):  # Assuming up to four bones influencing the vertex
				if i < len(bone_weights):
					newWeights.append(bone_weights[i])
					newBones.append(i)
				else:
					newWeights.append(0.0)
					newBones.append(0)

		# Assign arrays to mesh array.
		surface_array[Mesh.ARRAY_VERTEX] = verts
		surface_array[Mesh.ARRAY_TEX_UV] = uvs
		surface_array[Mesh.ARRAY_NORMAL] = normals
		surface_array[Mesh.ARRAY_INDEX] = indices
		surface_array[Mesh.ARRAY_BONES] = newBones
		surface_array[Mesh.ARRAY_WEIGHTS] = newWeights

		# Add the updated surface to the ArrayMesh
		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

		# Assign the updated ArrayMesh to the MeshInstance
		arraymesh.mesh = array_mesh
	else:
		print("Mesh or surface arrays not found or empty.")









static func _add_bone(scene, label, text, acceptBone, title):
	if !title.visible:
		title.show()
	else:
		title.hide()


static func _add_IK(scene, label, text, acceptIK, title):
	if !title.visible:
		title.show()
	else:
		title.hide()
