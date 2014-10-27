// Generated by CoffeeScript 1.7.1
(function() {
  var redditMetaLinker, request;

  request = require('request');

  redditMetaLinker = (function() {
    function redditMetaLinker() {}

    redditMetaLinker.COMMANDS = [
      {
        rawCommand: /(\/|\\)?r(\/|\\)[^\/\\\s]+/ig,
        when: null,
        method: "link"
      }
    ];

    redditMetaLinker.prototype.link = function(bot, out, isPublic, from, to, command, params, message) {
      var query, val;
      val = /(\/|\\)?r(\/|\\)[^\/\\\s]+/ig.exec(message);
      query = val[0];
      if (query[0] === "/") {
        query = query.slice(1);
      }
      return request("http://www.reddit.com/" + query + "/about.json", function(req, data, res) {
        var parsed, s;
        parsed = JSON.parse(data.body);
        if ((parsed.error != null) || parsed.kind === "Listing") {
          return;
        }
        data = parsed.data;
        s = "";
        s += data.over18 ? "NSFW " : "";
        s += "" + data.display_name + ": http://www.reddit.com" + data.url;
        return out(s);
      });
    };

    return redditMetaLinker;

  })();

  module.exports = redditMetaLinker;

}).call(this);
