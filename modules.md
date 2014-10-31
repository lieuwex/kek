kek module documentation
===

kek uses NPM as package manager for modules.

A module needs to export a object with a constructor, a static COMMANDS dictionary and a bunch of functions.

You can configure kek using kek.json. (Hopefully also soon for modules.)

kek bot object:
- `VERISON`: `String`
- `store`: `function(key, [value])`
- `clients`: `IRC-client`
- `modules`: `Module[]`
- `commands`: `{ command: RegExp, method: Function }[]`
- `commandPrefix`: `String` (not currently used)
- `publicPrefix`: `String`
- `privatePrefix`: `String`
- `commands`: `Dictionary (key: type, value: command)`

Full structure of a kek module:
- `COMMANDS`: `{ rawCommand|command: RegExp, method: String, when: String[] }[]` `method` is a name of a function in this kek module. `when` is an Array containing Strings that indicate where this method can be called. If this is null the method will be able to be called everywhere. If this is null the method will be able to be called everywhere. `rawCommand` is different from `command`, whereas `command` first removes the commandPrefixes from the message (it always removes the amount of chars of the prefixes, even when there is none. So you'll probably get a cut off string), `rawCommand` will just match against the full message.
- `constructor`: (`bot`)
	- `bot`: `The kek bot`
- `destruct`: (`exitCode`)
	- `exitCode`: `Number`
- `<methodName>`: (`bot`, `out`, `isPublic`, `from`, `to`, `command`, `params`, `message`)
	- `bot`: `The kek bot`
	- `out`: `function(string)`
	- `isPublic`: `Boolean`
	- `from`: `String`
	- `to`: `String`
	- `command`: `String`
	- `params`: `String[]`
	- `message`: `String`
