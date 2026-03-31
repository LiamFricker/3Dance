extends Node2D

@export var fileNum: int = 1#180
@onready var decimal: int = floor(log(fileNum)/ log(10))
@export var fileNumRight: int = 1#100
@onready var decimalRight: int = floor(log(fileNumRight)/ log(10))
@export var endFileLeft : int = 0
@export var endFileRight : int = 0
var deltaNum: int = 1
@export var fileMaxLeft: int = 763
@export var fileMaxRight: int = 977

@export var realTimeTesting = true

#0 Start, 1 Loading, 2 VideoTuning, 3 UI
@export var menu_state = 0
var teacherSelection : bool = true
var file_path_left = "../HH1_" #"../Teacher_"
var file_name_left = "HH1_"
var file_path_right = "../GoodHH1_" #"../Student_" 
var file_name_right = "GoodHH1_"


var leftRotation = 0
var rightRotation = 0
var curFileLeft = 0
var curFileRight = 0

const strLength: int = 11
var parseStr : String = "00000000000"
var outOfFiles : bool = false
var waitTime : float = 0.033

@export var strictness : float = 1.0
@export var slowness : int = 1
var timerCheck : int = 0

@export var processTrack : float = 0
@export var totalDuration : float = 72
var accuracyScore : float = 0.0
var accuracyScoreLLeg : float = 0.0
var accuracyScoreRLeg : float = 0.0
var accuracyScoreLArm : float = 0.0
var accuracyScoreRArm : float = 0.0
var accuracyScoreHead : float = 0.0
var accuracyScoreTorso : float = 0.0

#0: fail, 1: pass, 2: test
var strcase = 1

#Hip, Chest, Head, LArm, LHand, RArm, RHand, LLeg, LCalf, LFoot, RLeg, RCalf, RFoot
#Body 0, Tummy 1, Neck 2, LShoulder 3, LElbow 4, RShoulder 5, RElbow 6, LHip 7, LKnee 8, LCalf 9, RHip 10, RKnee 11, RCalf 12 
#Body, LCalf, RCalf Removed
var rotationTrack : PackedFloat32Array = [0,0,0,0,0,0,0,0,0,0]#0,0,0]
var rotationTrackRight : PackedFloat32Array = [0,0,0,0,0,0,0,0,0,0]#0,0,0]

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

var prevCoordinateArray : PackedVector2Array
var prevCoordinateArrayRight : PackedVector2Array

var isPaused : bool = false
var deltaBuildup : float = 0

@export var offset = 15 

var pastFileNumRight = -200
var colorTween
var currentScore = 0
var currentQueue = []


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
	#$UI/Panel3/Advice.text = "Generating...\n\n\n\n\n"
	tempImage = Image.load_from_file("res://icon.svg")
	tempImage2 = Image.load_from_file("res://icon.svg")
	$Camera2D2.enabled = realTimeTesting
	$Camera2D.enabled = not realTimeTesting
	if realTimeTesting:
		file_path_right = "../Student_" #GoodHH1_ Student_
		file_name_right = ""#""
		
		$UI3/StartEndTime.text = "00:00                                   " + _calcTimeStr(fileMaxLeft)
		menu_state = 3
		
	#NOTprocess()

func _process(delta) -> void:
	if menu_state == 3:
		if not isPaused:
			timerCheck += 1
			if timerCheck % slowness == 0:
				if processTrack < totalDuration:
					if NOTprocess(delta):
						processTrack += deltaNum
						_calculateMoveAccuracy(deltaNum)
		else:
			NOTprocess(delta)
				
func _on_seek_slider_value_changed(value: float) -> void:
	outOfFiles = false
	totalDuration = 100000
	fileNum = floor(value * fileMaxLeft / 100)
	if fileNum < 10:
		decimal = 0
	else:
		decimal = floor(log(fileNum)/ log(10))
	NOTprocess(0, false)
	processTrack = fileNum
		#processTrack += deltaNum
		#_calculateMoveAccuracy(deltaNum)

