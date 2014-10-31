express = require 'express'
_ = require "lodash"

app = express()

class web
	@COMMANDS: [
		{
			command: /^(broadcast|tellall) \S+/i
			when: null
			method: "broadcast"
		}
	]

	constructor: (bot) ->
		@tell = (server, channel, message) ->
			return unless message? and not _.isEmpty(message)
			if server? and channel?
				channel = "##{channel}" unless channel[0] is "#"

				client = _.find(bot.clients, (c) -> c.serverInfo.url is server.split(":")[0].trim())
				if client?
					client.say channel, message
				else throw new Error "nf"
			else
				for client in bot.clients
					for channel in client.serverInfo.channels
						client.say channel, "Broadcast: #{message}"

		app.get "/", (req, res) ->
			res.send JSON.stringify
				servers: ({ url: x.serverInfo.url, port: x.serverInfo.port, channels: x.serverInfo.channels, username: x.serverInfo.username } for x in bot.clients)
				modules: _.keys(bot.modules)

		app.post "/tell", (req, res) =>
			data = ""
			req.on "data", (blob) -> data += blob
			req.on "end", =>
				{ message, server, channel } = JSON.parse data
				unless message? and _.isString(message) and not _.isEmpty(message)
					res.status(403).json { error: "message cannot be null or empty string.", success: no }

				try
					@tell server, channel, message
					res.json { success: yes }
				catch e
					if e.message is "nf" then res.status(404).json { error: "Server with url #{server} not found.", success: no }
					else res.status(500).json { error: e.message, detailed: e, success: no }

		@server = app.listen 1337, -> console.log "Module web is loaded at port 1337."

	destruct: (code) -> server.close()

	broadcast: (bot, out, isPublic, from, to, command, params, message) =>
		_params = []
		singleParams = []
		inString = no
		for param in params
			inString = yes if _.contains [0, (param.length - 1)], param.indexOf('"')
			if param[0] is '"' then param = param[1..]
			else if param[param.length - 1] is '"' then param = param.substring 0, param.length - 1
			unless inString then singleParams.push param
			_params.push param
		if inString then singleParams.push "<msg>"
		params = _params

		server = channel = message = null
		if singleParams.length is 3
			server = params[0]
			channel = params[1]
			message = params[2..].join " "

		else if singleParams.length is 2
			server = bot.currentClient.serverInfo.url
			channel = params[0]
			message = params[1..].join " "

		else if singleParams.length is 1
			message = params.join " "

		@tell server, channel, message

module.exports = web