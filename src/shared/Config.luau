local Config = {}

Config.Title = "Girl of NevaeH"
Config.Author = "R A Simpson"

Config.Pink = Color3.fromRGB(255, 43, 214)
Config.Cyan = Color3.fromRGB(18, 216, 255)
Config.Ink = Color3.fromRGB(10, 8, 18)
Config.Gold = Color3.fromRGB(232, 201, 120)

Config.Games = {
	{
		id = "sphalerizer",
		name = "Sphalerizer",
		blurb = "Fly the sky. Fire neon beams. A boss waits at the end of the lane.",
		color = Config.Cyan,
	},
	{
		id = "warrior",
		name = "Warrior Battle",
		blurb = "Best of three. Punch, kick, and special against a rival of NevaeH.",
		color = Config.Pink,
	},
	{
		id = "civil",
		name = "Civil War",
		blurb = "Walk the street. Clear the thugs. The Karen waits as the first boss.",
		color = Config.Pink,
	},
	{
		id = "xo",
		name = "XO",
		blurb = "Three in a row. Play a friend or a light CPU.",
		color = Config.Cyan,
	},
	{
		id = "sixseven",
		name = "Six, Seven",
		blurb = "Drop discs. Four in a line wins. Seven columns, six rows.",
		color = Config.Cyan,
	},
	{
		id = "guess",
		name = "Number Guess",
		blurb = "Always pick two digits. Ten tries. Locked digits stay lit.",
		color = Config.Pink,
	},
	{
		id = "quiz",
		name = "Quiz Time",
		blurb = "Eight questions from the NevaeH bank. Four answers. Keep a streak.",
		color = Config.Cyan,
	},
}

return Config
