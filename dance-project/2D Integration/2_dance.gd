extends Node2D

var fileNum: int = 0#180
var decimal: int = 0
var fileNumRight: int = 0#100
var decimalRight: int = 0
const strLength: int = 11
var parseStr : String = "00000000000"
var outOfFiles : bool = false
var waitTime : float = 0.033

@export var strictness : float = 1.0

@export var processTrack : float = 0
@export var totalDuration : float = 72
@export var accuracyScore : float = 0.0

#0: fail, 1: pass, 2: test
var strcase = 1

#Hip, Chest, Head, LArm, LHand, RArm, RHand, LLeg, LCalf, LFoot, RLeg, RCalf, RFoot
#Body 0, Tummy 1, Neck 2, LShoulder 3, LElbow 4, RShoulder 5, RElbow 6, LHip 7, LKnee 8, LCalf 9, RHip 10, RKnee 11, RCalf 12 
var rotationTrack : PackedFloat32Array = [0,0,0,0,0,0,0,0,0,0,0,0,0]
var rotationTrackRight : PackedFloat32Array = [0,0,0,0,0,0,0,0,0,0,0,0,0]

const invalidPos: int = 20

const headBase: int = 48

const torsoBase: int = 48
const torsoLength: int = 96
const larmBase: int = 24
const larmLength: int = 84#42
#const lhandBase: int = 24
#const lhandLength: int = 42
const rarmBase: int = 24
const rarmLength: int = 84#42
#const rhandBase: int = 24
#const rhandLength: int = 42
const llegBase: int = 24
const llegLength: int = 84#36
#const lcalfBase: int = 24
#const lcalfLength: int = 36
#const lfootBase: int = 24
#const lfootLength: int = 12
const rlegBase: int = 24
const rlegLength: int = 84#36
#const rcalfBase: int = 24
#const rcalfLength: int = 36
#const rfootBase: int = 24
#const rfootLength: int = 12

var headBaseMult : float = 1
var torsoBaseMult : float = 1
var torsoLengthMult: float = 1
var larmBaseMult: float = 1
var larmLengthMult: float = 1
#var lhandBaseMult: float = 1
#var lhandLengthMult: float = 1
var rarmBaseMult: float = 1
var rarmLengthMult: float = 1
#var rhandBaseMult: float = 1
#var rhandLengthMult: float = 1
var llegBaseMult: float = 1
var llegLengthMult: float = 1
#var lcalfBaseMult: float = 1
#var lcalfLengthMult: float = 1
#var lfootBaseMult: float = 1
#var lfootLengthMult: float = 1
var rlegBaseMult: float = 1
var rlegLengthMult: float = 1
#var rcalfBaseMult: float = 1
#var rcalfLengthMult: float = 1
#var rfootBaseMult: float = 1
#var rfootLengthMult: float = 1

var avgSizeMult: float = 1

var LArmAngle: float = 1
var RArmAngle: float = 1
var LLegAngle: float = 1
var RLegAngle: float = 1
# Called when the node enters the scene tree for the first time.

var tempImage : Image
var tempImage2 : Image


func _ready() -> void:
	"""
	var jpgName : String = "../OPimages/" + parseStr.substr(0, strLength - decimal) + str(fileNum) + "_rendered.jpg"
	if FileAccess.file_exists(jpgName):
		tempImage = Image.load_from_file(jpgName)
		print(tempImage)
		$Sprite2D.texture
	else:	
		print("Error opening file: ", jpgName)
	return
	"""
	tempImage = Image.load_from_file("res://icon.svg")
	tempImage2 = Image.load_from_file("res://icon.svg")
	#NOTprocess()

func _process(delta) -> void:
	if processTrack < totalDuration:
		if NOTprocess():
			processTrack += delta
			_calculateMoveAccuracy(delta)
		#_calculateBasicMoveAccuracy(delta)

