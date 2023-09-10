
function trace(str)
	--Citizen.Trace(str.."\n")
end

function addblipGC()
	gcblip = AddBlipForCoord(-1360.336,160.0437,57.4211)
	SetBlipAsFriendly(gcblip, true)
	SetBlipSprite(gcblip, 109)
	if isGolfOpen then		
		SetBlipColour(gcblip, 2)
	else
		SetBlipColour(gcblip, 3)
	end
	SetBlipAsShortRange(gcblip,true)
	BeginTextCommandSetBlipName("STRING");
	AddTextComponentString(tostring("Los Santos Golf Club"))
	EndTextCommandSetBlipName(gcblip)
end

function endGame()

	isGameRunning = false
	golfHole = 1
	DeleteObject(mygolfball)
	mygolfball = nil
	golfclub = 1
	clubname = "None"
	power = 0.1
	isBallInHole = false
	isBallMoving = false
	isPlaying = false
	doingdrop = false
	golfstrokes = 0
	totalgolfstrokes = 0
	TriggerEvent('destroyProp')

	_removeStartEndCurrentHole()
	_removeBallBlip()
	--Citizen.Trace("Golf game ended.".."\n")
end

function displayHelpText(str)
    SetTextComponentFormat("STRING")
    AddTextComponentString(str)
    DisplayHelpTextFromStringLabel(0, 0, 0, -1)
end

function blipsStartEndCurrentHole()
	--Citizen.Trace("BlipsStartEnd".."\n")
	if startblip ~= nil then
		--Citizen.Trace("BlipsStartEnd - RemoveBlip".."\n")
		RemoveBlip(startblip)
		RemoveBlip(endblip)
	end
	startblip = AddBlipForCoord(holes[golfHole]["x"],holes[golfHole]["y"],holes[golfHole]["z"])
	SetBlipAsFriendly(startblip, true)
	SetBlipSprite(startblip, 379)
	BeginTextCommandSetBlipName("STRING");
	AddTextComponentString(tostring("Start of Hole"))
	EndTextCommandSetBlipName(startblip)
	endblip = AddBlipForCoord(holes[golfHole]["x2"],holes[golfHole]["y2"],holes[golfHole]["z2"])
	SetBlipAsFriendly(endblip, true)
	SetBlipSprite(endblip, 358)
	BeginTextCommandSetBlipName("STRING");
	AddTextComponentString(tostring("End of Hole"))
	EndTextCommandSetBlipName(endblip)
end

function _removeStartEndCurrentHole()
	if startblip ~= nil then
		--Citizen.Trace("BlipsStartEnd - RemoveBlip".."\n")
		RemoveBlip(startblip)
		RemoveBlip(endblip)
	end
end

function _removeBallBlip()
	if ballBlip ~= nil then
		RemoveBlip(ballBlip)
	end
end

function createBall(x,y,z)
	
	--Citizen.Trace("Creating Ball".."\n")

	if ballBlip ~= nil then
		RemoveBlip(ballBlip)
	end

	DeleteObject(mygolfball)
	mygolfball = CreateObject(GetHashKey("prop_golf_ball"), x, y, z, true, true, false)

	SetEntityRecordsCollisions(mygolfball,true)
	SetEntityCollision(mygolfball, true, true)
	SetEntityHasGravity(mygolfball, true)
	FreezeEntityPosition(mygolfball, true)
	local curHeading = GetEntityHeading(GetPlayerPed(-1))
	SetEntityHeading(mygolfball, curHeading)
	
	addBallBlip()
end

function addBallBlip()
	ballBlip = AddBlipForEntity(mygolfball)
	SetBlipAsFriendly(ballBlip, true)
	SetBlipSprite(ballBlip, 1)
	BeginTextCommandSetBlipName("STRING");
	AddTextComponentString(tostring("Golf ball position"))
	EndTextCommandSetBlipName(ballBlip)
end

