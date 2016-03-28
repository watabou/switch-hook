package com.watabou.switchhook.actors.actions;

import com.watabou.switchhook.utils.Sound;

class Melee extends Action {

	public var enemy : Actor;

	public function new( obj:Actor, enemy:Actor ) {
		this.obj = obj;
		this.enemy = enemy;
	}

	override public function perform():Void {
		Action.add( this );
		obj.sprite.arrival.addOnce( onArrive );
		obj.sprite.showState( true );
		obj.sprite.attack( obj.pos, enemy.pos );
	}

	private function onArrive():Void {
		Sound.play( "melee", enemy.sprite );

		obj.sprite.showState( false );

		enemy.damage( Std.is( obj, Monster ) ? cast(obj, Monster).type.attack : 1 );
		Action.remove( this );
	}

	override public function involves():Array<Actor> {
		return [obj, enemy];
	}
}
