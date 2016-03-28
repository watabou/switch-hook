package com.watabou.switchhook.geography;


import com.watabou.switchhook.actors.Bestiary;
import com.watabou.switchhook.actors.Monster;
import com.watabou.switchhook.locations.Amulet;
import com.watabou.switchhook.locations.Entrance;
import com.watabou.switchhook.locations.Exit;
import com.watabou.switchhook.locations.Key;
import com.watabou.switchhook.locations.Location;
import com.watabou.switchhook.locations.LockedExit;
import com.watabou.switchhook.locations.Shard;

class Level {

	public var abris	: HexMap;
	public var border	: HexMap;
	public var empty	: HexMap;
	public var walls	: HexMap;

	public var start	: Int;

	public var mobs	: Array<Monster>;
	public var locs	: Array<Location>;

	public function new( saved:Dynamic=null ) {

		if (saved != null) {
			load( saved );
			return;
		}

		empty = new HexMap();
		HexMap.blobness = 0.3;
		var minPassableSqr = Std.int( HexMap.LENGTH * 0.2 );
		do {
			empty.fill( false );
			empty.grow( HexMap.CENTER, Std.int(HexMap.SIZE / 2), HexMap.randomDir() );
		} while (empty.square() < minPassableSqr);

		abris = empty.clone();

		var borderTile = -1;

		walls = new HexMap();
		for (i in 0...HexMap.LENGTH) {
			if (!empty.data[i]) {

				for (dir in Hex.DIRS) {
					var neighbour = Hex.offsetPacked( i, dir );
					if (neighbour != -1 && empty.data[neighbour]) {
						abris.data[i] = true;
						walls.data[i] = true;
						borderTile = i;
						break;
					}
				}

			} else {

				for (dir in Hex.DIRS) {
					var neighbour = Hex.offsetPacked( i, dir );
					if (neighbour == -1) {
						empty.data[i] = false;
						walls.data[i] = true;
						borderTile = i;
						break;
					}
				}
			}
		}

		border = walls.floodFill( borderTile );

		createLocations();
		createMobs();
	}

	private function createMobs():Void {

		var dmap = PathFinder.buildDMap( start, empty.data );

		mobs = [];
		for (type in Bestiary.getTypes()) {
			var mob = new Monster( type );
			do {
				mob.pos = empty.random( true );
				if (Math.random() * dmap[mob.pos] < 2) {
					mob.pos = -1;
					continue;
				}
				for (other in mobs) {
					if (mob.pos == other.pos) {
						mob.pos = -1;
						continue;
					}
				}
			} while (mob.pos == -1);
			mobs.push( mob );
		}
	}

	private function createLocations():Void {
		locs = [];

		start = -1;
		do {
			var pos = border.random( true );
			for (d in Hex.DIRS) {
				var neighbour = Hex.offsetPacked( pos, d );
				if (neighbour != -1 && empty.data[neighbour]) {
					start = neighbour;
					break;
				}
			}
		} while (start == -1);

		var entrance = new Entrance();
		entrance.pos = start;
		locs.push( entrance );

		var dmap = PathFinder.buildDMap( entrance.pos, empty.data ).copy();

		if (Game.stage >= Game.MAX_STAGE) {
			var amulet = new Amulet();
			amulet.pos = findMostDistant( dmap );
			locs.push( amulet );

			addLocation( amulet, dmap );
		} else {
			var exit = Math.random() * Game.stage > 1 ? new LockedExit() : new Exit();
			exit.pos = findMostDistant( dmap );
			locs.push( exit );

			addLocation( exit, dmap );

			if (Std.is( exit, LockedExit )) {
				var key = new Key();
				key.pos = findMostDistant( dmap );
				locs.push( key );

				addLocation( key, dmap );
			}
		}

		if (Game.genocide) {
			var shard = new Shard();
			shard.pos = findMostDistant( dmap );
			locs.push( shard );
		}
	}

	private function findMostDistant( map:Array<Int>):Int {
		var distant = -1;
		var distance = 0;
		for (i in 0...HexMap.LENGTH) {
			var d = map[i];
			if (d != PathFinder.UNREACHABLE && d > distance) {
				distant = i;
				distance = d;
			}
		}
		return distant;
	}

	private function addLocation( loc:Location, map:Array<Int> ):Void {
		var newMap = PathFinder.buildDMap( loc.pos, empty.data );
		for (i in 0...HexMap.LENGTH) {
			if (newMap[i] != PathFinder.UNREACHABLE) {
				map[i] *= newMap[i];
			}
		}
	}

	private static inline var AMULET = "AMULET";
	private static inline var EXIT	 = "EXIT";
	private static inline var LOCK	 = "LOCK";
	private static inline var KEY	 = "KEY";
	private static inline var SHARD	 = "SHARD";

	private static function getLocationTag( loc:Location ):String {
		if (Std.is( loc, Amulet )) {
			return AMULET;
		} else if (Std.is( loc, LockedExit )) {
			return LOCK;
		} else if (Std.is( loc, Exit )) {
			return EXIT;
		} else if (Std.is( loc, Key )) {
			return KEY;
		} else if (Std.is( loc, Shard )) {
			return SHARD;
		} else {
			return null;
		}
	}

	public function save():Dynamic {
		return {
			empty	: empty.data,
			walls	: walls.data,
			mobs	: [for (mob in mobs) Monster.save( mob )],
			locs	: [ for (loc in locs) {
				pos		: loc.pos,
				name	: getLocationTag( loc )
			} ]
		}
	}

	public function load( saved:Dynamic ) {
		empty = new HexMap( saved.empty );
		walls = new HexMap( saved.walls );
		abris = new HexMap( [for (i in 0...HexMap.LENGTH) empty.data[i] || walls.data[i]] );

		mobs = [];
		for (savedMob in cast(saved.mobs, Array<Dynamic>)) {
			mobs.push( Monster.load( savedMob ) );
		}

		locs = [];
		for (savedLoc in cast(saved.locs, Array<Dynamic>)) {
			var loc = switch (savedLoc.name) {
				case AMULET:
					new Amulet();
				case LOCK:
					new LockedExit();
				case EXIT:
					new Exit();
				case KEY:
					new Key();
				case SHARD:
					new Shard();
				default:
					null;
			}
			if (loc != null) {
				loc.pos = savedLoc.pos;
				locs.push( loc );
			}
		}
	}
}