function idleShot()
	--Citizen.Trace("Idle Shot Enabled".."\n")
	power = 0.1
	--Citizen.Trace("POWER debut idleshot :"..power.."\n")
	--Citizen.Trace("mygolfball debut idleshot :"..mygolfball.."\n")

	local distance = GetDistanceBetweenCoords(GetEntityCoords(mygolfball), holes[golfHole]["x2"],holes[golfHole]["y2"],holes[golfHole]["z2"], true)
	if distance >= 200.0 then
		golfclub = 3 -- wood 200m-250m
	elseif distance >= 150.0 and distance < 200.0 then
		golfclub = 1 -- iron 1 140m-180m
	elseif distance >= 120.0 and distance < 250.0 then
		golfclub = 4 -- iron 3 -- 120m-150m
	elseif distance >= 90.0 and distance < 120.0 then
		golfclub = 5 -- -- iron 5 -- 70m-120m
	elseif distance >= 50.0 and distance < 90.0 then
		golfclub = 6 -- iron 7 -- 50m-100m
	elseif distance >= 20.0 and distance < 50.0 then
		golfclub = 2 --  wedge 50m-80m
	else
		golfclub = 0 -- else putter
	end

	_attachClub()
	RequestScriptAudioBank("GOLF_I", 0)

	while isPlaying do

		Wait(0)

		if (IsControlPressed(1, 38)) then
			addition = 0.5

			if power > 25 then
				addition = addition + 0.1
			end
			if power > 50 then
				addition = addition + 0.2
			end
			if power > 75 then
				addition = addition + 0.3
			end
			power = power + addition
			if power > 100.0 then
				power = 1.0
			end
		end



		local box = (power * 2) / 1000

		DrawRect(0.5,0.97,0.2,0.04,0,0,0,140)-- header
		if power > 90 then
			DrawRect(0.5,0.97,box,0.02,255,22,22,210) -- jauge
		else
			DrawRect(0.5,0.97,box,0.02,22,235,22,210) -- jauge
		end

		--DrawRect(x, y, width, height, r, g, b, a)

		local offsetball = GetOffsetFromEntityInWorldCoords(mygolfball, (power) - (power*2), 0.0, 0.0)

		DrawLine(GetEntityCoords(mygolfball), holes[golfHole]["x2"],holes[golfHole]["y2"],holes[golfHole]["z2"], 222, 111, 111, 0.2)

		DrawMarker(27,holes[golfHole]["x2"],holes[golfHole]["y2"],holes[golfHole]["z2"], 0, 0, 0, 0, 0, 0, 0.5, 0.5, 10.3, 212, 189, 0, 105, 0, 0, 2, 0, 0, 0, 0)

		--

		if (IsControlJustPressed(1, 246)) then
			local newclub = golfclub+1
			--Citizen.Trace(golfclub.."\n")
			if newclub > 6 then
				newclub = 0
			end
			--Citizen.Trace(golfclub .. " | " .. newclub.."\n")
			golfclub = newclub
			--Citizen.Trace(golfclub.."\n")
			_attachClub()
		end

		if (IsControlPressed(1, 34)) then
			_rotateShot(true)
		end
		if (IsControlPressed(1, 9)) then
			_rotateShot(false)
		end

		if golfclub == 0 then
			AttachEntityToEntity(GetPlayerPed(-1), mygolfball, 20, 0.14, -0.62, 0.99, 0.0, 0.0, 0.0, false, false, false, false, 1, true)
		elseif golfclub == 3 then
			AttachEntityToEntity(GetPlayerPed(-1), mygolfball, 20, 0.3, -0.92, 0.99, 0.0, 0.0, 0.0, false, false, false, false, 1, true)
		elseif golfclub == 2 then
			AttachEntityToEntity(GetPlayerPed(-1), mygolfball, 20, 0.38, -0.79, 0.94, 0.0, 0.0, 0.0, false, false, false, false, 1, true)
		else
			AttachEntityToEntity(GetPlayerPed(-1), mygolfball, 20, 0.4, -0.83, 0.94, 0.0, 0.0, 0.0, false, false, false, false, 1, true)
		end
		if (IsControlJustReleased(1, 38)) then
			if golfclub == 0 then
				playAnim = puttSwing["puttswinglow"]
			else
				playAnim = ironSwing["ironswinghigh"]
				playGolfAnim(playAnim)
				playAnim = ironSwing["ironswinglow"]
				playGolfAnim(playAnim)
				playAnim = ironSwing["ironswinglow"]
			end

			isPlaying = false
			inLoop = false
			DetachEntity(GetPlayerPed(-1), true, false)
		else
			if not inLoop then
				TriggerEvent("loopStart")
			end
		end
	end

	PlaySoundFromEntity(-1, "GOLF_SWING_FAIRWAY_IRON_LIGHT_MASTER", GetPlayerPed(-1), 0, 0, 0)

	playGolfAnim(playAnim)
	swing()

	Wait(3380)
	endShot()

	if isBallInGolf == false or isBallInEtang1 == true or isBallInEtang2 == true or isBallInEtang3 == true then
		displayHelpText("Your ball is off-limits or in water. Replacing ball with a 1 point penality.")
		x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
		createBall(x,y,z-1)
		golfstrokes = golfstrokes + 1
	end
