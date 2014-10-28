_ = require "lodash"

class choose
	@COMMANDS: [
		{
			command: /^choose/ig
			when: [ "public" ]
			method: "choose"
		}
	]

	choose: (bot, out, isPublic, from, to, command, params, message) ->
		[].push.apply params, params[0].split(",")
		choices = ( param.trim() for param in params )

		out "#{from}: " + choices[_.random 0, choices.length - 1]

module.exports = choose