func NOTprocess() -> bool:
	
	if not outOfFiles and fileNum < 4000:
		#var temp0 = load_from_file("../HH3_json/", "HH3_")
		#var temp00 = load_from_file("../GoodHH1_json/", "GoodHH1_", fileNumRight, decimalRight)
		#var temp00 = load_from_file("../BadHH3_json/", "BadHH3_", fileNumRight, decimalRight)
		
		var temp0 = load_from_file("../Demo3_json/", "Yoga3_")
		#var temp00 = load_from_file("../Good1_json/", "GoodYoga1_", fileNumRight, decimalRight)
		var temp00 = load_from_file("../Bad3_json/", "BadYoga3_", fileNumRight, decimalRight)
		if temp0 and temp00:
			#$Sprite2D.texture = loadImage("../Demo3_images/", "Yoga3_")
			#$Sprite2D2.texture = loadImage("../Bad3_images/", "BadYoga3_", fileNumRight, decimalRight)
			#$Sprite2D2.texture = loadImage("../Good1_images/", "GoodYoga1_", fileNumRight, decimalRight)
			#$Sprite2D2.texture = loadImage("../Demo1_images/", "Yoga1_", fileNumRight, decimalRight)
			
			var temp1 = parseJson(temp0)
			var temp2 = findPositions(temp1)
			var temp3 = getCoordinates(temp2)
			
			#mapCoordinates(temp3)
			rotationTrack = _calculateAngles(temp3)
			
			var temp01 = parseJson(temp00)
			var temp02 = findPositions(temp01)
			var temp03 = getCoordinates(temp02)
			#mapRightCoordinates(temp03)
			rotationTrackRight = _calculateAngles(temp03, true)
			#$Sprite2D.texture = tempImage
			fileNum += 1
			if fileNum >= pow(10, decimal+1):
				decimal += 1
			fileNumRight += 1
			if fileNumRight >= pow(10, decimalRight+1):
				decimalRight += 1
			return true
		else:
			return false
		#await get_tree().create_timer(waitTime).timeout
		#NOTprocess()
	return false

func loadImage(stringcase : String, stringstr : String, fN = fileNum, dec = decimal) -> ImageTexture:
	var jpgName : String = stringcase + stringstr + parseStr.substr(0, strLength - decimal) + str(fN) + "_rendered.jpg"
	var jpg = FileAccess.open(jpgName, FileAccess.READ_WRITE)
	
	if jpg == null:
		print("Error opening file: ", jpgName)
		return null
	if jpg.get_length() < 100000:
		print("Jpg too small ")
		return null
	
	var buffer = jpg.get_buffer(jpg.get_length()) # Read entire file into a PackedByteArray
	
	var tempError = tempImage.load_jpg_from_buffer(buffer)
	if tempError != OK:
		print("Temperror ", tempError)	
		return null
	#"""
	# + stringstr2 
	
	jpg.close()
	return ImageTexture.create_from_image(tempImage)

func load_from_file(jsoncase : String, stringstr : String, fN = fileNum, dec = decimal):
	
	var fileName : String = jsoncase + stringstr + parseStr.substr(0, strLength - decimal) + str(fileNum) + "_keypoints.json"

	var file = FileAccess.open(fileName, FileAccess.READ)
	if file == null:
		print("Error opening file: ", FileAccess.get_open_error())
		print(fileName)
		#outOfFiles = true
		return null
	
	var content = file.get_as_text()
	return content
	
func parseJson(json_string : String) -> Dictionary:
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data_received = json.data
		return data_received
		"""
		if typeof(data_received) == TYPE_ARRAY:
			print(data_received) # Prints the array.
		else:
			print("Unexpected data")
		"""
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return {}

func findPositions(jsonDict : Dictionary) -> Array:
	if jsonDict.is_empty():
		return []
	var people = jsonDict["people"]
	if people.is_empty():
		return []
	var peopleDict = people[0]
	return peopleDict["pose_keypoints_2d"]

func getCoordinates(keypointArray : Array) -> PackedVector2Array:
	var tempSize = keypointArray.size()- 2
	var coordinateArray = PackedVector2Array()
	for i in range(0, tempSize, 3):
		coordinateArray.append(Vector2(keypointArray[i], keypointArray[i+1]))
	return coordinateArray

