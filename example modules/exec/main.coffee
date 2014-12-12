_ = require "lodash"

class exec
	@COMMANDS: [
		{
			rawCommand: /^`.+`$/i
			when: null
			method: "exec"
		}
	]

	exec: (bot, out, isPublic, from, to, command, params, message, where) ->
		return unless from is "Lieuwex"
		out eval(message.substring(1, message.length - 1))

module.exports = exec