func _on_pause_play_button_down() -> void:
	#Might add more code here later 
	if (isPaused):
		isPaused = false
	else:
		$UI3/SeekSlider.value = floor(100 * fileNum / fileMaxLeft)
		isPaused = true


func _on_button_button_down() -> void:
	#return
	if not outOfFiles:
		if realTimeTesting:
			var tempFileNum = fileNum+offset
			var tempDec = 0
			if tempFileNum >= 10:
				tempDec = floor(log(tempFileNum)/ log(10))
			$UI3/Panel5/TextureRect.texture = loadImage(file_path_left + "images/", file_name_left, tempFileNum, tempDec)
		else:
			$UI/Panel5/TextureRect.texture = loadImage(file_path_left + "images/", file_name_left, fileNum, decimal)
			#$UI/Panel2/TextureRect.texture = loadImage("../GoodHH1_images/", "GoodHH1_", fileNumRight, decimalRight)
			$UI/Panel7/TextureRect.texture = loadImage(file_path_right + "images/", file_name_right, fileNumRight, decimalRight, false)
		
		#$UI/Panel/TextureRect.texture = loadImage("../Demo1_images/", "Yoga1_", fileNum, decimal)
		#$Sprite2D2.texture = loadImage("../Good1_images/", "GoodYoga1_", fileNumRight, decimalRight)
		#$UI/Panel2/TextureRect.texture = loadImage("../BadYoga1_images/", "BadYoga1_", fileNumRight, decimalRight)
		#$Sprite2D2.texture = loadImage("../Bad3_images/", "BadYoga3_", fileNumRight, decimalRight)
		#$Sprite2D2.texture = loadImage("../Good1_images/", "GoodYoga1_", fileNumRight, decimalRight)
		#$Sprite2D2.texture = loadImage("../Demo1_images/", "Yoga1_", fileNumRight, decimalRight)
	else:
		$Timer.stop()

func NOTprocess(delta : float, adjustFilenum = true) -> bool:
	if not outOfFiles and fileNum < fileMaxLeft:
		var temp0 = load_from_file(file_path_left + "json/", file_name_left, fileNum, decimal)
		#var temp00 = load_from_file("../HH1_json/", "HH1_")
		#var temp00 = load_from_file("../GoodHH1_json/", "GoodHH1_", fileNumRight, decimalRight)
		var temp00 = load_from_file(file_path_right + "json/", file_name_right, fileNumRight, decimalRight)
		#var temp0 = load_from_file("../Demo1_json/", "Yoga1_")
		#var temp00 = load_from_file("../Good1_json/", "GoodYoga1_", fileNumRight, decimalRight)
		#var temp00 = load_from_file("../Bad1_json/", "BadYoga1_", fileNumRight, decimalRight)
		
		if temp00 and (not temp0 or isPaused):
			var temp01 = parseJson(temp00)
			var temp02 = findPositions(temp01)
			var temp03 = getCoordinates(temp02, prevCoordinateArrayRight)
			prevCoordinateArrayRight = temp03
			rotationTrackRight = _calculateAngles(temp03, true)
			_assignModelAngles(rotationTrackRight, true)
			deltaNum = floor((delta * 60) + 0.5)
	
			fileNumRight += deltaNum
			if fileNumRight >= pow(10, decimalRight+1):
				decimalRight += 1
			if (temp0 and adjustFilenum):
				var temp1 = parseJson(temp0)
				var temp2 = findPositions(temp1)
				var temp3 = getCoordinates(temp2, prevCoordinateArray)
				prevCoordinateArray = temp3
				
				mapCoordinates(temp3)
				rotationTrack = _calculateAngles(temp3)
				if realTimeTesting:
					_assignModelAngles(rotationTrack)
			return false
		elif temp0 and temp00:
			var temp1 = parseJson(temp0)
			var temp2 = findPositions(temp1)
			var temp3 = getCoordinates(temp2, prevCoordinateArray)
			prevCoordinateArray = temp3
			
			mapCoordinates(temp3)
			rotationTrack = _calculateAngles(temp3)
			if realTimeTesting:
				_assignModelAngles(rotationTrack)
				
			
			var temp01 = parseJson(temp00)
			var temp02 = findPositions(temp01)
			var temp03 = getCoordinates(temp02, prevCoordinateArrayRight)
			prevCoordinateArrayRight = temp03
			
			#mapRightCoordinates(temp03)
			rotationTrackRight = _calculateAngles(temp03, true)
			if realTimeTesting:
				_assignModelAngles(rotationTrackRight, true)
			#$Sprite2D.texture = tempImage
			
			if adjustFilenum:
				deltaNum = floor((delta * 60) + 0.5)
				fileNumRight += deltaNum
				if fileNumRight >= pow(10, decimalRight+1):
					decimalRight += 1
				
				deltaNum = floor(((delta + deltaBuildup) * 60) + 0.5)
				fileNum += deltaNum
				if fileNum >= pow(10, decimal+1):
					decimal += 1
				deltaBuildup = 0
				
			$UI3/CurrTime.text = _calcTimeStr(fileNum)
			
			return true
		else:
			deltaBuildup += delta
			return false
		#await get_tree().create_timer(waitTime).timeout
		#NOTprocess()
	else:
		totalDuration = 1
		_chooseAdvice()
		
	return false