func addLineCoordinate(pos1 : Vector2, pos2 : Vector2, index : int, right = false) -> void:
	if 	pos1.length() > 20 and pos2.length() > 20:
		if right:
			$UserModelRight.get_child(index).points = [pos1,pos2]
		else:
			$UserModel.get_child(index).points = [pos1,pos2]

func mapHead(coordinateArray : PackedVector2Array) -> void:
	return
	if coordinateArray[0].length() < 20 or coordinateArray[1].length() < 20:
		return
	if coordinateArray[15].length() < 20 or coordinateArray[16].length() < 20:
		return
	if coordinateArray[17].length() < 20 or coordinateArray[18].length() < 20:
		return
	print("Passed")
	var top = (coordinateArray[15].y + coordinateArray[16].y)/2
	var left = coordinateArray[17].x - (coordinateArray[15].x - coordinateArray[17].x)
	var right = coordinateArray[18].x + (coordinateArray[18].x - coordinateArray[16].x)
	var bot = coordinateArray[0].y + (coordinateArray[1].y - coordinateArray[0].y) * 0.75
	var tempPos = [Vector2(left, top), Vector2(left, bot), Vector2(right, bot), Vector2(right, top)]
	#$Model/Head.polygon = tempPos
	#print(tempPos) 
	

func mapTorso(coordinateArray : PackedVector2Array) -> void:
	pass
	
func mapCoordinates(coordinateArray : PackedVector2Array) -> void:
	
	#print(coordinateArray)
	if coordinateArray.size() == 0:
		return
	$Node2D.position = coordinateArray[0] * 0.25 - Vector2(22,22)
	for i in range(4):
		addLineCoordinate(coordinateArray[i],coordinateArray[i+1], i)
	addLineCoordinate(coordinateArray[1],coordinateArray[5], 4)
	for i in range(5, 7, 1):
		addLineCoordinate(coordinateArray[i],coordinateArray[i+1], i)
	addLineCoordinate(coordinateArray[1],coordinateArray[8], 7)
	for i in range(8, 12, 1):
		addLineCoordinate(coordinateArray[i],coordinateArray[i+1], i)
	addLineCoordinate(coordinateArray[8],coordinateArray[12], 11)
	for i in range(12, 14, 1):
		addLineCoordinate(coordinateArray[i],coordinateArray[i+1], i)
	
	addLineCoordinate(coordinateArray[0],coordinateArray[15], 14)
	addLineCoordinate(coordinateArray[0],coordinateArray[16], 15)
	addLineCoordinate(coordinateArray[15],coordinateArray[17], 16)
	addLineCoordinate(coordinateArray[16],coordinateArray[18], 17)
	
	#mapHead(coordinateArray)
	_pointsToLength(coordinateArray)
	_calculateAngles(coordinateArray)
	
	"""
	if 	coordinateArray[1].length() > 15:
		$UserModel/Neck01.points = 			[coordinateArray[0],coordinateArray[1]]
	if 	coordinateArray[2].length() > 15:
		$UserModel/LShoulder12.points =		[coordinateArray[1],coordinateArray[2]]
	if 	coordinateArray[3].length() > 15:
		$UserModel/LArm23.points = 			[coordinateArray[2],coordinateArray[3]]
	if 	coordinateArray[4].length() > 15:
		$UserModel/LHand34.points = 		[coordinateArray[3],coordinateArray[4]]
	if 	coordinateArray[5].length() > 15:
		$UserModel/RShoulder15.points = 	[coordinateArray[1],coordinateArray[5]]
	if 	coordinateArray[6].length() > 15:
		$UserModel/RArm56.points = 			[coordinateArray[5],coordinateArray[6]]
	if 	coordinateArray[7].length() > 15:
		$UserModel/RHand67.points = 		[coordinateArray[6],coordinateArray[7]]
	if 	coordinateArray[8].length() > 15:
		$UserModel/Torso18.points = 		[coordinateArray[1],coordinateArray[8]]
	if 	coordinateArray[9].length() > 15:
		$UserModel/LHip89.points =		 	[coordinateArray[8],coordinateArray[9]]
	if 	coordinateArray[10].length() > 15:
		$UserModel/LThigh910.points =		[coordinateArray[9],coordinateArray[10]]
	if 	coordinateArray[11].length() > 15:
		$UserModel/LLeg1011.points =	[coordinateArray[10],coordinateArray[11]]
	if 	coordinateArray[12].length() > 15:
		$UserModel/RHip812.points =			[coordinateArray[8],coordinateArray[12]]
	if 	coordinateArray[13].length() > 15:
		$UserModel/RThigh1213.points =		[coordinateArray[12],coordinateArray[13]]
	if 	coordinateArray[14].length() > 15:
		$UserModel/RLeg1314.points =	[coordinateArray[13],coordinateArray[14]]
	if 	coordinateArray[15].length() > 15:
		$UserModel/LHead015.points =		[coordinateArray[0],coordinateArray[15]]
	if 	coordinateArray[16].length() > 15:
		$UserModel/RHead016.points =		[coordinateArray[0],coordinateArray[16]]
	if 	coordinateArray[17].length() > 15:
		$UserModel/LCheek1517.points =		[coordinateArray[15],coordinateArray[17]]
	if 	coordinateArray[18].length() > 15:
		$UserModel/RCheek1618.points =		[coordinateArray[16],coordinateArray[18]]
	"""

