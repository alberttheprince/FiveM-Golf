--# Written by Alberto but based on koil-golf !


-- Is Golf open by manager ?
isGolfOpen = true

-- Add icon on map
addblipGC()

-- a player game is running ?
isGameRunning = false

-- starting hole
golfHole = 1

-- to store player balf entity
mygolfball = nil

-- golf club to use 0 for putter, 1 iron, 2 wedge, 3 driver.
golfclub = 1

clubname = "None"

power = 0.1

-- is ball in hole 
isBallInHole = false

-- is ball moving
isBallMoving = false

-- do players play? Who watches the watchmen? link to ball / free to roam 
isPlaying = false

-- does player want to drop
doingdrop = false

golfstrokes = 0
totalgolfstrokes = 0

-- -- golfstate, 2 on ball ready to swing, 1 free roam
-- golfstate = 1

-- holes data
holes = {
	[1] = { ["par"] = 5, ["x"] = -1371.3370361328, ["y"] = 173.09497070313, ["z"] = 57.013027191162, ["x2"] = -1114.2274169922, ["y2"] = 220.8424987793, ["z2"] = 63.8947830200},
	[2] = { ["par"] = 4, ["x"] = -1107.1888427734, ["y"] = 156.581298828, ["z"] = 62.03958129882, ["x2"] = -1322.0944824219, ["y2"] = 158.8779296875, ["z2"] = 56.80027008056},
	[3] = { ["par"] = 3, ["x"] = -1312.1020507813, ["y"] = 125.8329391479, ["z"] = 56.4341888427, ["x2"] = -1237.347412109, ["y2"] = 112.9838562011, ["z2"] = 56.20140075683},
	[4] = { ["par"] = 4, ["x"] = -1216.913208007, ["y"] = 106.9870910644, ["z"] = 57.03926086425, ["x2"] = -1096.6276855469, ["y2"] = 7.780227184295, ["z2"] = 49.73574447631},
	[5] = { ["par"] = 4, ["x"] = -1097.859619140, ["y"] = 66.41466522216, ["z"] = 52.92545700073, ["x2"] = -957.4982910156, ["y2"] = -90.37551879882, ["z2"] = 39.2753639221},
	[6] = { ["par"] = 3, ["x"] = -987.7417602539, ["y"] = -105.0764007568, ["z"] = 39.585887908936, ["x2"] = -1103.506958007, ["y2"] = -115.2364349365, ["z2"] = 40.55868911743},
	[7] = { ["par"] = 4, ["x"] = -1117.0194091797, ["y"] = -103.8586044311, ["z"] = 40.8405838012, ["x2"] = -1290.536499023, ["y2"] = 2.7952194213867, ["z2"] = 49.34057998657},
	[8] = { ["par"] = 5, ["x"] = -1272.251831054, ["y"] = 38.04283142089, ["z"] = 48.72544860839, ["x2"] = -1034.80187988, ["y2"] = -83.16706085205, ["z2"] = 43.0353431701},
	[9] = { ["par"] = 4, ["x"] = -1138.319580078, ["y"] = -0.1342505216598, ["z"] = 47.98218917846, ["x2"] = -1294.685913085, ["y2"] = 83.5762557983, ["z2"] = 53.92817306518}
}


-- Ressource main loop
CreateThread(function()

	while true do
		-- Refresh tick
		Wait(5)

		if isGolfOpen then 
			-- DEBUG: Ressource running
			----citizen.trace("Ressource is running".."\n")

			-- Marker on ground near hold number 1 to start/stop game
			DrawMarker(27,-1369.32, 167.24, 57.31, 0, 0, 0, 0, 0, 0, 1.5, 1.5, 10.3, 0, 519, 0, 105, 5.5, 0, 2, 1, 0, 0, 0) 

			-- Player position
			local playerLoc = GetEntityCoords(GetPlayerPed(-1))

			-- Distance betwyn player and marker 
			local distanceFromMarker = GetDistanceBetweenCoords(-1369.51, 167.4, 58.01, playerLoc.x,playerLoc.y,playerLoc.z, false)

			-- If player going more than 500 from mark and game runing we stop it
			if distanceFromMarker > 500 and isGameRunning then
				endGame()
			end

			-- If player less than 1.5 from mark we ask and listen for start/stop game
			if distanceFromMarker < 1.5 then
			
				if isGameRunning then
					-- if game already running
					displayHelpText("Press ~g~~INPUT_CONTEXT~~s~ to end your golf game.")
				else
					displayHelpText("Press ~g~~INPUT_CONTEXT~~s~ to start golfing!")
				end
				if IsControlJustReleased(1, 38) then
					if isGameRunning then
						--citizen.trace("End game".."\n")
						endGame()
					else
						--citizen.trace("Run new game".."\n")	
						isGameRunning = true
						newGame()
					end
				end
			end
		end -- (isGolfOpen)
	end
end)

