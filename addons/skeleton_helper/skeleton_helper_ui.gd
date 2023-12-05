tool
extends Control
	
func _on_update_mesh_pressed():
	if get_tree().edited_scene_root.get_name() == 'characterTemplate':
		var scene = get_tree().edited_scene_root
		var bodymesh = scene.get_node('bodyMesh')
		
		
		# Clear and populate Bone_array
		$buttons/Bone_array.clear()
		
		
		for bone in scene.bone_array:
			$buttons/Bone_array.add_item(bone)
		
		# Check for duplicate bone names in bone_array
		var unique_bones = {}
		var has_duplicates = false
		for b in scene.bone_array:
			if unique_bones.has(b):
				print("Duplicate bone name found:", b)
				has_duplicates = true
			else:
				unique_bones[b] = true
		
		# Add 'bones' node if it doesn't exist
		if scene.get_node_or_null('bones') == null:
			var bones = Spatial.new()
			scene.add_child(bones)
			bones.set_name('bones')
			bones.set_owner(get_tree().edited_scene_root)
		
		# Ensure bodymesh has a skin
		if bodymesh.skin == null:
			bodymesh.skin = Skin.new()
			bodymesh.skin.set_bind_count(0)
			bodymesh.skeleton = ""

		# Reference 'bones' node
		var bones_node = scene.get_node('bones')
		
		# Add bones to the 'bones' node if it has no children
		if bones_node.get_child_count() <= 0:
			for b in scene.bone_array.size():
				var bone = BoneAttachment.new()
				bones_node.add_child(bone)
				bone.set_name(scene.bone_array[b])
				bone.set_owner(get_tree().edited_scene_root)
				bone.bone_name = bone.get_name()
				bone.add_to_group('BoneAttachments')
				var coll = CollisionShape.new()
				coll.shape = SphereShape.new()
				bone.add_child(coll)
				coll.shape.radius = SkeletonHelper.get_proximity()
				coll.set_owner(get_tree().edited_scene_root)
				scene.boneIndices.append(b)
				scene.weights.append(1.0)


		var children_names_indices = {}

		var queue = []  # Using a queue for breadth-first traversal
		var current_number = -1

		# Add bones_node to the queue and assign it a number
		queue.append(bones_node)
		children_names_indices[bones_node.get_name()] = current_number

		while queue.size() > 0:
			var current_node = queue.pop_front()
			var children_array = current_node.get_children()

			for i in range(children_array.size()):
				var child = children_array[i]
				if child is BoneAttachment:
					queue.append(child)
					current_number += 1
					children_names_indices[child.get_name()] = current_number
		
		var sk_bones = []
		# Print the node names and their assigned numbers
		for node_name in children_names_indices.keys():
			var node_number = children_names_indices[node_name]
			if node_name != 'bones':
				sk_bones.append([node_name, node_number])
				







		# Add the Skeleton node if it doesn't exist
		if !scene.has_node('Skeleton'):
			var s = Skeleton.new()
			s.name = "Skeleton"
			scene.add_child(s)
			s.set_owner(get_tree().edited_scene_root)
		
		# Reference and add bones to the Skeleton node
		var skeleton_node = scene.get_node_or_null('Skeleton')
		
		if skeleton_node != null:
			print(sk_bones)

			# Loop through sk_bones to add bones to the skeleton_node
			for b in range(sk_bones.size()):
				var bone_name = sk_bones[b][0]
				var bone_parent = sk_bones[b][1]

				if bone_name != 'bones':
					skeleton_node.add_bone(bone_name)
				else:
					print('Make sure none of your bones are named "bones" as that is the parent node.')
					
					
					
			# Loop through BoneAttachments to set parent bones for skeleton_node
			for b2 in get_tree().get_nodes_in_group('BoneAttachments'):
				if b2 is BoneAttachment:
					for i in range(sk_bones.size()):
						var parent_node = b2.get_parent()
						if sk_bones[i][0] == parent_node.get_name():
							var bone = skeleton_node.find_bone(b2.get_name())
							print("Set ", bone, ": which is: ", b2.get_name(), " - parent to number: ", sk_bones[i][1])
							skeleton_node.set_bone_parent(bone, sk_bones[i][1])

	else:
		print("SCENE NEEDS TO BE THE CHARACTER TEMPLATE SCENE IN THE HIERARCHY!")






func _on_set_bone_pos_pressed():
	if get_tree().edited_scene_root.get_name() == 'characterTemplate':
		var scene = get_tree().edited_scene_root
		SkeletonHelper._set_positions(scene)
	else:
		print("SCENE NEEDS TO BE THE CHARACTER TEMPLATE SCENE IN THE HEIRARCHY!")



func _on_attach_mesh_pressed():
	if get_tree().edited_scene_root.get_name() == 'characterTemplate':
		var scene = get_tree().edited_scene_root
		SkeletonHelper._attach_mesh(scene)
	else:
		print("SCENE NEEDS TO BE THE CHARACTER TEMPLATE SCENE IN THE HEIRARCHY!")



func _on_assign_mesh_data_pressed():
	if get_tree().edited_scene_root.get_name() == 'characterTemplate':
		var scene = get_tree().edited_scene_root
		SkeletonHelper._assign_bones_weights(scene)
	else:
		print("SCENE NEEDS TO BE THE CHARACTER TEMPLATE SCENE IN THE HEIRARCHY!")