func _chooseAdvice() -> void:
	var lines = 4
	var adviceStr = ""
	var passScore = 0.7 * processTrack
	if accuracyScoreLLeg < passScore or accuracyScoreRLeg < passScore:
		adviceStr += " Bring your knees up higher (90 degree bend).\n"
		lines -= 1
	if accuracyScoreLArm < passScore or accuracyScoreRArm < passScore:
		adviceStr += " Keep your arms bent (90 degree bend).\n" #from the duration of this move
		lines -= 1
	if accuracyScoreHead < passScore:
		adviceStr += " Turn your head all the way to your left.\n"
		lines -= 1
	if accuracyScoreTorso < passScore:
		adviceStr += " Try to make your stance wider.\n"
		lines -= 1
	for i in range(lines):
		adviceStr += "\n"
	$UI/Panel3/Advice.text = adviceStr

func loadImage(stringcase : String, stringstr : String, fN = fileNum, dec = decimal, left = true) -> ImageTexture:
	var jpgName : String = stringcase + stringstr + parseStr.substr(0, strLength - dec) + str(fN) + "_rendered.jpg"
	#if realTimeTesting:
	#	jpgName = stringcase + parseStr.substr(0, strLength - dec) + str(fN) + "_rendered.jpg"
	var jpg = FileAccess.open(jpgName, FileAccess.READ_WRITE)
	
	if jpg == null:
		print("Error opening file: ", jpgName)
		outOfFiles = not realTimeTesting
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
	
	if left:
		match leftRotation:
			90:
				tempImage.rotate_90(0)
			180:
				tempImage.rotate_180()
			270:
				tempImage.rotate_90(1)
	else:
		match rightRotation:
			90:
				tempImage.rotate_90(0)
			180:
				tempImage.rotate_180()
			270:
				tempImage.rotate_90(1)
	
	jpg.close()
	return ImageTexture.create_from_image(tempImage)

func load_from_file(jsoncase : String, stringstr : String, fN = fileNum, dec = decimal):
	
	var fileName : String = jsoncase + stringstr + parseStr.substr(0, strLength - dec) + str(fN) + "_keypoints.json"
	#if realTimeTesting:
	#	fileName = jsoncase + parseStr.substr(0, strLength - decimal) + str(fileNum) + "_keypoints.json"
	var file = FileAccess.open(fileName, FileAccess.READ)
	if file == null:
		print("Error opening file: ", FileAccess.get_open_error())
		print(fileName)
		outOfFiles =  not realTimeTesting
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

