package com.watabou.switchhook.ui;

import com.watabou.switchhook.utils.Updater;

class RestartButton extends Button {

	public function new() {
		super( "Try Again", 0x882222 );

		alpha = 0;
		Updater.tick.add( onFadeIn );

		setSize( 300, 40 );
	}

	private function onFadeIn( elapsed:Float ):Void {
		if ((alpha += elapsed) >= 1) {
			Updater.tick.remove( onFadeIn );
		}
	}

	override public function onClick():Void {
		SwitchHook.instance.restart();
	}
}