end

function swing()
	--Citizen.Trace("Swing Enabled".."\n")

	--Citizen.Trace("POWER DEBUT SWING :"..power.."\n")
	if golfclub ~= 0 then
		ballCam()
	end
	if not HasNamedPtfxAssetLoaded("scr_minigamegolf") then
		RequestNamedPtfxAsset("scr_minigamegolf")
		while not HasNamedPtfxAssetLoaded("scr_minigamegolf") do
			Wait(0)
		end
	end
	SetPtfxAssetNextCall("scr_minigamegolf")
	StartParticleFxLoopedOnEntity("scr_golf_ball_trail", mygolfball, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)

	local enabledroll = false

	dir = GetEntityHeading(mygolfball)
	local x,y = quickmafs(dir)
	FreezeEntityPosition(mygolfball, false)
	local rollpower = power / 3

	if golfclub == 0 then -- putter
		power = power / 3
		local check = 5.0
		while check < power do
			SetEntityVelocity(mygolfball, x*check,y*check,-0.1)
			Wait(20)
			check = check + 0.3
		end

		power = power
		while power > 0 do
			SetEntityVelocity(mygolfball, x*power,y*power,-0.1)
			Wait(20)
			power = power - 0.3
		end

	elseif golfclub == 1 then -- iron 1 140m-180m
		power = power * 1.85
		airpower = power / 2.6
		enabledroll = true
		rollpower = rollpower / 4
	elseif golfclub == 3 then -- wood 200m-250m
		power = power * 2.0
		airpower = power / 2.6
		enabledroll = true
		rollpower = rollpower / 2
	elseif golfclub == 2 then -- wedge -- 50m-80m
		power = power * 1.5
		airpower = power / 2.1
		enabledroll = true
		rollpower = rollpower / 4.5
	elseif golfclub == 4 then -- iron 3 -- 110m-150m
		power = power * 1.8
		airpower = power / 2.55
		enabledroll = true
		rollpower = rollpower / 5
	elseif golfclub == 5 then -- iron 5 -- 70m-120m
		power = power * 1.75
		airpower = power / 2.5
		enabledroll = true
		rollpower = rollpower / 5.5
	elseif golfclub == 6 then -- iron 7 -- 50m-100m
		power = power * 1.7
		airpower = power / 2.45
		enabledroll = true
		rollpower = rollpower / 6.0
	end

	--Citizen.Trace("POWER APRES COEF :"..power.."\n")
	--Citizen.Trace("AIRPOWER :"..airpower.."\n")
	--Citizen.Trace("ROLLPOWER :"..rollpower.."\n")

	while power > 0 do
		SetEntityVelocity(mygolfball, x*power,y*power,airpower)
		Wait(0)
		power = power - 1
		airpower = airpower - 1
	end

	if enabledroll then
		while rollpower > 0 do
			SetEntityVelocity(mygolfball, x*rollpower,y*rollpower,0.0)
			Wait(5)
			rollpower = rollpower - 1
		end
	end

	Wait(2000)

	SetEntityVelocity(mygolfball,0.0,0.0,0.0)

	if golfclub ~= 0 then
		ballCamOff()
	end

	FreezeEntityPosition(mygolfball, true)
	local x,y,z = table.unpack(GetEntityCoords(mygolfball))
	createBall(x,y,z)
	--SetEntityCoords(GetPlayerPed(-1),GetEntityCoords(mygolfball))

	-- CHECKBALL POSITION
	local mygolfballCoord = GetEntityCoords(mygolfball)

	isBallInGolf = golfArea:isPointInside(mygolfballCoord)
	isBallInEtang1 = etang1:isPointInside(mygolfballCoord)
	isBallInEtang2 = etang2:isPointInside(mygolfballCoord)
	isBallInEtang3 = etang3:isPointInside(mygolfballCoord)
	if isBallInGolf and isBallInEtang1 == false and isBallInEtang2 == false and isBallInEtang3 == false then
		displayHelpText("Ball still in area of play and not in water.")
	else
		displayHelpText("Ball outside area of play or in water.")
	end