func getCoordinates(keypointArray : Array, substituteArr : PackedVector2Array) -> PackedVector2Array:
	var tempSize = keypointArray.size()- 2
	var coordinateArray = PackedVector2Array()
	if (substituteArr.size() > 0 and fileNum > 150):
		for i in range(0, tempSize, 3):
			var tempVec = Vector2(keypointArray[i], keypointArray[i+1])
			var tempDist = tempVec.distance_squared_to(substituteArr[i/3])
			#if(tempDist > 200000):
			#	coordinateArray.append(substituteArr[i/3])
			if(tempDist > 150000):
				coordinateArray.append(0.125 * (7 * substituteArr[i/3]+tempVec)) #coordinateArray.append(substituteArr[i/3])
			elif(tempDist > 100000):
				coordinateArray.append(0.25 * (3 * substituteArr[i/3]+tempVec))
			elif(tempDist > 40000):
				coordinateArray.append(0.5 * (substituteArr[i/3]+tempVec))
			else:
				coordinateArray.append(tempVec)
	else:
		for i in range(0, tempSize, 3):
			coordinateArray.append(Vector2(keypointArray[i], keypointArray[i+1]))
	return coordinateArray

func addLineCoordinate(pos1 : Vector2, pos2 : Vector2, index : int, right = false) -> void:
	if 	pos1.length() > 20 and pos2.length() > 20:
		if right:
			$UserModelRight.get_child(index).points = [pos1,pos2]
		else:
			$UI3/UserModel.get_child(index).points = [pos1,pos2]

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
	#_pointsToLength(coordinateArray)
	#_calculateAngles(coordinateArray)

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

func _percentDifference(A : float, B : float) -> float:
	#A = fmod(A + 2*PI, 2*PI)
	#B = fmod(B + 2*PI, 2*PI)
	var tempDiff = abs(A - B) / (PI)
	if tempDiff > 1.0:
		tempDiff = abs(2.0 - tempDiff)
	#print("A: ",  A, " B: ", B, " tD: ", tempDiff, " postTemp: ", pow(tempDiff/2, strictness))
	return pow(tempDiff/2, strictness)

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

func _calculateRealTimeAccuracy(delta) -> void:
	
	var tempScore = 1.0
	var multScore = 0
	
	multScore = _percentDifference(rotationTrack[0], rotationTrackRight[0])
	tempScore -= multScore * 0.1
	accuracyScoreTorso += (deltaNum * (1.0 - multScore))
	
	multScore = _percentDifference(rotationTrack[1], rotationTrackRight[1])
	tempScore -= multScore * 0.1
	accuracyScoreHead += (deltaNum * (1.0 - multScore))
	
	multScore = _percentDifference(rotationTrack[2], rotationTrackRight[2])+_percentDifference(rotationTrack[3], rotationTrackRight[3])
	tempScore -= multScore * 0.1
	accuracyScoreLArm += (deltaNum * (1.0 - multScore*0.5))
	
	multScore = _percentDifference(rotationTrack[4], rotationTrackRight[4])+_percentDifference(rotationTrack[5], rotationTrackRight[5])
	tempScore -= multScore * 0.1
	accuracyScoreRArm += (deltaNum * (1.0 - multScore*0.5))
	
	multScore = _percentDifference(rotationTrack[6], rotationTrackRight[6])+_percentDifference(rotationTrack[7], rotationTrackRight[7])
	tempScore -= multScore * 0.1
	accuracyScoreLLeg += (deltaNum * (1.0 - multScore*0.5))
	
	multScore = _percentDifference(rotationTrack[8], rotationTrackRight[8])+_percentDifference(rotationTrack[9], rotationTrackRight[9])
	tempScore -= multScore * 0.1
	accuracyScoreRLeg += (deltaNum * (1.0 - multScore*0.5))
	
	currentScore += (deltaNum * tempScore)
	
	if fileNumRight > pastFileNumRight + 30:
		var tempDiff = fileNumRight - pastFileNumRight
		if pastFileNumRight < 0:
			tempDiff = 1
			currentQueue.push_back(currentScore/10)
		else:
			currentQueue.push_back(currentScore/tempDiff)
		if colorTween:	
			colorTween.kill()
		colorTween = create_tween()
		colorTween.set_parallel()
		colorTween.tween_property($UI3/Node2D/Model2/Torso, "modulate", _matchColor(accuracyScoreTorso/tempDiff), 0.5)
		colorTween.tween_property($UI3/Node2D/Model2/Head, "modulate", _matchColor(accuracyScoreHead/tempDiff), 0.5)
		colorTween.tween_property($UI3/Node2D/Model2/LArm, "modulate", _matchColor(accuracyScoreLArm/tempDiff), 0.5)
		colorTween.tween_property($UI3/Node2D/Model2/RArm, "modulate", _matchColor(accuracyScoreRArm/tempDiff), 0.5)
		colorTween.tween_property($UI3/Node2D/Model2/LLeg, "modulate", _matchColor(accuracyScoreLLeg/tempDiff), 0.5)
		colorTween.tween_property($UI3/Node2D/Model2/RLeg, "modulate", _matchColor(accuracyScoreRLeg/tempDiff), 0.5)
		
		var tempSize = currentQueue.size()
		if (tempSize > 5): 
		
			currentQueue.pop_front()
			var tempAvr = 0
			for i in currentQueue:
				tempAvr += i / (tempSize - 1)
			
			colorTween.tween_property($UI3/Arrows, "position", Vector2(_arrowPos(tempAvr), 0), 0.5)
		
		accuracyScoreTorso = 0
		accuracyScoreHead = 0
		accuracyScoreLArm = 0
		accuracyScoreRArm = 0
		accuracyScoreLLeg = 0
		accuracyScoreRLeg = 0
		currentScore = 0
		pastFileNumRight = fileNumRight
		
	
	accuracyScore += (deltaNum * tempScore) 
	$UI3/AccuracyScore.text = "SCORE: " + str(int(10 * accuracyScore)) + " pts"
	

