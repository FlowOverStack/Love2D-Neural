-- Persistent Data
local multiRefObjects = {
{};
} -- multiRefObjects
multiRefObjects[1]["red"] = 1;
multiRefObjects[1]["blue"] = 1;
multiRefObjects[1]["green"] = 1;
local obj1 = {
	[1] = {
		["x"] = 192;
		["dendrites"] = {
		};
		["y"] = 240;
		["colors"] = multiRefObjects[1];
		["sum"] = 0;
		["axons"] = {
			[1] = {
				["connectedTo"] = 2;
				["strength"] = 1;
			};
		};
		["value"] = 0;
		["alreadyUpdated"] = false;
		["target"] = 0;
	};
	[2] = {
		["x"] = 240;
		["dendrites"] = {
			[1] = {
				["connectedTo"] = 1;
				["strength"] = 1;
			};
		};
		["y"] = 256;
		["colors"] = multiRefObjects[1];
		["sum"] = 0;
		["axons"] = {
		};
		["value"] = 0;
		["alreadyUpdated"] = false;
		["target"] = 0;
	};
}
return obj1