end

function endShot()
	--Citizen.Trace("Ending Shot".."\n")
	TriggerEvent("attachItem","golfbag01")
	inTask = false
	golfstrokes = golfstrokes + 1
	local ballLoc = GetEntityCoords(mygolfball)
	local distance = GetDistanceBetweenCoords(ballLoc.x,ballLoc.y,ballLoc.z, holes[golfHole]["x2"],holes[golfHole]["y2"],holes[golfHole]["z2"], true)

	if distance < 0.5 then
		TriggerEvent("customNotification","You got the ball within range!")
		totalgolfstrokes = golfstrokes + totalgolfstrokes
		golfstrokes = 0
		isBallInHole = true
	end

	--Citizen.Trace("Ball seemed to have landed on: " .. GetCollisionNormalOfLastHitForEntity(mygolfball) .."\n")
end

function dropShot()
	--Citizen.Trace("Droping Shot".."\n")
	doingdrop = true
	while doingdrop do

		Wait(0)
		local distance = GetDistanceBetweenCoords(GetEntityCoords(mygolfball), GetEntityCoords(GetPlayerPed(-1)), true)
		local distanceHole = GetDistanceBetweenCoords(holes[golfHole]["x2"],holes[golfHole]["y2"],holes[golfHole]["z2"], GetEntityCoords(GetPlayerPed(-1)), true)
		if distance < 50.0 and distanceHole > 50.0 then
			DisplayHelpText("Press ~g~E~s~ to drop here.")
			if ( IsControlJustReleased(1, 38) ) then
				doingdrop = false
				x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
				createBall(x,y,z-1)
				golfstrokes = golfstrokes + 1
			end
		else
			DisplayHelpText("Press ~g~E~s~ to drop - ~r~ too far from ball or to close to hole.")
		end
	end
end


function quickmafs(dir)
	local x = 0.0
	local y = 0.0
	local dir = dir
	if dir >= 0.0 and dir <= 90.0 then
		local factor = (dir/9.2) / 10
		x = -1.0 + factor
		y = 0.0 - factor
	end

	if dir > 90.0 and dir <= 180.0 then
		dirp = dir - 90.0
		local factor = (dirp/9.2) / 10
		x = 0.0 + factor
		y = -1.0 + factor
	end

	if dir > 180.0 and dir <= 270.0 then
		dirp = dir - 180.0
		local factor = (dirp/9.2) / 10
		x = 1.0 - factor
		y = 0.0 + factor
	end

	if dir > 270.0 and dir <= 360.0 then
		dirp = dir - 270.0
		local factor = (dirp/9.2) / 10
		x = 0.0 - factor
		y = 1.0 - factor
	end
	return x,y