function newGame()
	-- Game loop: partie en cours
	CreateThread(function()

		-- add start and end of the first hole as icons on map
		blipsStartEndCurrentHole()

		TriggerEvent("beginGolfHud")

		-- create the first ball
		createBall(holes[golfHole]["x"],holes[golfHole]["y"],holes[golfHole]["z"])

		while isGameRunning == true do
			-- Refresh tick
			Wait(100)
			----citizen.trace("Game is running".."\n")

			-- if ball is in current hole then we set up the next hole or endGame if current is 9
			if isBallInHole then
				if golfHole == 9 then
					--citizen.trace("Game is finish ball in last hole ! -> End game".."\n")
					endGame()
				else
					golfHole = golfHole + 1
					blipsStartEndCurrentHole()
					createBall(holes[golfHole]["x"],holes[golfHole]["y"],holes[golfHole]["z"])
					isBallInHole = false
				end
			else
				-- Continue to play actual hole
				if isPlaying then
					idleShot()
				else
					lookingForBall()
				end
			end
		end

		return
	end)
end

golfArea = PolyZone:Create({
  vector2(-1340.7989501953, 125.04475402832),
  vector2(-1342.5408935547, 142.90570068359),
  vector2(-1346.7891845703, 148.30410766602),
  vector2(-1358.3530273438, 147.7126159668),
  vector2(-1359.3299560547, 173.22514343262),
  vector2(-1361.2554931641, 186.72328186035),
  vector2(-1341.2399902344, 192.03338623047),
  vector2(-1257.6059570312, 198.9454498291),
  vector2(-1232.1319580078, 207.94815063477),
  vector2(-1220.5051269531, 212.04547119141),
  vector2(-1165.9887695312, 224.37823486328),
  vector2(-1141.7316894531, 231.72482299805),
  vector2(-1121.4205322266, 237.89305114746),
  vector2(-1111.814453125, 237.21472167969),
  vector2(-1104.8190917969, 224.671875),
  vector2(-1090.0133056641, 181.33894348145),
  vector2(-1069.1300048828, 143.39642333984),
  vector2(-998.81817626953, 29.568370819092),
  vector2(-974.93133544922, -9.6275100708008),
  vector2(-940.04583740234, -57.441383361816),
  vector2(-923.88690185547, -83.41340637207),
  vector2(-924.85229492188, -94.125183105469),
  vector2(-931.20184326172, -99.439292907715),
  vector2(-943.59545898438, -107.31571960449),
  vector2(-953.55932617188, -114.29402160645),
  vector2(-969.15112304688, -120.986328125),
  vector2(-993.65167236328, -128.79643249512),
  vector2(-1005.6416625977, -132.22966003418),
  vector2(-1021.0614624023, -132.50416564941),
  vector2(-1029.7065429688, -133.92350769043),
  vector2(-1043.037109375, -142.27110290527),
  vector2(-1062.0545654297, -148.04011535645),
  vector2(-1076.5524902344, -147.1325378418),
  vector2(-1095.5341796875, -137.80737304688),
  vector2(-1160.3674316406, -104.27989196777),
  vector2(-1212.0971679688, -75.49568939209),
  vector2(-1253.3757324219, -52.579933166504),
  vector2(-1280.6865234375, -40.263202667236),
  vector2(-1295.0959472656, -28.952693939209),
  vector2(-1302.4108886719, -17.745761871338),
  vector2(-1313.6827392578, 1.5130497217178),
  vector2(-1326.3939208984, 18.281391143799)
}, {
  name="golfArea",
  --minZ = 38.554801940918,
  --maxZ = 67.755218505859
})

