package com.watabou.switchhook.actors.actions;

import com.watabou.switchhook.effects.HookThrow;
import com.watabou.switchhook.effects.Swap;
import com.watabou.switchhook.ui.MapView;
import com.watabou.switchhook.utils.Sound;

class SwitchHook extends Action {

	public var target : Monster;

	private var blocked : Array<Actor>;

	public function new( obj:Actor, target:Monster ) {
		this.obj = obj;
		this.target = target;

		blocked = Actor.all.concat( [obj] );
	}

	override public function perform():Void {
		var effect:HookThrow = new HookThrow( obj, target );
		effect.switched.addOnce( onThrown );
		MapView.instance.addChild( effect );

		Sound.play( "hook", obj.sprite );
		obj.sprite.showState( true );

		Action.add( this );
	}

	private function onThrown():Void {

		obj.sprite.showState( false );

		if (target.type.immovable) {
			finish();
		} else {
			var swap = new Swap( obj, target );
			swap.complete.addOnce( onSwapped );

			Sound.play( "pull", obj.sprite );
		}
	}

	private function onSwapped():Void {
		var pos:Int = obj.pos;
		obj.place( target.pos );
		target.place( pos );

		finish();
	}

	private function finish():Void {
		if (!target.type.immune) {
			Sound.play( "ranged", target.sprite );
			target.damage();
		}

		for (loc in Game.level.locs) {
			if (loc.pos == obj.pos) {
				loc.visit( obj );
			}
		}

		Action.remove( this );
	}

	override public function involves():Array<Actor> {
		return blocked;
	}
}
