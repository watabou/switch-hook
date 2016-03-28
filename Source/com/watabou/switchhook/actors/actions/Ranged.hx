package com.watabou.switchhook.actors.actions;

import com.watabou.switchhook.effects.Arrow;
import com.watabou.switchhook.utils.Sound;

class Ranged extends Action {

	public var enemy : Actor;

	public function new( obj:Actor, enemy:Actor ) {
		this.obj = obj;
		this.enemy = enemy;
	}

	override public function perform():Void {
		var arrow = new Arrow( obj, enemy );
		arrow.hit.addOnce( onArrive );

		Action.add( this );

		obj.sprite.showState( true );

		Sound.play( "shoot", obj.sprite );
	}

	private function onArrive():Void {

		obj.sprite.showState( false );

		Sound.play( "ranged", enemy.sprite );

		enemy.damage( Std.is( obj, Monster ) ? cast(obj, Monster).type.attack : 1 );
		Action.remove( this );
	}

	override public function involves():Array<Actor> {
		return [obj, enemy];
	}
}