func mapRightCoordinates(coordinateArray : PackedVector2Array) -> void:
	#print(coordinateArray)
	if coordinateArray.size() == 0:
		return
		
	$Node2DRight.position = coordinateArray[0] * 0.25 - Vector2(22,22)
	for i in range(4):
		addLineCoordinate(coordinateArray[i],coordinateArray[i+1], i)
	addLineCoordinate(coordinateArray[1],coordinateArray[5], 4)
	for i in range(5, 7, 1):
		addLineCoordinate(coordinateArray[i],coordinateArray[i+1], i)
	addLineCoordinate(coordinateArray[1],coordinateArray[8], 7)
	for i in range(8, 12, 1):
		addLineCoordinate(coordinateArray[i],coordinateArray[i+1], i)
	addLineCoordinate(coordinateArray[8],coordinateArray[12], 11)
	for i in range(12, 14, 1):
		addLineCoordinate(coordinateArray[i],coordinateArray[i+1], i)
	
	addLineCoordinate(coordinateArray[0],coordinateArray[15], 14)
	addLineCoordinate(coordinateArray[0],coordinateArray[16], 15)
	addLineCoordinate(coordinateArray[15],coordinateArray[17], 16)
	addLineCoordinate(coordinateArray[16],coordinateArray[18], 17)
	
	#mapHead(coordinateArray)
	#_pointsToLength(coordinateArray)
	
	
	#fileNum += 1
	#if fileNum >= pow(10, decimal+1):
	#	decimal += 1

func _on_button_button_down() -> void:
	#$AnimationPlayer.play("BasicMove")
	processTrack = 2.0
	totalDuration = 2.0
	accuracyScore = 0

func _percentDifference(A : float, B : float) -> float:
	#A = fmod(A + 2*PI, 2*PI)
	#B = fmod(B + 2*PI, 2*PI)
	var tempDiff = abs(A - B) / (2*PI)
	if tempDiff > 0.5:
		tempDiff = 1.0 - tempDiff
	#print("A: ",  A, " B: ", B, " tD: ", tempDiff)
	return pow(tempDiff, strictness)

