settings = require "./kek.json"
storage = require "node-persist"
irc = require "irc"
_ = require "lodash"

storage.initSync()

process.on "uncaughtException", (e) -> console.log "-- Unresolved Error: #{e.message} --"

bot =
	_settings: settings

	clients: []
	VERSION: "0.0.2"
	modules: {}
	commandPrefix: settings.commandPrefix ? ""
	publicPrefix: settings.publicPrefix ? ""
	privatePrefix: settings.privatePrefix ? ""
	commands:
		"pm": []
		"message": []

	store: (key, value) ->
		key = "kek_#{key}"

		if arguments.length is 2 then storage.setItem key, value
		return storage.getItem key

	_callbacks: {}
	emit: (type, params...) ->
		@_callbacks[type] ?= []
		callback(params...) for callback in @_callbacks[type]
	on: (type, callback) ->
		@_callbacks[type] ?= []
		@_callbacks[type].push callback

for module in settings.modules
	required = new require module
	bot.modules[module] = new required bot
	process.on 'exit', (code) -> required.destruct? code
	for command in required.COMMANDS then do (command) ->
		command.method = bot.modules[module][command.method]
		command.moduleName = module
		command.when ?= _.keys(bot.commands)
		for messageType in command.when
			messageType = "message" if messageType is "public"
			bot.commands[messageType] ?= []
			bot.commands[messageType].push command

for server in settings.servers
	client = new irc.Client server.url, server.username,
		channels: server.channels
		port: if (val = server.port)? then val else 6667
		autoRejoin: server.autoReconnect
		realName: server.realName

	bot.clients.push _.extend client, serverInfo: server

	client.on "error", (data) -> bot.emit "error", data

	client.on "pm", (from, message, raw) ->
		splitted = message.split " "
		givenCommand = splitted[0]
		params = splitted[1..]

		for command in _.filter(bot.commands["pm"], (c) -> c.command?.test?(message) or c.rawCommand?.test?(message)) then do (command) ->
			out = (s) -> client.notice from, s
			try
				command.method _.extend(bot, currentClient: client), out, no, from, server.username, givenCommand, params, message
			catch e
				out "-- Module #{command.moduleName} crashed: #{e.message} --"
				console.log e.message
				console.log e.stack

	client.on "message#", (from, to, message, raw) ->
		isPublic = message.toLowerCase().substring(bot.commandPrefix.length, bot.commandPrefix.length + bot.privatePrefix.length) isnt bot.privatePrefix
		prefixLength = if isPublic then (bot.commandPrefix.length + bot.publicPrefix.length) else (bot.commandPrefix.length + bot.privatePrefix.length)
		splitted = message[prefixLength..].split " "
		givenCommand = splitted[0]
		params = splitted[1..]

		for command in _.filter(bot.commands["message"], (c) -> c.command?.test?(message[prefixLength..]) or c.rawCommand?.test?(message)) then do (command) ->
			out = (s) -> if isPublic then client.say(to, s) else client.notice(from, s)
			try
				command.method _.extend(bot, currentClient: client), out, isPublic, from, to, givenCommand, params, message
			catch e
				out "-- Module #{command.moduleName} crashed: #{e.message} --"
				console.log e.message
				console.log e.stack

	for customCommand in _.filter(_.keys(bot.commands), (s) -> s.toLowerCase().indexOf("message#") is 0)
		client.on customCommand, (from, to, message, raw) ->
			isPublic = message.toLowerCase().substring(bot.commandPrefix.length, bot.commandPrefix.length + bot.privatePrefix.length) isnt bot.privatePrefix
			prefixLength = if isPublic then (bot.commandPrefix.length + bot.publicPrefix.length) else (bot.commandPrefix.length + bot.privatePrefix.length)
			splitted = message[prefixLength..].split " "
			givenCommand = splitted[0]
			params = splitted[1..]

			for command in _.filter(bot.commands[customCommand], (c) -> c.command?.test?(message[prefixLength..]) or c.rawCommand?.test?(message)) then do (command) ->
				out = (s) -> if isPublic then client.say(to, s) else client.notice(from, s)
				try
					command.method _.extend(bot, currentClient: client), out, isPublic, from, to, givenCommand, params, message
				catch e
					out "-- Module #{command.moduleName} crashed: #{e.message} --"
					console.log e.message
					console.log e.stack