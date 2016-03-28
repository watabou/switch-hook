package com.watabou.switchhook.actors;

import com.watabou.switchhook.actors.actions.Action;
import com.watabou.switchhook.actors.actions.Input;
import com.watabou.switchhook.sprites.ActorSprite;
import com.watabou.switchhook.ui.MapView;
import msignal.Signal.Signal0;

class Actor {

	public var pos	: Int;

	public var hp	: Int;
	public var ht	: Int;

	public var fastAction : Bool;

	public var sprite	: ActorSprite;

	public var health	: Signal0 = new Signal0();

	public function new() {
	}

	public function act():Action {
		return null;
	}

	public function damage( dmg:Int=1 ):Bool {
		if (dmg > 0 && Game.visible.data[pos]) {
			sprite.hit();
		}

		hp = (hp > dmg ? hp - dmg : 0);
		health.dispatch();

		if (isAlive()) {
			return true;
		} else {
			die();
			return false;
		}
	}

	public function die():Void {
		hp = 0;
		Actor.remove( this );
		sprite.die();
	}

	public function isAlive():Bool {
		return hp > 0;
	}

	public function place( pos:Int ):Void {
		this.pos = pos;
		MapView.instance.addActor( this );
	}

	public function finishStep( pos:Int ):Void {
		place( pos );
	}

	public function observe():Void {
		Game.observe( this );
	}

	public function toString():String {
		var fullName = Type.getClassName( Type.getClass( this ) );
		return fullName.substr( fullName.lastIndexOf( "." ) + 1 );
	}

	// ********
	// STATIC
	// ********

	public static var all	: Array<Actor>;

	public static function reset():Void {
		all = new Array<Actor>();
	}

	public static function add( a:Actor ):Void {
		if (all.indexOf( a ) == -1) {
			all.push( a );
		}
	}

	public static function remove( a:Actor ):Void {
		all.remove( a );
	}

	public static function process():Void {
		while (true) {

			if (all.length <= 0) {
				break;
			}

			var curActor = all.shift();
			var action = curActor.act();

			if (action != null) {

				if (action.isBlocked()) {
					all.unshift( curActor );
					break;
				}

				action.perform();
				if (action == Input.instance) {
					all.unshift( curActor );
					break;
				} else if (action.isFast()) {
					all.unshift( curActor );
				} else {
					curActor.fastAction = false;
					all.push( curActor );
				}
			} else if (curActor.isAlive()) {
				all.push( curActor );
			}
		}
	}

	public static function get( pos:Int ):Actor {
		for (a in Actor.all) {
			if (a.pos == pos) {
				return a;
			}
		}
		return null;
	}
}
