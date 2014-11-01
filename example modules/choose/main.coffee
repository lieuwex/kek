_ = require "lodash"

class choose
	@COMMANDS: [
		{
			command: /^choose/ig
			when: null
			method: "choose"
			commandLength: 1
		}
	]

	choose: (bot, out, isPublic, from, to, command, params, message) ->
		return if params.length is 0 or (params.length is 1 and _.isEmpty(params[0].trim()))
		if message.indexOf(",") isnt -1 then params = message.split(" ")[1..].join(" ").split(",")
		choices = ( param.trim() for param in params )

		out "#{from}: " + choices[_.random 0, choices.length - 1]

module.exports = choose