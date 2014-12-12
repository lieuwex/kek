_ = require "lodash"
magisterJS = require "magister.js"

Magister = magisterJS.Magister
MagisterSchool = magisterJS.MagisterSchool

Date::addDays = (days) -> @setDate @getDate() + days; return @

class magisterIRC
	@COMMANDS: [
		{
			rawCommand: /^magister create \S+ \S+ \S+$/i
			when: "pm"
			method: "register"
			commandLength: 2
		}
		{
			command: /^magister time/i
			when: null
			method: "time"
			commandLength: 2
		}
	]

	constructor: (bot) ->
		@store = (key, value) -> return if key? then bot.store("m_" + key, value) else undefined
		@check = (name) ->
			val = @store(name)
			unless val? then bot.currentClient.notice name, "--- You're not registered. Register with /msg magisterIRC create <schoolname> <username> <password> ---"
			return val

	register: (bot, out, isPublic, from, to, command, params, message) =>
		unless @store from
			MagisterSchool.getSchools params[0], (e, r) =>
				if e? then out "--Something has gone wrong--"
				else @store from, school: r[0], username: params[1], password: params[2]
		else
			out "--- Already registered. ---"

	time: (bot, out, isPublic, from, to, command, params, message) =>
		return unless (val = @check from)?
		new Magister(val.school, val.username, val.password, no).ready (m) ->
			m.appointments new Date(), new Date().addDays(3), (e, r) ->
				if e? then out "--Something has gone wrong--"
				else
					appointment = _.find r, (a) -> not a.fullDay() and _.contains([8..17], a.begin().getHours())
					out "--- First lesson #{if isPublic then "for #{from}" else ""} @ #{appointment.begin()} (#{appointment.classes()[0]}) ---"

module.exports = magisterIRC