package com.watabou.switchhook.locations;

import com.watabou.switchhook.actors.Actor;
import com.watabou.switchhook.sprites.GameSprite;

class Location {

	public var pos : Int;

	public var sprite : GameSprite;

	public function visit( a:Actor ):Void {
	}

	public function remove():Void {
		if (sprite != null) {
			sprite.parent.removeChild( sprite );
		}
		Game.level.locs.remove( this );
	}
}
