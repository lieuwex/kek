// Generated by CoffeeScript 1.7.1
(function() {
  var exec, insults, _;

  _ = require("lodash");

  insults = ["STAHP", "Y U DO DIS", "I EHM'T UR MUM LAST NITE", "STFU"];

  exec = (function() {
    function exec() {}

    exec.COMMANDS = [
      {
        rawCommand: /^`.+`$/i,
        when: null,
        method: "exec"
      }
    ];

    exec.prototype.exec = function(bot, out, isPublic, from, to, command, params, message, where) {
      if (from !== "Lieuwex") {
        return;
      }
      return out(eval(message.substring(1, message.length - 1)));
    };

    return exec;

  })();

  module.exports = exec;

}).call(this);