etang1 = PolyZone:Create({
  vector2(-1134.4281005859, 128.00877380371),
  vector2(-1132.0672607422, 129.18437194824),
  vector2(-1129.4871826172, 130.28790283203),
  vector2(-1126.662109375, 128.81904602051),
  vector2(-1121.6307373047, 126.82503509521),
  vector2(-1118.1671142578, 128.34255981445),
  vector2(-1113.091796875, 130.9047088623),
  vector2(-1107.564453125, 133.98193359375),
  vector2(-1103.7365722656, 136.53012084961),
  vector2(-1101.5626220703, 136.35597229004),
  vector2(-1098.8894042969, 138.79592895508),
  vector2(-1095.6279296875, 139.24281311035),
  vector2(-1093.5583496094, 137.46542358398),
  vector2(-1089.3717041016, 138.79299926758),
  vector2(-1086.9147949219, 139.03764343262),
  vector2(-1084.6042480469, 139.61727905273),
  vector2(-1081.2492675781, 135.89506530762),
  vector2(-1079.2491455078, 135.27127075195),
  vector2(-1077.2933349609, 132.19932556152),
  vector2(-1079.2985839844, 130.39083862305),
  vector2(-1081.8815917969, 130.55606079102),
  vector2(-1085.3358154297, 126.3839263916),
  vector2(-1086.853515625, 124.49081420898),
  vector2(-1088.3382568359, 122.53498840332),
  vector2(-1089.6600341797, 117.45861053467),
  vector2(-1091.1861572266, 110.32335662842),
  vector2(-1088.2283935547, 107.5378112793),
  vector2(-1084.1256103516, 105.68126678467),
  vector2(-1082.3533935547, 100.60806274414),
  vector2(-1084.4224853516, 98.759078979492),
  vector2(-1085.7900390625, 99.461280822754),
  vector2(-1091.8032226562, 94.265007019043),
  vector2(-1093.8503417969, 95.594360351562),
  vector2(-1099.2982177734, 95.145477294922),
  vector2(-1101.0875244141, 98.559143066406),
  vector2(-1104.4921875, 97.077644348145),
  vector2(-1108.2651367188, 102.88613891602),
  vector2(-1115.9671630859, 102.5909576416),
  vector2(-1118.2326660156, 104.42613220215),
  vector2(-1120.5920410156, 104.8443069458),
  vector2(-1121.1451416016, 107.97873687744),
  vector2(-1125.9927978516, 110.62202453613),
  vector2(-1126.5711669922, 112.87406921387),
  vector2(-1129.2536621094, 114.30466461182),
  vector2(-1130.6369628906, 114.57358551025),
  vector2(-1134.5255126953, 113.14373779297),
  vector2(-1136.5792236328, 114.86979675293),
  vector2(-1138.6878662109, 117.15356445312),
  vector2(-1136.2521972656, 123.37474060059),
  vector2(-1136.8511962891, 127.06150054932),
  vector2(-1134.0529785156, 127.12812805176)
}, {
  name="etang1",
  --minZ = 57.961555480957,
  --maxZ = 59.931709289551
})

etang2 = PolyZone:Create({
  vector2(-1088.4818115234, 41.795265197754),
  vector2(-1078.5300292969, 42.965980529785),
  vector2(-1075.2073974609, 46.150661468506),
  vector2(-1070.5321044922, 43.826248168945),
  vector2(-1066.9249267578, 44.772144317627),
  vector2(-1058.4613037109, 43.476718902588),
  vector2(-1047.1806640625, 41.016578674316),
  vector2(-1039.8121337891, 45.874225616455),
  vector2(-1036.8669433594, 48.553405761719),
  vector2(-1030.2073974609, 47.187438964844),
  vector2(-1030.1745605469, 44.165035247803),
  vector2(-1025.5526123047, 37.764610290527),
  vector2(-1028.9963378906, 31.91198348999),
  vector2(-1033.3443603516, 33.152339935303),
  vector2(-1037.0438232422, 29.397964477539),
  vector2(-1037.3243408203, 26.630142211914),
  vector2(-1041.5235595703, 23.404758453369),
  vector2(-1040.6878662109, 20.769901275635),
  vector2(-1045.919921875, 15.49206829071),
  vector2(-1052.8859863281, 13.299273490906),
  vector2(-1056.5681152344, 4.1643619537354),
  vector2(-1060.3422851562, 4.0571284294128),
  vector2(-1061.2401123047, -0.53958123922348),
  vector2(-1066.0467529297, -2.2324686050415),
  vector2(-1067.9759521484, -4.8585305213928),
  vector2(-1075.7478027344, -1.5850523710251),
  vector2(-1079.1309814453, -4.0679569244385),
  vector2(-1080.2043457031, -5.9496817588806),
  vector2(-1083.1920166016, -14.085180282593),
  vector2(-1085.6109619141, -14.978125572205),
  vector2(-1087.4467773438, -18.027896881104),
  vector2(-1088.2353515625, -19.69056892395),
  vector2(-1091.4189453125, -21.516218185425),
  vector2(-1094.5286865234, -19.754083633423),
  vector2(-1097.9770507812, -20.183317184448),
  vector2(-1103.2139892578, -13.334311485291),
  vector2(-1102.7376708984, -10.723866462708),
  vector2(-1097.4294433594, -5.7387466430664),
  vector2(-1088.8294677734, -4.6842436790466),
  vector2(-1076.3458251953, 8.7851123809814),
  vector2(-1074.6862792969, 13.016589164734),
  vector2(-1081.1558837891, 23.260408401489),
  vector2(-1083.5269775391, 27.419729232788),
  vector2(-1087.5012207031, 28.808660507202),
  vector2(-1095.7131347656, 30.862897872925),
  vector2(-1093.8795166016, 35.945724487305)
}, {
  name="etang2",
  --minZ = 49.457775115967,
  --maxZ = 50.787307739258
})