func _calculateMoveAccuracy(delta) -> void:
	if realTimeTesting:
		_calculateRealTimeAccuracy(delta)
		return
	#if totalDuration <= processTrack
	#Body 0, Tummy 1, Neck 2, LShoulder 3, LElbow 4, RShoulder 5, RElbow 6, LHip 7, LKnee 8, LCalf 9, RHip 10, RKnee 11, RCalf 12 
	#Tummy 0, Neck 1, LShoulder 2, LElbow 3, RShoulder 4, RElbow 5, LHip 6, LKnee 7, RHip 8, RKnee 9 
	var tempScore = 1.0
	#var mult = 1 + processTrack/1800
	#Consider a different scale.
	#for i in range(0, 10, 1):
	#	var multScore = _percentDifference(rotationTrack[i], rotationTrackRight[i]) 
		#tempScore -= multScore * 1/10#pow(multScore, mult)
		#tempScore -= 0.1 * _percentDifference(rotationTrack[i], rotationTrackRight[i]) 
		#print(i)#Body 0, Tummy 1, Neck 2, LShoulder 3, LElbow 4, RShoulder 5, RElbow 6, LHip 7, LKnee 8, LCalf 9, RHip 10, RKnee 11, RCalf 12 
	var multScore = 0
	
	multScore = _percentDifference(rotationTrack[0], rotationTrackRight[0])
	tempScore -= multScore * 0.1
	accuracyScoreTorso += (deltaNum * (1.0 - multScore))
	$UI/AccuracyScoreTorso.text = "TORSO: " + str(ceil(100 * accuracyScoreTorso / (processTrack))) + "%"
	$UI/Body/Torso.material.set_shader_parameter("progress", max(0.1, accuracyScoreTorso / processTrack))#processTrack * 2 / totalDuration
	
	multScore = _percentDifference(rotationTrack[1], rotationTrackRight[1])
	tempScore -= multScore * 0.1
	accuracyScoreHead += (deltaNum * (1.0 - multScore))
	$UI/AccuracyScoreHead.text = "HEAD: " + str(ceil(100 * accuracyScoreHead / (processTrack))) + "%"
	$UI/Body/Head.material.set_shader_parameter("progress", max(0.1, accuracyScoreHead / processTrack))
	
	multScore = _percentDifference(rotationTrack[2], rotationTrackRight[2])+_percentDifference(rotationTrack[3], rotationTrackRight[3])
	tempScore -= multScore * 0.1
	accuracyScoreLArm += (deltaNum * (1.0 - multScore*0.5))
	$UI/AccuracyScoreLArm.text = "LEFT ARM: " + str(ceil(100 * accuracyScoreLArm / (processTrack))) + "%"
	$UI/Body/LArm.material.set_shader_parameter("progress", max(0.1, accuracyScoreLArm / processTrack))
	
	multScore = _percentDifference(rotationTrack[4], rotationTrackRight[4])+_percentDifference(rotationTrack[5], rotationTrackRight[5])
	tempScore -= multScore * 0.1
	accuracyScoreRArm += (deltaNum * (1.0 - multScore*0.5))
	$UI/AccuracyScoreRArm.text = "RIGHT ARM: " + str(ceil(100 * accuracyScoreRArm / (processTrack))) + "%"
	$UI/Body/RArm.material.set_shader_parameter("progress", max(0.1, accuracyScoreRArm / processTrack))
	
	multScore = _percentDifference(rotationTrack[6], rotationTrackRight[6])+_percentDifference(rotationTrack[7], rotationTrackRight[7])
	tempScore -= multScore * 0.1
	accuracyScoreLLeg += (deltaNum * (1.0 - multScore*0.5))
	$UI/AccuracyScoreLLeg.text = "LEFT LEG: " + str(ceil(100 * accuracyScoreLLeg / (processTrack))) + "%"
	$UI/Body/LLeg.material.set_shader_parameter("progress", max(0.1, accuracyScoreLLeg / processTrack))
	
	multScore = _percentDifference(rotationTrack[8], rotationTrackRight[8])+_percentDifference(rotationTrack[9], rotationTrackRight[9])
	tempScore -= multScore * 0.1
	accuracyScoreRLeg += (deltaNum * (1.0 - multScore*0.5))
	$UI/AccuracyScoreRLeg.text = "RIGHT LEG: " + str(ceil(100 * accuracyScoreRLeg / (processTrack))) + "%"
	$UI/Body/RLeg.material.set_shader_parameter("progress", max(0.1, accuracyScoreRLeg / processTrack))
	
	accuracyScore += (deltaNum * tempScore) 
	$UI/AccuracyScore.text = "TOTAL ACCURACY SCORE: " + str(ceil(100 * accuracyScore / (processTrack))) + "%"
	$UI/CurrentScore.text = "CURRENT ACCURACY SCORE: " + str(ceil(100 * tempScore)) + "%"