func _calculateBasicMoveAccuracy(delta) -> void:
	#Body 0, Tummy 1, Neck 2, LShoulder 3, LElbow 4, RShoulder 5, RElbow 6, LHip 7, LKnee 8, LCalf 9, RHip 10, RKnee 11, RCalf 12 
	var armRot = $Node2D/Skeleton2D/hip/chest/arm_right.rotation 
	var handRot = $Node2D/Skeleton2D/hip/chest/arm_right/hand_right.rotation
	var legRot = $Node2D/Skeleton2D/hip/leg_left.rotation
	
	var tempScore = 1 - _percentDifference(rotationTrack[7], legRot) * 0.5
	#print("tempscore 1 ", tempScore, " ", rad_to_deg(rotationTrack[7]), " ", rad_to_deg(legRot))
	var testScore1 = _percentDifference(rotationTrack[6], handRot) + _percentDifference(rotationTrack[5], armRot)
	var testScore2 = _percentDifference(rotationTrack[5], armRot + 0.5*handRot) * 1.25
	if testScore1 < testScore2:
		tempScore -= testScore1 * 0.5
		#print("tempscore 2 ", tempScore, " ", rad_to_deg(rotationTrack[5]), " ", rad_to_deg(armRot))
		#print("tempscore 3 ", tempScore, " ", rad_to_deg(rotationTrack[6]), " ", rad_to_deg(handRot))
	else:
		tempScore -= testScore2 * 0.5
		#print("tempscore 4 ", tempScore, " ", rad_to_deg(rotationTrack[5]), " ", rad_to_deg(armRot))
		#print("tempscore 5 ", tempScore, " ", rad_to_deg(rotationTrack[6]), " ", rad_to_deg(handRot))
	accuracyScore = accuracyScore + (delta * tempScore) #/ (totalDuration - processTrack)
	$AccuracyLabel.text = str(100 * accuracyScore / (totalDuration - processTrack))

func _calculateMoveAccuracy(delta) -> void:
	#if totalDuration <= processTrack
	#Body 0, Tummy 1, Neck 2, LShoulder 3, LElbow 4, RShoulder 5, RElbow 6, LHip 7, LKnee 8, LCalf 9, RHip 10, RKnee 11, RCalf 12 
	var tempScore = 1.0
	var mult = 1 + processTrack/30
	#Consider a different scale.
	for i in range(12):
		tempScore -= _percentDifference(rotationTrack[i], rotationTrackRight[i]) * mult / 12
		#print(i)
	print(tempScore)
	accuracyScore = accuracyScore + (delta * tempScore) #/ (totalDuration - processTrack)
	$AccuracyLabel.text = str(100 * accuracyScore / (processTrack))

func _calculateAngles(coordinateArray : PackedVector2Array, rightAngle = false) -> PackedFloat32Array:
	#Body 0
	#null
	var Skeleton = "Node2DRight2/Skeleton2D/hip/" if rightAngle else "Node2D2/Skeleton2D/hip/"
	var rotTrack : PackedFloat32Array = [0,0,0,0,0,0,0,0,0,0,0,0,0]
	if coordinateArray.size() < 14:
		return rotTrack
	#Tummy 1
	if coordinateArray[1].length() > invalidPos and coordinateArray[8].length() > invalidPos:
		rotTrack[1] = coordinateArray[8].angle_to_point(coordinateArray[1]) + PI/2
		#get_node(Skeleton + "chest").rotation = rotTrack[1]
	
	#Neck 2
	if coordinateArray[1].length() > invalidPos and coordinateArray[0].length() > invalidPos:
		rotTrack[2] = coordinateArray[1].angle_to_point(coordinateArray[0]) + PI/2
		#get_node(Skeleton + "chest/head").rotation = rotTrack[2]
	
	#LShoulder 3
	if coordinateArray[2].length() > invalidPos and coordinateArray[3].length() > invalidPos:
		rotTrack[3] = coordinateArray[2].angle_to_point(coordinateArray[3]) - PI/2
		#get_node(Skeleton + "chest/arm_left").rotation = rotTrack[3]
	
	#LElbow 4
	if coordinateArray[4].length() > invalidPos and coordinateArray[3].length() > invalidPos:
		rotTrack[4] = coordinateArray[3].angle_to_point(coordinateArray[4]) - PI/2
		#get_node(Skeleton + "chest/arm_left/hand_left").rotation = rotTrack[4]
		
	#RShoulder 5
	if coordinateArray[5].length() > invalidPos and coordinateArray[6].length() > invalidPos:
		rotTrack[5] = coordinateArray[5].angle_to_point(coordinateArray[6]) - PI/2
		#get_node(Skeleton + "chest/arm_right").rotation = rotTrack[5]
	
	#RElbow 6
	if coordinateArray[7].length() > invalidPos and coordinateArray[6].length() > invalidPos:
		rotTrack[6] = coordinateArray[6].angle_to_point(coordinateArray[7])# - PI/2
		#get_node(Skeleton + "chest/arm_right/hand_right").rotation = rotTrack[6]
	
	#LHip 7
	if coordinateArray[9].length() > invalidPos and coordinateArray[10].length() > invalidPos:
		rotTrack[7] = coordinateArray[9].angle_to_point(coordinateArray[10]) - PI/2	
		#get_node(Skeleton + "leg_left").rotation = rotTrack[7]
	
	#LKnee 8
	if coordinateArray[11].length() > invalidPos and coordinateArray[10].length() > invalidPos:
		rotTrack[8] = coordinateArray[10].angle_to_point(coordinateArray[11]) - PI/2	
		#get_node(Skeleton + "leg_left/calf_left").rotation = rotTrack[8]
	
	#LCalf 9
	#null
	
	#RHip 10
	if coordinateArray[12].length() > invalidPos and coordinateArray[13].length() > invalidPos:
		rotTrack[10] = coordinateArray[12].angle_to_point(coordinateArray[13]) - PI/2
		#get_node(Skeleton + "leg_right").rotation = rotTrack[10]
	
	#RKnee 11
	if coordinateArray[14].length() > invalidPos and coordinateArray[13].length() > invalidPos:
		rotTrack[11] = coordinateArray[13].angle_to_point(coordinateArray[14]) - PI/2
		#get_node(Skeleton + "leg_right/calf_right").rotation = rotTrack[11]
		
	#RCalf 12 
	#null
	
	return rotTrack
	