etang3 = PolyZone:Create({
  vector2(-1173.1820068359, -48.157444000244),
  vector2(-1172.3804931641, -54.680221557617),
  vector2(-1170.6058349609, -58.35718536377),
  vector2(-1166.1499023438, -61.570560455322),
  vector2(-1166.4907226562, -72.045204162598),
  vector2(-1171.9370117188, -77.781532287598),
  vector2(-1176.0206298828, -78.717041015625),
  vector2(-1180.9291992188, -75.672073364258),
  vector2(-1181.9155273438, -72.392379760742),
  vector2(-1183.9104003906, -69.689186096191),
  vector2(-1185.8588867188, -66.180084228516),
  vector2(-1185.3842773438, -62.21496963501),
  vector2(-1186.7886962891, -59.990081787109),
  vector2(-1191.4251708984, -61.82649230957),
  vector2(-1194.6578369141, -58.379070281982),
  vector2(-1197.3286132812, -56.337677001953),
  vector2(-1200.953125, -53.705654144287),
  vector2(-1203.3422851562, -52.325729370117),
  vector2(-1203.7781982422, -49.715316772461),
  vector2(-1205.5632324219, -47.617198944092),
  vector2(-1207.3010253906, -46.256011962891),
  vector2(-1210.6898193359, -45.884754180908),
  vector2(-1213.4860839844, -42.192852020264),
  vector2(-1217.1348876953, -42.245464324951),
  vector2(-1218.3298339844, -40.044422149658),
  vector2(-1222.5437011719, -36.827556610107),
  vector2(-1225.2727050781, -33.115600585938),
  vector2(-1231.7586669922, -31.009090423584),
  vector2(-1235.6610107422, -30.567623138428),
  vector2(-1238.5727539062, -26.949226379395),
  vector2(-1241.4462890625, -23.373443603516),
  vector2(-1241.3037109375, -17.470520019531),
  vector2(-1243.8333740234, -14.204926490784),
  vector2(-1246.2634277344, -10.213208198547),
  vector2(-1249.5438232422, -6.2493605613708),
  vector2(-1256.2030029297, -4.4095454216003),
  vector2(-1257.9655761719, -2.246643781662),
  vector2(-1261.8233642578, -0.24623660743237),
  vector2(-1264.8671875, 1.7654958963394),
  vector2(-1266.2385253906, 5.4950428009033),
  vector2(-1267.7186279297, 9.0236196517944),
  vector2(-1268.09765625, 11.253690719604),
  vector2(-1265.5919189453, 13.782306671143),
  vector2(-1262.7059326172, 17.727558135986),
  vector2(-1257.8228759766, 16.932100296021),
  vector2(-1252.5437011719, 13.166374206543),
  vector2(-1247.1131591797, 8.0136518478394),
  vector2(-1248.6756591797, 0.80859100818634),
  vector2(-1245.9645996094, -3.9010694026947),
  vector2(-1243.0593261719, -5.027811050415),
  vector2(-1241.8575439453, -7.434398651123),
  vector2(-1239.8343505859, -9.5314922332764),
  vector2(-1236.5639648438, -11.073376655579),
  vector2(-1230.0311279297, -8.7359228134155),
  vector2(-1227.6887207031, -8.8415155410767),
  vector2(-1217.9870605469, -10.208189964294),
  vector2(-1216.7473144531, -14.336300849915),
  vector2(-1221.4904785156, -16.417213439941),
  vector2(-1221.912109375, -18.444915771484),
  vector2(-1220.1774902344, -22.796669006348),
  vector2(-1221.1325683594, -25.25625038147),
  vector2(-1221.787109375, -27.175374984741),
  vector2(-1221.4052734375, -29.732799530029),
  vector2(-1218.4735107422, -32.702796936035),
  vector2(-1214.9586181641, -34.274166107178),
  vector2(-1212.3409423828, -35.583869934082),
  vector2(-1208.6354980469, -34.755802154541),
  vector2(-1206.0975341797, -36.683197021484),
  vector2(-1202.904296875, -37.297466278076),
  vector2(-1197.8325195312, -36.173377990723),
  vector2(-1195.8072509766, -34.90417098999),
  vector2(-1193.7540283203, -35.685253143311),
  vector2(-1187.8071289062, -34.247905731201),
  vector2(-1185.5510253906, -33.169471740723),
  vector2(-1177.5880126953, -35.697582244873),
  vector2(-1176.498046875, -34.261936187744),
  vector2(-1172.7877197266, -35.197689056396),
  vector2(-1170.3687744141, -42.043739318848),
  vector2(-1170.0341796875, -44.0569190979)
}, {
  name="etang3",
  --minZ = 44.569702148438,
  --maxZ = 47.893482208252
})