func _calculateAngles(coordinateArray : PackedVector2Array, rightAngle = false) -> PackedFloat32Array:
	#Body 0
	#null
	var rotTrack : PackedFloat32Array = [0,0,0,0,0,0,0,0,0,0]#,0,0,0]
	if coordinateArray.size() < 14:
		return rotTrack
	#Tummy 1
	if coordinateArray[1].length() > invalidPos and coordinateArray[8].length() > invalidPos:
		rotTrack[0] = (coordinateArray[8].angle_to_point(coordinateArray[1]) + PI/2)
	
	#Neck 2
	if coordinateArray[1].length() > invalidPos and coordinateArray[0].length() > invalidPos:
		rotTrack[1] = (coordinateArray[1].angle_to_point(coordinateArray[0]) + PI/2)
	
	#LShoulder 3
	if coordinateArray[2].length() > invalidPos and coordinateArray[3].length() > invalidPos:
		rotTrack[2] = (coordinateArray[2].angle_to_point(coordinateArray[3]) - PI/2)
	
	#LElbow 4
	if coordinateArray[4].length() > invalidPos and coordinateArray[3].length() > invalidPos:
		rotTrack[3] = (coordinateArray[3].angle_to_point(coordinateArray[4]) - PI/2) - rotTrack[2]
		
	#RShoulder 5
	if coordinateArray[5].length() > invalidPos and coordinateArray[6].length() > invalidPos:
		rotTrack[4] = (coordinateArray[5].angle_to_point(coordinateArray[6]) - PI/2)
	
	#RElbow 6
	if coordinateArray[7].length() > invalidPos and coordinateArray[6].length() > invalidPos:
		rotTrack[5] = (coordinateArray[6].angle_to_point(coordinateArray[7]) - PI/2) - rotTrack[4]
	
	#LHip 7
	if coordinateArray[9].length() > invalidPos and coordinateArray[10].length() > invalidPos:
		rotTrack[6] = (coordinateArray[9].angle_to_point(coordinateArray[10]) - PI/2)	
	
	#LKnee 8
	if coordinateArray[11].length() > invalidPos and coordinateArray[10].length() > invalidPos:
		rotTrack[7] = (coordinateArray[10].angle_to_point(coordinateArray[11]) - PI/2)	- rotTrack[6]
	
	#LCalf 9
	#null
	
	#RHip 10
	if coordinateArray[12].length() > invalidPos and coordinateArray[13].length() > invalidPos:
		rotTrack[8] = (coordinateArray[12].angle_to_point(coordinateArray[13]) - PI/2)
	
	#RKnee 11
	if coordinateArray[14].length() > invalidPos and coordinateArray[13].length() > invalidPos:
		rotTrack[9] = (coordinateArray[13].angle_to_point(coordinateArray[14]) - PI/2) - rotTrack[8]
		
	#RCalf 12 
	#null
	return rotTrack


