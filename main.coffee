settings = require "./kek.json"
irc = require "irc"
fs = require "fs"
_ = require "lodash"

bot =
	clients: []
	VERSION: "0.0.1"
	modules: {}
	commandPrefix: settings.commandPrefix
	publicPrefix: settings.publicPrefix
	privatePrefix: settings.privatePrefix
	commands:
		"pm": []
		"message": []

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
	for command in required.COMMANDS then do (command) ->
		command.method = bot.modules[module][command.method]
		command.when ?= _.keys(bot.commands)
		for messageType in command.when
			bot.commands[messageType] ?= []
			bot.commands[messageType].push command

for server in settings.servers
	client = new irc.Client server.url, server.username,
		channels: server.channels
		port: if (val = server.port)? then val else 6667
		autoRejoin: server.autoReconnect
		realName: server.realName

	bot.clients.push client

	client.on "error", -> bot.emit "error", data

	client.on "pm", (from, message) ->
		splitted = message[bot.commandPrefix.length + bot.privatePrefix.length..].split " "
		command = splitted[0]
		params = splitted[1..]

		for command in _.filter(bot.commands["pm"], (c) -> c.command.test(message)) then do (command) ->
			out = (s) -> client.notice from, s
			command.method bot, out, no, command, params, message

	client.on "message#", (from, to, message) ->
		isPublic = message.toLowerCase().substring(bot.commandPrefix.length, bot.privatePrefix.length) isnt bot.privatePrefix
		splitted = if isPublic then message[bot.commandPrefix.length + bot.publicPrefix.length..].split(" ") else message[bot.commandPrefix.length + bot.privatePrefix.length..].split(" ")
		command = splitted[0]
		params = splitted[1..]

		for command in _.filter(bot.commands["message"], (c) -> c.command.test(message)) then do (command) ->
			out = (s) -> if isPublic then client.say(to, s) else client.notice(from, s)
			command.method bot, out, isPublic, command, params, message

	for customCommand in _.filter(_.keys(bot.commands), (s) -> s.toLowerCase().indexOf("message#") is 0)
		client.on customCommand, (from, to, message) ->
			return unless message.toLowerCase().indexOf(bot.commandPrefix + bot.publicPrefix) is 0 or message.toLowerCase().indexOf(bot.commandPrefix + bot.privatePrefix) is 0
			isPublic = message.toLowerCase().indexOf(bot.commandPrefix + bot.publicPrefix) is 0
			splitted = if isPublic then message[bot.commandPrefix.length + bot.publicPrefix.length..].split(" ") else message[bot.commandPrefix.length + bot.privatePrefix.length..].split(" ")
			command = splitted[0]
			params = splitted[1..]

			for command in _.filter(bot.commands[customCommand], (c) -> c.command.test(message)) then do (command) ->
				out = (s) -> if isPublic then client.say(to, s) else client.notice(from, s)
				command.method bot, out, isPublic, command, params, message
