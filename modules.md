kek module documentation
===

kek uses NPM as package manager for modules.

A module needs to export a object with a constructor, a static COMMANDS dictionary and a bunch of functions.

You can configure kek using kek.json. (Hopefully also soon for modules.)

kek bot object:
- `VERISON`: `String`
- `clients`: `IRC-client`
- `modules`: `Module[]`
- `commands`: `{ command: RegExp, method: Function }[]`
- `commandPrefix`: `String` (not currently used)
- `publicPrefix`: `String`
- `privatePrefix`: `String`
- `commands`: `Dictionary (key: type, value: command)`

Full structure of a kek module:
- `COMMANDS`: `{ command: RegExp, method: String, when: String[] }[]` `method` is a name of a function in this kek module. `when` is an Array containing Strings that indicate where this method can be called. If this is null the method will be able to be called everywhere.
- `constructor`: (`bot`)
	- `bot`: `The kek bot` 
- `<methodName>`: (`bot`, `out`, `public`, `command`, `params`)
	- `bot`: `The kek bot`
	- `out`: `function(string)`
	- `public`: `Boolean`
	- `command`: `String`
	- `params`: `String[]`
	- `message`: `String`