request = require 'request'

class redditMetaLinker
	@COMMANDS: [
		{
			rawCommand: /(^|\s)[\/\\]?r[\\\/][^\\\/\W]+/i
			when: null
			method: "link"
		}
	]

	link: (bot, out, isPublic, from, to, command, params, message) ->
		query = /(^|\s)[\/\\]?r[\\\/][^\\\/\W]+/i.exec(message)[0].trim()
		if query[0] is "/" then query = query[1..]
		request "http://www.reddit.com/#{query}/about.json", (req, data, res) ->
			parsed = JSON.parse data.body
			return if parsed.error? or parsed.kind is "Listing"
			data = parsed.data

			s = ""
			s += if data.over18 then "\x0304NSFW \x03" else ""
			s += "#{data.display_name}: http://www.reddit.com#{data.url}"

			out s

module.exports = redditMetaLinker