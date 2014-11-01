request = require "request"
moment = require "moment"

class redditIRC
	@COMMANDS: [
		{
			command: /^reddit/ig
			when: null
			method: "give"
			commandLength: 1
		}
	]

	give: (bot, out, isPublic, from, to, command, params, message) ->
		return unless params.length is 1
		username = params[0]

		request "http://www.reddit.com/user/#{username}/about.json", (req, data, res) ->
			try
				data = JSON.parse(res).data
				if isPublic
					out "Name: #{data.name} | Signup: #{moment(data.created * 1000).fromNow()} | LinkKarma: #{data.link_karma} |  CommentKarma: #{data.comment_karma} | Has gold: #{if data.is_gold then "yup!" else "nope"}"
				else
					out "Name: #{data.name} | Signup: #{moment(data.created * 1000).fromNow()} | LinkKarma: #{data.link_karma} |  CommentKarma: #{data.comment_karma} | Has gold: #{if data.is_gold then "yup!" else "nope"}"
			catch
				out "Whoops! That didn't go right!"	

module.exports = redditIRC