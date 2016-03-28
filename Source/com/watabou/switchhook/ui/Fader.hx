package com.watabou.switchhook.ui;

import com.watabou.switchhook.utils.Sound;
import com.watabou.switchhook.utils.Updater;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.StageDisplayState;
import msignal.Signal.Signal0;

class Fader extends View {

	private var block	: Bitmap;
	private var sound	: SoundButton;
	private var fscreen	: FullScreenButton;

	public var complete : Signal0 = new Signal0();

	public function new() {
		super();
	}

	override private function createChildren():Void {
		block = new Bitmap( new BitmapData( 1, 1, true, 0xFF000000 ) );
		addChild( block );

		sound = new SoundButton();
		addChild( sound );

		fscreen = new FullScreenButton();
		addChild( fscreen );
	}

	override private function layout():Void {
		block.width = rWidth;
		block.height = rHeight;

		fscreen.x = rWidth - sound.width - 4;
		fscreen.y = rHeight - sound.height - 4;

		sound.x = fscreen.x - sound.width - 8;
		sound.y = fscreen.y;
	}

	public function fadeIn():Void {
		Updater.tick.add( onFadeIn );
		Updater.tick.remove( onFadeOut );
		block.visible = true;
		block.alpha = 1;
	}

	public function fadeOut():Void {
		Updater.tick.add( onFadeOut );
		Updater.tick.remove( onFadeIn );
		block.visible = true;
		block.alpha = 0;
	}

	private function onFadeIn( elapsed:Float ):Void {
		if ((block.alpha -= elapsed * 2) <= 0) {
			Updater.tick.remove( onFadeIn );
			block.visible = false;
			complete.dispatch();
		}
	}

	private function onFadeOut( elapsed:Float ):Void {
		if ((block.alpha += elapsed * 2) >= 1) {
			Updater.tick.remove( onFadeOut );
			complete.dispatch();
		}
	}
}

private class SoundButton extends BitmapButton {

	public function new() {
		super( new Bitmap( Assets.getBitmapData( "sound" ) ), onClick );
		Sound.on;
	}

	private function onClick():Void {
		if (Sound.on = !Sound.on) {
			Sound.play( "click" );
		}
	}
}

private class FullScreenButton extends BitmapButton {

	public function new() {
		super( new Bitmap( Assets.getBitmapData( "fullscreen" ) ), onClick );
	}

	private function onClick():Void {
		stage.displayState = (stage.displayState == StageDisplayState.NORMAL) ?
			StageDisplayState.FULL_SCREEN_INTERACTIVE :
			StageDisplayState.NORMAL;
	}
}