func _on_create_bone_pressed():
	if get_tree().edited_scene_root.get_name() == 'characterTemplate':
		var scene = get_tree().edited_scene_root
		var title = get_node('panels/createBoneTtl')
		var label = get_node("panels/createBoneTtl/createBoneLbl")
		var text = get_node("panels/createBoneTtl/createBoneTxt")
		var acceptBtn = get_node("panels/createBoneTtl/createBoneAccptBtn")
		SkeletonHelper._add_bone(scene, label, text, acceptBtn, title)
	else:
		print("SCENE NEEDS TO BE THE CHARACTER TEMPLATE SCENE IN THE HEIRARCHY!")


func _on_acceptBtnBone_button_up():
	if get_tree().edited_scene_root.get_name() == 'characterTemplate':
		var scene = get_tree().edited_scene_root
		var label = get_node("panels/createBoneTtl/createBoneLbl")
		var text = get_node("panels/createBoneTtl/createBoneTxt")
		var acceptBtn = get_node("panels/createBoneTtl/createBoneAccptBtn")
		var newbone = BoneAttachment.new()
		var bones_node = scene.get_node('bones')
		scene.bone_array.append(text.text)
		newbone.set_name(text.text)
		if scene.get_node_or_null('bones') != null:
			bones_node.add_child(newbone)
			newbone.set_owner(get_tree().edited_scene_root)
			newbone.bone_name = newbone.get_name()
			newbone.add_to_group('BoneAttachments')
			var coll = CollisionShape.new()
			coll.shape = SphereShape.new()
			newbone.add_child(coll)
			coll.shape.radius = SkeletonHelper.get_proximity()
			coll.set_owner(get_tree().edited_scene_root)
			scene.boneIndices.append(newbone.get_index())
			scene.weights.append(1.0)
			newbone.add_to_group('BoneAttachments')
		label.hide()
		text.text = ''
		text.hide()
		acceptBtn.hide()
	else:
		print("SCENE NEEDS TO BE THE CHARACTER TEMPLATE SCENE IN THE HEIRARCHY!")

var selected_bone = null

func _on_remove_bone_in_array_button_up():
	var scene = get_tree().edited_scene_root
	if selected_bone != null:
		for b in range(scene.bone_array.size()):
			if b == selected_bone:
				var node = find_bone_in_children(scene.get_node('bones'), scene.bone_array[b])
				if scene.get_node('Skeleton').find_bone(scene.bone_array[b]):
					print('found in skeleton')
					scene.get_node('Skeleton').unparent_bone_and_rest(b)
				else:
					print('not found in skeleton')
				if node != null:
					print('Delete: ', node)
					scene.find_node(scene.bone_array[b]).queue_free()
				else:
					print('Node not found')
				scene.bone_array.remove(b)
				
				
func find_bone_in_children(node, node_to_find):
	# Loop through each child node
	for i in range(node.get_child_count()):
		var child_node = node.get_child(i)
		# Recursively call the function for each child node
		var found_node = find_bone_in_children(child_node, node_to_find)
		if found_node != null:
			return found_node

		if child_node.name == node_to_find:
			return child_node

	return null  # Return null if node is not found


func collect_nodes(node, node_list):
	# Add the current node to the list
	node_list.append(node)

	# Recursively process each child node
	for child in node.get_children():
		collect_nodes(child, node_list)

# Create a function to retrieve all nodes
func get_all_nodes(root_node):
	var all_nodes = []
	collect_nodes(root_node, all_nodes)
	return all_nodes




func _on_Bone_array_item_selected(index):
	selected_bone = index
	print(selected_bone, "  is the index of bones you are about to remove")


func _on_clear_skeleton_pressed():
	if get_tree().edited_scene_root.get_name() == 'characterTemplate':
		var scene = get_tree().edited_scene_root
		SkeletonHelper._clear_skeleton(scene)
	else:
		print("SCENE NEEDS TO BE THE CHARACTER TEMPLATE SCENE IN THE HEIRARCHY!")


func _on_add_to_group_pressed():
	var scene = get_tree().edited_scene_root
	var nodes = get_all_nodes(scene.get_node('bones'))
	for node in nodes:
		node.add_to_group("BoneAttachments")


func _on_create_IK_pressed():
	if get_tree().edited_scene_root.get_name() == 'characterTemplate':
		var scene = get_tree().edited_scene_root
		var title = get_node('panels/createIKTtl')
		var label = get_node("panels/createIKTtl/createIKLbl")
		var text = get_node("panels/createIKTtl/createIKTxt")
		var acceptBtn = get_node("panels/createIKTtl/createIKAccptBtn")
		SkeletonHelper._add_IK(scene, label, text, acceptBtn, title)
	else:
		print("SCENE NEEDS TO BE THE CHARACTER TEMPLATE SCENE IN THE HEIRARCHY!")


func _on_acceptBtnIK_button_up():
	if get_tree().edited_scene_root.get_name() == 'characterTemplate':
		var scene = get_tree().edited_scene_root
		var label = get_node("panels/createIKTtl/createIKLbl")
		var text = get_node("panels/createIKTtl/createIKTxt")
		var acceptBtn = get_node("panels/createIKTtl/createIKAccptBtn")
		var newik = SkeletonIK.new()
		var skeleton_node = scene.get_node('Skeleton')
		newik.set_name(text.text)
		if scene.get_node_or_null('bones') != null:
			skeleton_node.add_child(newik)
			newik.set_owner(get_tree().edited_scene_root)
		label.hide()
		text.text = ''
		text.hide()
		acceptBtn.hide()
	else:
		print("SCENE NEEDS TO BE THE CHARACTER TEMPLATE SCENE IN THE HEIRARCHY!")
