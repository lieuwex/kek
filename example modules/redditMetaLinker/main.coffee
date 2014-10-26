request = require 'request'

class redditMetaLinker
	@COMMANDS: [
		{
			command: /(\/|\\)?r(\/|\\)[^\/\\\s]+/ig
			when: null
			method: "link"
		}
	]

	link: (bot, out, isPublic, command, params, message) ->
		val = /(\/|\\)?r(\/|\\)[^\/\\\s]+/ig.exec message
		query = val[0]
		if query[0] is "/" then query = query[1..]
		request "http://www.reddit.com/#{query}/about.json", (req, data, res) ->
			parsed = JSON.parse data.body
			return if parsed.error? or parsed.kind is "Listing"
			data = parsed.data

			s = ""
			s += if data.over18 then "NSFW " else ""
			s += "#{data.display_name}: http://www.reddit.com#{data.url}"

			out s

module.exports = redditMetaLinker