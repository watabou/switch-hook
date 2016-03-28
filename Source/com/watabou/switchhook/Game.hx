package com.watabou.switchhook;

import com.watabou.switchhook.actors.Actor;
import com.watabou.switchhook.actors.Bestiary;
import com.watabou.switchhook.actors.Hero;
import com.watabou.switchhook.actors.Monster;
import com.watabou.switchhook.geography.HexMap;
import com.watabou.switchhook.geography.Level;
import com.watabou.switchhook.geography.ShadowCaster;
import openfl.net.SharedObject;

class Game {

	public static inline var MAX_STAGE : Int = 20;

	public static var stage	: Int;
	public static var theme	: Int;

	public static var hero	: Hero;
	public static var level : Level;

	public static var visible	: HexMap = new HexMap();
	public static var visited	: HexMap = new HexMap();

	public static var genocide	: Bool;
	public static var pacifism	: Bool;
	public static var victory	: Bool;
	public static var loaded	: Bool;

	public static function newGame():Void {
		stage = 0;
		hero = new Hero();
		genocide = false;
		pacifism = false;
		victory = false;
		loaded = false;
	}

	public static function newLevel():Void {
		stage++;
		theme = -1;
		level = new Level();
		for (i in 0...HexMap.LENGTH) {
			visited.data[i] = false;
		}
		hero.spawn();

		#if flash
		Game.save();
		#end
	}

	public static function nextLevel():Void {

		genocide = true;
		for (mob in Game.level.mobs) {
			if (!cast(mob, Monster).isPassive()) {
				genocide = false;
				break;
			}
		}

		pacifism = (Game.level.mobs.length == Bestiary.getTypes().length);

		loaded = false;

		newLevel();
	}

	private static inline var SAVED = "SAVED4";

	public static function save():Void {
		var so = SharedObject.getLocal( "savedGame" );
		so.data.saved = SAVED;

		so.data.stage = stage;
		so.data.theme = theme;
		so.data.visited = visited.data;

		so.data.hero = hero.save();
		so.data.level = level.save();

		so.flush();
	}

	public static function load( ):Void {
		var so = SharedObject.getLocal( "savedGame" );

		stage = so.data.stage;
		theme = so.data.theme;
		visited = new HexMap( so.data.visited );

		hero = new Hero( so.data.hero );
		level = new Level( so.data.level );

		loaded = true;
	}

	public static function isGameSaved():Bool {
		return SharedObject.getLocal( "savedGame" ).data.saved == SAVED;
	}

	public static function clear():Void {
		SharedObject.getLocal( "savedGame" ).clear();
	}

	public static function observe( a:Actor ):Void {

		ShadowCaster.observe( a.pos, HexMap.SIZE, Game.level.walls.data );

		if (a == hero) {
			for (i in 0...HexMap.LENGTH) {
				var v:Bool = ShadowCaster.fov[i];
				visible.data[i] = v;
				visited.data[i] = visited.data[i] || v;
			}
		}
	}
}
