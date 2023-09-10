games {'gta5'}

fx_version 'cerulean'

description 'A cleaned up version of Alberto Golf, which is an improved version Koil Golf, by PrinceAlbert.'
version '0.0.1'

client_script {
	'@PolyZone/client.lua',
	'tools.lua',
	'client.lua'
}

export {
	'trace',
	'endGame',
	'displayHelpText',
	'blipsStartEndCurrentHole',
	'createBall',
	'idleShot',
	'lookingForBall',
	'addBallBlip',
	'addblipGC'
}

server_scripts {}