func _assignModelAngles(rotTrack : PackedFloat32Array, rightAngle = false):
	
	var Skeleton = "UI3/Node2D/Skeleton2D/hip/" if rightAngle else "UI3/Node2D2/Skeleton2D/hip/"
	#var Skeleton = "Node2D2/Skeleton2D/hip/" if rightAngle else "Node2D/Skeleton2D/hip/"
	
	get_node(Skeleton + "chest").rotation = rotTrack[0]
	get_node(Skeleton + "chest/head").rotation = rotTrack[1]
	get_node(Skeleton + "chest/arm_left").rotation = rotTrack[2]
	get_node(Skeleton + "chest/arm_left/hand_left").rotation = rotTrack[3]
	get_node(Skeleton + "chest/arm_right").rotation = rotTrack[4]
	get_node(Skeleton + "chest/arm_right/hand_right").rotation = rotTrack[5]
	get_node(Skeleton + "leg_left").rotation = rotTrack[6]
	get_node(Skeleton + "leg_left/calf_left").rotation = rotTrack[7]
	get_node(Skeleton + "leg_right").rotation = rotTrack[8]
	get_node(Skeleton + "leg_right/calf_right").rotation = rotTrack[9]
	
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
	#$Node2D/Skeleton2D/hip.scale = Vector2(avgSizeMult,avgSizeMult)
	
	#if hipNeckPos != Vector2.ZERO:
		#print(0.45*hipNeckPos)
		#$Node2D/Skeleton2D/hip.psosition = Vector2(0.45,0.45)*hipNeckPos + Vector2(-425,15) #- Vector2(120,25)
		

func _input(event):
	const SCROLL_SPEED = 36 
	#685
	#1021

	#1360
	#1020

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: 
			if $Camera2D.position.y >= 300:
				$Camera2D.position.y -= SCROLL_SPEED
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: 
			if $Camera2D.position.y <= 1480:
				$Camera2D.position.y += SCROLL_SPEED

func _updateThumbnail(value: int, left : bool) -> void:
	if left:
		var tempDecimal: int = floor(log(value)/ log(10))
		$VideoTuning/Panel/TextureRect.texture = loadImage(file_path_left + "images/", file_name_left, value, tempDecimal)
	else:
		var tempDecimalRight: int = floor(log(value)/ log(10))
		$VideoTuning/Panel4/TextureRect.texture = loadImage(file_path_right + "images/", file_name_right, value, tempDecimalRight, false)

func _on_StT_h_slider_value_changed(value: float) -> void:
	fileNum = floor(value * fileMaxLeft / 100)
	if fileNum < 10:
		decimal = 0
	else:
		decimal = floor(log(fileNum)/ log(10))
	curFileLeft = fileNum
	_updateThumbnail(fileNum, true)


func _on_EtT_h_slider_value_changed(value: float) -> void:
	endFileLeft = floor(value * fileMaxLeft / 100)
	curFileLeft = endFileLeft
	_updateThumbnail(endFileLeft, true)


func _on_RT_h_slider_value_changed(value: float) -> void:
	leftRotation = int(value)
	_updateThumbnail(curFileLeft, true)