end

function _attachClub()

	if golfclub == 3 then
		TriggerEvent("attachItem","golfdriver01")
		clubname = "Wood"
	elseif golfclub == 2 then
		TriggerEvent("attachItem","golfwedge01")
		clubname = "Wedge"
	elseif golfclub == 1 then
		TriggerEvent("attachItem","golfiron01")
		clubname = "1 Iron"
	elseif golfclub == 4 then
		TriggerEvent("attachItem","golfiron03")
		clubname = "3 Iron"
	elseif golfclub == 5 then
		TriggerEvent("attachItem","golfiron05")
		clubname = "5 Iron"
	elseif golfclub == 6 then
		TriggerEvent("attachItem","golfiron07")
		clubname = "7 Iron"
	else
		TriggerEvent("attachItem","golfputter01")
		clubname = "Putter"
	end
end

function _rotateShot(moveType)
	local curHeading = GetEntityHeading(mygolfball)
	if curHeading >= 360.0 then
		curHeading = 0.0
	end
	if moveType then
		SetEntityHeading(mygolfball, curHeading-0.7)
	else
		SetEntityHeading(mygolfball, curHeading+0.7)
	end
end

RegisterNetEvent('customNotification')
AddEventHandler('customNotification', function(response)
	TriggerEvent('chatMessage', 'GOLF: ', { 0, 11, 0 }, response)
end)

RegisterNetEvent('destroyProp')
AddEventHandler('destroyProp', function()
	removeAttachedProp()
end)

