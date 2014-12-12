_ = require "lodash"

insults = [
	"STAHP"
	"Y U DO DIS"
	"I EHM'T UR MUM LAST NITE"
	"STFU"
]

class dwarfcraftInsulter
	@COMMANDS: [
		{
			rawCommand: /\b[ue]*h+m+/ig
			when: [ "public" ]
			method: "insult"
		}
	]

	insult: (bot, out, isPublic, from, to, command, params, message) ->
		return unless from.toLowerCase() is "dwarfcraft"
		out insults[_.random 0, insults.length - 1]

module.exports = dwarfcraftInsulter