func _on_StS_h_slider_value_changed(value: float) -> void:
	fileNumRight = floor(value * fileMaxRight / 100)
	if fileNumRight < 10:
		decimalRight = 0
	else:
		decimalRight = floor(log(fileNumRight)/ log(10))
	curFileRight = fileNumRight
	_updateThumbnail(fileNumRight, false)


func _on_EtS_h_slider_value_changed(value: float) -> void:
	endFileRight = floor(value * fileMaxRight / 100)
	curFileRight = endFileRight
	_updateThumbnail(endFileRight, false)


func _on_RS_h_slider_value_changed(value: float) -> void:
	rightRotation = int(value)
	_updateThumbnail(curFileRight, false)


func _on_Teacher_Select_button_down() -> void:
	$StartMenu/FileDialog.popup_file_dialog()
	teacherSelection = true


func _on_Student_Select_button_down() -> void:
	teacherSelection = false
	$StartMenu/FileDialog.popup_file_dialog()


func _on_Continue_1_button_down() -> void:
	menu_state = 1
	$StartMenu.visible = false
	$Loading.visible = true
	$LoadTimer.start()


func _on_Continue_2_button_down() -> void:
	menu_state = 3
	$VideoTuning.visible = false
	$UI.visible = true
	$Timer.start()

func _on_load_timer_timeout() -> void:
	menu_state = 2
	$Loading.visible = false
	$VideoTuning.visible = true
	_on_StT_h_slider_value_changed(1)
	_on_StS_h_slider_value_changed(1)

func _on_file_dialog_file_selected(path: String) -> void:
	if teacherSelection:
		#file_name_left = $StartMenu/FileDialog.current_file 
		#$StartMenu/Panel/TextureRect.texture = $StartMenu/FileDialog.file_thumbnail
		var tempName = $StartMenu/FileDialog.current_file
		var periodPos = tempName.rfind(".")
		if periodPos == -1:
			file_name_left = tempName
			file_path_left = tempName
		else:
			file_name_left = tempName.substr(0, periodPos)
			file_path_left = tempName
		$StartMenu/Panel/Label.text = "Currently Selected File:\n" + tempName
	else:
		#file_name_right = $StartMenu/FileDialog.current_file 
		#$StartMenu/Panel4/TextureRect.texture = $StartMenu/FileDialog.file_thumbnail
		var tempName = $StartMenu/FileDialog.current_file
		var periodPos = tempName.rfind(".")
		if periodPos == -1:
			file_name_right = tempName
			file_path_right = tempName
		else:
			file_name_right = tempName.substr(0, periodPos)
			file_path_right = tempName
		$StartMenu/Panel4/Label.text = "Currently Selected File:\n" + tempName
		
func _calcTimeStr(time : int) -> String:
	time /= 30
	var tempHour = floor(time / 60)
	var tempMin = floor(time % 60)
	var hourBuffer = ""
	var minBuffer = ""
	if tempHour <= 9:
		hourBuffer = "0"
	if tempMin <= 9:
		minBuffer = "0"
	return hourBuffer + str(tempHour) + ":" + minBuffer + str(tempMin)
	

func _on_speed_slider_value_changed(value: float) -> void:
	slowness = 10 - int(value)


func _on_pause_play_2_button_down() -> void:
	accuracyScore = 0

func _matchColor(percent : float) -> Color:
	if percent >= 0.9:
		return Color("00cc41ff")
	elif percent >= 0.8:
		return Color("a2ff70ff")
	elif percent >= 0.7:
		return Color("e5ff70ff")
	elif percent >= 0.6:
		return Color("ff8d70ff")
	else:
		return Color("ff5024ff")

func _arrowPos(percent : float) -> int:
	if percent >= 0.9:
		return 200 - 1000*(1-percent)
	elif percent >= 0.8:
		return 50 - 1000*(0.9-percent)
	elif percent >= 0.7:
		return -49 - 1000*(0.8-percent)
	elif percent >= 0.6:
		return -150 - 1000*(0.7-percent)
	else:
		return -327