-- event listerner pour lancer le menu
RegisterNetEvent('beginGolfHud')
AddEventHandler('beginGolfHud', function()
	startGolfHud()
	--citizen.trace("HUD started".."\n")
end)

function startGolfHud()
	while isGameRunning do
		Wait(0)
    -- x, y, width, height
		DrawRect(0.115,0.39,0.2,0.45,0,0,0,140) -- game info
		if golfhole ~= 0 then
			local distance = math.ceil(GetDistanceBetweenCoords(GetEntityCoords(mygolfball), holes[golfHole]["x2"],holes[golfHole]["y2"],holes[golfHole]["z2"], true))
			--drawGolfTxt(0.9193, 1.391, 1.0,1.0,0.4, "~s~" .. golfstrokes .. "~r~ - ~s~" .. totalgolfstrokes .. "~r~ - ~s~" .. clubname .. "~r~ - ~s~" .. distance .. " m", 255, 255, 255, 255)
			

      -- x,y ,width,height,scale, text, r,g,b,a
      	-- game help text
      drawGolfTxtFixed(0.025, 0.18, 1.0,1.0,0.4, "How to Play:", 255, 255, 255, 255)
			drawGolfTxtFixed(0.025, 0.22, 1.0,1.0,0.3, "Walk up to the ball to begin", 255, 255, 255, 255)
			drawGolfTxtFixed(0.025, 0.25, 1.0,1.0,0.3, "Use Y to change clubs", 255, 255, 255, 255)
			drawGolfTxtFixed(0.025, 0.28, 1.0,1.0,0.3, "Use A and D to rotate", 255, 255, 255, 255)
			drawGolfTxtFixed(0.025, 0.31, 1.0,1.0,0.3, "Hold E to gain power and release to strike", 255, 255, 255, 255)
			-- game info text
      drawGolfTxtFixed(0.025, 0.38, 1.0,1.0,0.4, "Game Info:", 255, 255, 255, 255)
			drawGolfTxtFixed(0.025, 0.42, 1.0,1.0,0.3, "Strokes current hole: " .. golfstrokes, 255, 255, 255, 255)
			drawGolfTxtFixed(0.025, 0.45, 1.0,1.0,0.3, "Distance between ball and hole: " .. distance .. " m", 255, 255, 255, 255)
			drawGolfTxtFixed(0.025, 0.48, 1.0,1.0,0.3, "Current hole: " .. golfHole, 255, 255, 255, 255)
			drawGolfTxtFixed(0.025, 0.51, 1.0,1.0,0.3, "Total strokes: " .. totalgolfstrokes, 255, 255, 255, 255)
			-- golf club text
			drawGolfTxtFixed(0.025, 0.56, 1.0,1.0,0.4, "Current club: " .. clubname, 255, 255, 255, 255)
		end
	end
end

function drawGolfTxt(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(2)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.025)
end


function drawGolfTxtFixed(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x,y)
end