RegisterNetEvent('attachProp')
AddEventHandler('attachProp', function(attachModelSent,boneNumberSent,x,y,z,xR,yR,zR)
	removeAttachedProp()
	attachModel = GetHashKey(attachModelSent)
	boneNumber = boneNumberSent
	SetCurrentPedWeapon(GetPlayerPed(-1), 0xA2719263)
	local bone = GetPedBoneIndex(GetPlayerPed(-1), boneNumberSent)
	--local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
	RequestModel(attachModel)
	while not HasModelLoaded(attachModel) do
		Wait(100)
	end
	attachedProp = CreateObject(attachModel, 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(attachedProp, GetPlayerPed(-1), bone, x, y, z, xR, yR, zR, 1, 1, 0, 0, 2, 1)
end)

attachPropList = {

	["golfbag01"] = {
		["model"] = "prop_golf_bag_01", ["bone"] = 24816, ["x"] = 0.12,["y"] = -0.3,["z"] = 0.0,["xR"] = -75.0,["yR"] = 190.0, ["zR"] = 92.0
	},

	["golfputter01"] = {
		["model"] = "prop_golf_putter_01", ["bone"] = 57005, ["x"] = 0.0,["y"] = -0.05,["z"] = 0.0,["xR"] = 90.0,["yR"] = -118.0, ["zR"] = 44.0
	},

	["golfiron01"] = {
		["model"] = "prop_golf_iron_01", ["bone"] = 57005, ["x"] = 0.125,["y"] = 0.04,["z"] = 0.0,["xR"] = 90.0,["yR"] = -118.0, ["zR"] = 44.0
	},
	["golfiron03"] = {
		["model"] = "prop_golf_iron_01", ["bone"] = 57005, ["x"] = 0.126,["y"] = 0.041,["z"] = 0.0,["xR"] = 90.0,["yR"] = -118.0, ["zR"] = 44.0
	},
	["golfiron05"] = {
		["model"] = "prop_golf_iron_01", ["bone"] = 57005, ["x"] = 0.127,["y"] = 0.042,["z"] = 0.0,["xR"] = 90.0,["yR"] = -118.0, ["zR"] = 44.0
	},
	["golfiron07"] = {
		["model"] = "prop_golf_iron_01", ["bone"] = 57005, ["x"] = 0.128,["y"] = 0.043,["z"] = 0.0,["xR"] = 90.0,["yR"] = -118.0, ["zR"] = 44.0
	},
	["golfwedge01"] = {
		["model"] = "prop_golf_pitcher_01", ["bone"] = 57005, ["x"] = 0.17,["y"] = 0.04,["z"] = 0.0,["xR"] = 90.0,["yR"] = -118.0, ["zR"] = 44.0
	},

	["golfdriver01"] = {
		["model"] = "prop_golf_driver", ["bone"] = 57005, ["x"] = 0.14,["y"] = 0.00,["z"] = 0.0,["xR"] = 160.0,["yR"] = -60.0, ["zR"] = 10.0
	}

}

RegisterNetEvent('attachItem')
AddEventHandler('attachItem', function(item)
	TriggerEvent("attachProp",attachPropList[item]["model"], attachPropList[item]["bone"], attachPropList[item]["x"], attachPropList[item]["y"], attachPropList[item]["z"], attachPropList[item]["xR"], attachPropList[item]["yR"], attachPropList[item]["zR"])
end)

function playGolfAnim(anim)
	--ClearPedSecondaryTask(GetPlayerPed(-1))
	loadAnimDict( "mini@golf" )
	if IsEntityPlayingAnim(lPed, "mini@golf", anim, 3) then

	else
		length = GetAnimDuration("mini@golf", anim)
		TaskPlayAnim( GetPlayerPed(-1), "mini@golf", anim, 1.0, -1.0, length, 0, 1, 0, 0, 0)
		Wait(length)
	end
--	ClearPedSecondaryTask(GetPlayerPed(-1))
end

function playAudio(num)
	RequestScriptAudioBank("GOLF_I", 0)
	PlaySoundFromEntity(-1, sounds[num], GetPlayerPed(-1), 0, 0, 0)
end

sounds = {
	[1] = "GOLF_SWING_GRASS_LIGHT_MASTER",
	[2] = "GOLF_SWING_GRASS_PERFECT_MASTER",
	[3] = "GOLF_SWING_GRASS_MASTER",
	[4] = "GOLF_SWING_TEE_LIGHT_MASTER",
	[5] = "GOLF_SWING_TEE_PERFECT_MASTER",
	[6] = "GOLF_SWING_TEE_MASTER",
	[7] = "GOLF_SWING_TEE_IRON_LIGHT_MASTER",
	[8] = "GOLF_SWING_TEE_IRON_PERFECT_MASTER",
	[9] = "GOLF_SWING_TEE_IRON_MASTER",
	[10] = "GOLF_SWING_FAIRWAY_IRON_LIGHT_MASTER",
	[11] = "GOLF_SWING_FAIRWAY_IRON_PERFECT_MASTER",
	[12] = "GOLF_SWING_FAIRWAY_IRON_MASTER",
	[13] = "GOLF_SWING_ROUGH_IRON_LIGHT_MASTER",
	[14] = "GOLF_SWING_ROUGH_IRON_PERFECT_MASTER",
	[15] = "GOLF_SWING_ROUGH_IRON_MASTER",
	[16] = "GOLF_SWING_SAND_IRON_LIGHT_MASTER",
	[17] = "GOLF_SWING_SAND_IRON_PERFECT_MASTER",
	[18] = "GOLF_SWING_SAND_IRON_MASTER",
	[19] = "GOLF_SWING_CHIP_LIGHT_MASTER",
	[20] = "GOLF_SWING_CHIP_PERFECT_MASTER",
	[21] = "GOLF_SWING_CHIP_MASTER",
	[22] = "GOLF_SWING_CHIP_GRASS_LIGHT_MASTER",
	[23] = "GOLF_SWING_CHIP_GRASS_MASTER",
	[24] = "GOLF_SWING_CHIP_SAND_LIGHT_MASTER",
	[25] = "GOLF_SWING_CHIP_SAND_PERFECT_MASTER",
	[26] = "GOLF_SWING_CHIP_SAND_MASTER",
	[27] = "GOLF_SWING_PUTT_MASTER",
	[28] = "GOLF_FORWARD_SWING_HARD_MASTER",
	[29] = "GOLF_BACK_SWING_HARD_MASTER"
}

function lookingForBall()
	----Citizen.Trace("Looking for Ball".."\n")
	Wait(0)
	if GetVehiclePedIsIn(GetPlayerPed(-1), false) == 0 then
		local ballLoc = GetEntityCoords(mygolfball)
		local playerLoc = GetEntityCoords(GetPlayerPed(-1))
		local distance = GetDistanceBetweenCoords(ballLoc.x,ballLoc.y,ballLoc.z, playerLoc.x,playerLoc.y,playerLoc.z, true)
		-- if distance < 50.0 then
		-- 	DisplayHelpText("Move to your ball, press ~g~E~s~ to ball drop if you are stuck.")
		-- 	if ( IsControlJustReleased(1, 38) ) then
		-- 		dropShot()
		-- 	end
		-- end

		if (distance < 5.0) and not doingdrop then
			isPlaying = true
			--Citizen.Trace("Close to the Ball".."\n")
		end
	end
end

function removeAttachedProp()
	DeleteEntity(attachedProp)
	attachedProp = 0
	ClearPedTasks(PlayerPedId())
end

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Wait( 5 )
    end
end

function ballCam()
	ballcam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	--AttachCamToEntity(ballcam, mygolfball, -2.0,0.0,-2.0, false)
	SetCamFov(ballcam, 90.0)
	RenderScriptCams(true, true, 3, 1, 0)

	TriggerEvent("camFollowBall")
end

function ballCamOff()
	RenderScriptCams(false, false, 0, 1, 0)
	DestroyCam(ballcam, false)
end

RegisterNetEvent('camFollowBall')
AddEventHandler('camFollowBall', function()
	local timer = 20000
	while timer > 0 do
		Wait(5)
		x,y,z = table.unpack(GetEntityCoords(mygolfball))
		SetCamCoord(ballcam, x,y-10,z+9)
		PointCamAtEntity(ballcam, mygolfball, 0.0, 0.0, 0.0, true)
		timer = timer - 1
	end
end)

ironSwing = {
	["ironshufflehigh"] = "iron_shuffle_high",
	["ironshufflelow"] = "iron_shuffle_low",
	["ironshuffle"] = "iron_shuffle",
	["ironswinghigh"] = "iron_swing_action_high",
	["ironswinglow"] = "iron_swing_action_low",
	["ironidlehigh"] = "iron_swing_idle_high",
	["ironidlelow"] = "iron_swing_idle_low",
	["ironidle"] = "iron_shuffle",
	["ironswingintro"] = "iron_swing_intro_high"
}


puttSwing = {
	["puttshufflelow"] = "iron_shuffle_low",
	["puttshuffle"] = "iron_shuffle",
	["puttswinglow"] = "putt_action_low",
	["puttidle"] = "putt_idle_low",
	["puttintro"] = "putt_intro_low",
	["puttintro"] = "putt_outro"
}


RegisterNetEvent('loopStart')
AddEventHandler('loopStart', function()
	inLoop = true
	--Citizen.Trace("Idle Enabled".."\n")
	while inLoop do
		Wait(0)
		idleLoop()
	end
end)

function idleLoop()
	if golfclub == 0 then
		playAnim = puttSwing["puttidle"]
	else
		if (IsControlPressed(1, 38)) then
			playAnim = ironSwing["ironidlehigh"]
		else
			playAnim = ironSwing["ironidle"]
		end
	end
	playGolfAnim(playAnim)
	Wait(1200)
end
