package com.watabou.switchhook.locations;

import com.watabou.switchhook.actors.Actor;
import com.watabou.switchhook.scenes.GameScene;
import com.watabou.switchhook.sprites.GameSprite;
import com.watabou.switchhook.sprites.LocationSprite;
import com.watabou.switchhook.utils.Sound;

class Exit extends Location {
	public function new() {
		sprite = new LocationSprite( "exit" );
	}

	override public function visit( a:Actor ):Void {
		if (a == Game.hero) {
			Sound.play( "teleport" );
			Game.nextLevel();
			SwitchHook.instance.switchScene( GameScene );
		}
	}
}
