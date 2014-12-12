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
		if /\b\d+-\d+/ig.test(message)
			numbers = message.split(" ")[1..].join(" ").split("-").map (x) -> (Number) x
			out "#{from}: " + _.random numbers[0], numbers[1]
		else
			choices = ( param.trim() for param in params )
			return if choices.length < 2

			out "#{from}: " + choices[_.random 0, choices.length - 1]

module.exports = choose