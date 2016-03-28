package com.watabou.switchhook.actors;

import com.watabou.switchhook.actors.Bestiary.MonsterType;
import com.watabou.switchhook.actors.actions.Action;
import com.watabou.switchhook.actors.actions.Melee;
import com.watabou.switchhook.actors.actions.Motion;
import com.watabou.switchhook.actors.actions.Ranged;
import com.watabou.switchhook.effects.Explosion;
import com.watabou.switchhook.geography.Hex;
import com.watabou.switchhook.geography.HexMap;
import com.watabou.switchhook.geography.PathFinder;
import com.watabou.switchhook.geography.ShadowCaster;
import com.watabou.switchhook.sprites.ActorSprite;
import com.watabou.switchhook.utils.Sound;

class Monster extends Actor {

	public var type : MonsterType;

	private var dest : Int = -1;

	public function new( type:MonsterType ) {
		super();

		this.type = type;

		hp = ht = type.health;

		sprite = new ActorSprite( this, type.sprite );
	}

	override public function place( pos:Int ):Void {
		super.place( pos );
		sprite.displayed = Game.visible.data[pos];
	}

	override public function die():Void {
		super.die();
		Game.level.mobs.remove( this );

		if (type.explosive) {
			for (dir in Hex.DIRS) {
				var a = Actor.get( Hex.offsetPacked( pos, dir ) );
				if (a != null) {
					a.damage( Std.is( a, Monster ) ? a.hp : 1 );
				}
			}
			new Explosion( pos );

			Sound.play( "explosion" );
		}
	}

	override public function act():Action {

		Game.observe( this );


		if (Game.hero.isAlive() && ShadowCaster.fov[Game.hero.pos]) {

			// The hero is alive and the monster knows where is he
			dest = Game.hero.pos;
			var distance = Hex.distancePacked( pos, dest );

			if (type.attack > 0) {

				// The monster can attack (in general)
				if (type.ranged) {
					if (distance > 2) {
						if (distance <= 4) {
							// The monster shoots if the the hero is within its shooting distance
							return new Ranged( this, Game.hero );
						}
					} else {
						// The hero is too close to the monster, trying to step back
						var step = getFurther( Game.hero.pos );
						if (step == -1) {
							return null;
						} else {
							return new Motion( this, step, type.fast && !fastAction );
						}
					}
				} else {
					if (distance == 1) {
						// The hero is adjacent to the monster, the monster attacks
						return new Melee( this, Game.hero );
					}
				}
			}

		} else if (dest == -1) {
			// The hero is dead or the monster doesn't know where is he
			dest = Game.level.empty.random( true );
		}

		// The monster goes where he was going to go or skips a turn if it's impossible
		var step = getCloser();
		if (step == -1) {
			dest = -1;
			return null;
		} else {
			return new Motion( this, step, type.fast && !fastAction );
		}
	}

	private function getCloser():Int {

		if (type.still) {
			return -1;
		}

		var passable = Game.level.empty.clone();
		for (a in Actor.all) {
			if (ShadowCaster.fov[a.pos]) {
				passable.data[a.pos] = false;
			}
		}

		var step = PathFinder.step( pos, dest, passable.data );
		if (step != -1 && passable.data[step]) {
			return step;
		} else {
			return -1;
		}
	}

	private function getFurther( away:Int ):Int {

		if (type.still) {
			return -1;
		}

		var passable = Game.level.empty.clone();
		for (a in Actor.all) {
			if (ShadowCaster.fov[a.pos]) {
				passable.data[a.pos] = false;
			}
		}

		var step = PathFinder.stepBack( pos, away, passable.data );
		if (step != -1 && passable.data[step]) {
			return step;
		} else {
			return -1;
		}
	}

	public function isPassive():Bool {
		return type.still && type.attack == 0;
	}

	public function getAttackArea( map:HexMap ):Void {
		if (type.attack == 0) {

			// Non-atacking monsters
			map.fill( false );
			map.data[pos] = true;

		} else if (type.fast) {

			// Fast monsters
			map.fill( false );
			for (dir in Hex.DIRS) {
				var p = Hex.offsetPacked( pos, dir );
				if (map.data[p] = (Game.visited.data[p] && Game.level.empty.data[p])) {
					var a = Actor.get( p );
					if (a == null || a == Game.hero) {
						for (dir1 in Hex.DIRS) {
							var p1 = Hex.offsetPacked( p, dir1 );
							map.data[p1] = (Game.visited.data[p1] && Game.level.empty.data[p1]);
						}
					}
				}
			}

		} else if (type.ranged) {

			// Ranged monsters
			Game.observe( this );
			for (i in 0...HexMap.LENGTH) {
				var d = Hex.distancePacked( i, pos );
				map.data[i] = (d > 2 && d <= 4) && ShadowCaster.fov[i] && (Game.visited.data[i] && Game.level.empty.data[i]);
			}

		} else {

			// Normal monsters
			map.fill( false );
			for (dir in Hex.DIRS) {
				var p = Hex.offsetPacked( pos, dir );
				map.data[p] = (Game.visited.data[p] && Game.level.empty.data[p]);
			}
			map.data[pos] = true;
		}
	}

	public static function save( mob:Monster ):Dynamic {
		return {
			hp		: mob.hp,
			pos		: mob.pos,
			dest	: mob.dest,
			type 	: mob.type
		}
	}

	public static function load( saved:Dynamic ):Monster {
		var mob = new Monster( saved.type );
		mob.hp = saved.hp;
		mob.pos = saved.pos;
		mob.dest = saved.dest;
		mob.health.dispatch();
		return mob;
	}
}
