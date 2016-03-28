package com.watabou.switchhook.locations;

import com.watabou.switchhook.actors.Actor;
import com.watabou.switchhook.scenes.GameScene;
import com.watabou.switchhook.sprites.GameSprite;

class LockedExit extends Location {
	public function new() {
		sprite = new GameSprite( "locked" );
	}

	override public function visit( a:Actor ):Void {
		GameScene.instance.showMessage( "Find a key to unlock the exit" );
	}
}
