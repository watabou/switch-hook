package com.watabou.switchhook.effects;

import com.watabou.switchhook.actors.Actor;
import com.watabou.switchhook.geography.Hex;
import com.watabou.switchhook.utils.Updater;
import msignal.Signal.Signal0;

class Swap {

	private var a1 : Actor;
	private var a2 : Actor;

	private var progress : Float;
	private var x1 : Float;
	private var y1 : Float;
	private var x2 : Float;
	private var y2 : Float;

	private var k : Float;

	public var complete : Signal0 = new Signal0();

	public function new( a1:Actor, a2:Actor ) {

		this.a1 = a1;
		this.a2 = a2;

		progress = 0;
		x1 = a1.sprite.x;
		y1 = a1.sprite.y;
		x2 = a2.sprite.x;
		y2 = a2.sprite.y;

		k = 4 / Math.sqrt( Hex.distancePacked( a1.pos, a2.pos ) );

		Updater.tick.add( onAdvance );
	}

	private function onAdvance( elapsed:Float ):Void {
		if ((progress += elapsed * k) >= 1) {
			Updater.tick.remove( onAdvance );
			complete.dispatch();
		} else {
			a1.sprite.x = x1 + (x2 - x1) * progress;
			a1.sprite.y = y1 + (y2 - y1) * progress;
			a2.sprite.x = x2 - (x2 - x1) * progress;
			a2.sprite.y = y2 - (y2 - y1) * progress;
		}
	}
}