#Put this into the various map functions later I'm just lazy here
func _pointsToLength(coordinateArray : PackedVector2Array):
	var limbsThatWork = 0
	var tempLimbs = 0
	var hipNeckPos = Vector2.ZERO
	avgSizeMult = 0
	if coordinateArray[0].length() > invalidPos and coordinateArray[1].length() > invalidPos:		
		
		#if coordinateArray[15].length() > invalidPos or coordinateArray[17].length() > invalidPos:
		#	return
		#if coordinateArray[16].length() < 20 or coordinateArray[18].length() < 20:
		#	return
		headBaseMult = (coordinateArray[0].distance_to(coordinateArray[1]) * 0.8) / headBase
		limbsThatWork += 1
		avgSizeMult += headBaseMult
	else:
		pass
	#HeadHeight = NeckLength(0,1) * 0.75 
	#HeadWidth = (LCheek(15,17) or RCheek(16,18) * 2 or LCheek + RCheek
	
	if coordinateArray[1].length() > invalidPos and coordinateArray[8].length() > invalidPos:
		var torsoLen = coordinateArray[1].distance_to(coordinateArray[8])
		hipNeckPos = coordinateArray[8] + 0.2*(coordinateArray[1]-coordinateArray[8])
		torsoLengthMult = (torsoLen * 0.9) / torsoLength
		tempLimbs += 1
	if coordinateArray[2].length() > invalidPos and coordinateArray[5].length() > invalidPos:
		if coordinateArray[9].length() > invalidPos and coordinateArray[12].length() > invalidPos:
			var tempTorso = coordinateArray[2].distance_to(coordinateArray[5])
			torsoBaseMult = (tempTorso * 2 + coordinateArray[9].distance_to(coordinateArray[12])) / (torsoBase * 3)
		else:
			torsoBaseMult = (coordinateArray[2].distance_to(coordinateArray[5]) * 0.8) / torsoBase
		
		tempLimbs += 2
	elif coordinateArray[9].length() > invalidPos and coordinateArray[12].length() > invalidPos:
		torsoBaseMult = (coordinateArray[9].distance_to(coordinateArray[12]) * 1.2) / torsoBase
		tempLimbs += 2
		
	if tempLimbs > 2:
		limbsThatWork += 1
		avgSizeMult += (torsoBaseMult + torsoLengthMult) / 2
	elif tempLimbs == 2:
		limbsThatWork += 1
		avgSizeMult += torsoBaseMult
	elif tempLimbs:
		limbsThatWork += 1
		avgSizeMult += torsoLengthMult
	#TorsoBase = (Shoulder(2,5) + Shoulder(2,5) + Hip(9,12)) / 3 - Skewed average
	#TorsoHeight = Torso(1,8) * 0.9 (should be a bit higher too)
	
	if coordinateArray[2].length() > invalidPos and coordinateArray[3].length() > invalidPos:
		var armLen = larmLength
		if coordinateArray[3].length() > invalidPos and coordinateArray[4].length() > invalidPos:
			armLen = coordinateArray[2].distance_to(coordinateArray[3]) + coordinateArray[3].distance_to(coordinateArray[4])
		else:
			armLen = coordinateArray[2].distance_to(coordinateArray[3]) * 2
		larmLengthMult = armLen / larmLength
		larmBaseMult = armLen / (larmBase * 4)
		
		limbsThatWork += 1
		avgSizeMult += (larmBaseMult + larmLengthMult) / 2
	#LArmBase = TorsoBase * 0.4
	#LArmHeight = FullArm(2,4) (move out a little)
	
	if coordinateArray[1].length() > invalidPos and coordinateArray[6].length() > invalidPos:
		var armLen = rarmLength
		if coordinateArray[5].length() > invalidPos and coordinateArray[4].length() > invalidPos:
			armLen = coordinateArray[1].distance_to(coordinateArray[5]) + coordinateArray[5].distance_to(coordinateArray[6])
		else:
			armLen = coordinateArray[1].distance_to(coordinateArray[5]) * 2
		rarmLengthMult = armLen / rarmLength
		rarmBaseMult = armLen / (rarmBase * 4)
		limbsThatWork += 1
		avgSizeMult += (rarmBaseMult + rarmLengthMult) / 2
	#RArmBase = TorsoBase * 0.4
	#RArmHeight = FullArm(5,7) (move out a little)
	
	if coordinateArray[9].length() > invalidPos and coordinateArray[10].length() > invalidPos:
		var legLen = llegLength
		if coordinateArray[10].length() > invalidPos and coordinateArray[11].length() > invalidPos:
			legLen = coordinateArray[9].distance_to(coordinateArray[10]) + coordinateArray[10].distance_to(coordinateArray[11])
		else:
			legLen = coordinateArray[9].distance_to(coordinateArray[10]) * 2
		llegLengthMult = legLen / llegLength
		llegBaseMult = legLen / (llegBase * 4)
		limbsThatWork += 1
		avgSizeMult += (llegBaseMult + llegLengthMult) / 2
	#LLegBase = TorsoBase * 0.5
	#LLegHeight = FullLeg(9,11) (move out a little)
	
	if coordinateArray[12].length() > invalidPos and coordinateArray[13].length() > invalidPos:
		var legLen = rlegLength
		if coordinateArray[13].length() > invalidPos and coordinateArray[14].length() > invalidPos:
			legLen = coordinateArray[12].distance_to(coordinateArray[13]) + coordinateArray[13].distance_to(coordinateArray[14])
		else:
			legLen = coordinateArray[12].distance_to(coordinateArray[13]) * 2
		rlegLengthMult = legLen / rlegLength
		rlegBaseMult = legLen / (rlegBase * 4)
		limbsThatWork += 1
		avgSizeMult += (rlegBaseMult + rlegLengthMult) / 2
	#RLegBase = TorsoBase * 0.5
	#RLegHeight = FullLeg(12,13) (move out a little)
	avgSizeMult *= 0.45 * 1.1
	if limbsThatWork == 0:
		avgSizeMult = 1
	else:
		avgSizeMult /= limbsThatWork
	#print(avgSizeMult)
	$Node2D/Skeleton2D/hip.scale = Vector2(avgSizeMult,avgSizeMult)
	
	if hipNeckPos != Vector2.ZERO:
		#print(0.45*hipNeckPos)
		$Node2D/Skeleton2D/hip.position = Vector2(0.45,0.45)*hipNeckPos + Vector2(-425,15) #- Vector2(120,25)
