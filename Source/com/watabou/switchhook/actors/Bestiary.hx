package com.watabou.switchhook.actors;

typedef MonsterType = {
	name	: String,

	sprite	: String,

	attack	: Int,
	health	: Int,

	fast		: Bool,
	immovable	: Bool,
	ranged		: Bool,
	explosive	: Bool,
	immune		: Bool,
	still		: Bool,
}

class Bestiary {

	public static var UNDEAD	: MonsterType = {
		name	: "undead warrior",
		sprite	: "undead",

		attack	: 1,
		health	: 2,

		fast:false, immovable:false, ranged:false, explosive:false, immune:false, still:false
	};

	public static var WOLF	: MonsterType = {
		name	: "giant wolf",
		sprite	: "wolf",

		attack	: 1,
		health	: 2,

		fast: true,

		immovable:false, ranged:false, explosive:false, immune:false, still:false
	};

	public static var STATUE	: MonsterType = {
		name	: "stone head",
		sprite	: "statue",

		attack	: 0,
		health	: 3,

		still: true,

		fast:false, immovable:false, ranged:false, explosive:false, immune:false
	};

	public static var TREANT	: MonsterType = {
		name	: "enraged treant",
		sprite	: "treant",

		attack	: 1,
		health	: 3,

		immovable: true,

		fast:false, still:false, ranged:false, explosive:false, immune:false
	};

	public static var ARMOR	: MonsterType = {
		name	: "animated armor",
		sprite	: "armor",

		attack	: 1,
		health	: 2,

		immune: true,

		fast:false, still:false, ranged:false, explosive:false, immovable:false
	};

	public static var CUPID	: MonsterType = {
		name	: "evil cupid",
		sprite	: "cupid",

		attack	: 1,
		health	: 2,

		ranged: true,

		fast:false, still:false, immune:false, explosive:false, immovable:false
	};

	public static var BOMB	: MonsterType = {
		name	: "dark bomb",
		sprite	: "bomb",

		attack	: 0,
		health	: 2,

		explosive: true, still: true,

		fast:false, immune:false, ranged:false, immovable:false
	};

	public static var TOAD	: MonsterType = {
		name	: "bloated toad",
		sprite	: "toad",

		attack	: 2,
		health	: 2,

		explosive: true,

		fast:false, immune:false, ranged:false, immovable:false, still: false
	};

	public static function getTypes():Array<MonsterType> {
		switch Game.stage {
			case 1:	// intro
				return [UNDEAD];
			case 2:	// intro-2
				return [UNDEAD, UNDEAD, STATUE];
			case 3:	// undead challenge
				return [UNDEAD, UNDEAD, UNDEAD, STATUE];
			case 4:	// wolf intro
				return [WOLF, UNDEAD, STATUE];
			case 5:	// wolf challenge
				return [WOLF, WOLF, UNDEAD, STATUE, STATUE];
			case 6:	// treant intro
				return [TREANT, TREANT, STATUE];
			case 7:	// bomb intro
				return [TREANT, TREANT, TREANT, BOMB, STATUE];
			case 8:	// treant challenge
				return [TREANT, TREANT, TREANT, WOLF, BOMB];
			case 9:	// armor intro
				return [ARMOR, WOLF, UNDEAD];
			case 10:	// armor + bombs
				return [ARMOR, ARMOR, ARMOR, BOMB, BOMB, STATUE];
			case 11:	// armor challenge
				return [ARMOR, ARMOR, ARMOR, ARMOR, BOMB, BOMB];
			case 12:	// toad intro
				return [TOAD, TOAD];
			case 13:	// toad challenge
				return [TOAD, TOAD, TOAD, WOLF, TREANT];
			case 14:	// cupid intro
				return [CUPID, TREANT, UNDEAD];
			case 15:	// cupid management
				return [CUPID, CUPID, STATUE, STATUE, UNDEAD];
			case 16:	// cupid challenge
				return [CUPID, CUPID, CUPID, WOLF, STATUE, STATUE];
			case 17:	// dark forest
				return [TOAD, TOAD, WOLF, WOLF, TREANT, TREANT, TREANT];
			case 18:	// army of dead
				return [UNDEAD, UNDEAD, UNDEAD, UNDEAD, UNDEAD, UNDEAD, UNDEAD];
			case 19:	//  cursed castle
				return [ARMOR, ARMOR, ARMOR, ARMOR, ARMOR, BOMB, STATUE];
			case 20:	// final
				return [CUPID, CUPID, CUPID, CUPID, ARMOR, ARMOR, TOAD, TOAD, STATUE, STATUE];
		}
		return [CUPID, CUPID];
	}
}
