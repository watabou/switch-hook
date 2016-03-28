package com.watabou.switchhook.scenes;

import com.watabou.switchhook.ui.Button;
import com.watabou.switchhook.ui.BitmapButton;
import com.watabou.switchhook.ui.BitmapText;
import com.watabou.switchhook.utils.Updater;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.geom.Rectangle;
import openfl.net.URLRequest;
import openfl.system.System;
import openfl.ui.Keyboard;

class TitleScene extends Scene {

	private var logo	: Bitmap;
	private var start	: StartButton;
	private var version	: BitmapButton;

	private var bmpStar : BitmapData;
	private var stars	: Array<Star> = [];

	public function new() {
		super();
	}

	override private function createChildren():Void {
		logo = new Bitmap( Assets.getBitmapData( "logo" ) );
		addChild( logo );

		start = new StartButton();
		start.setSize( 300, 40 );
		addChild( start );

		version = new BitmapButton( new BitmapText( SwitchHook.fontSmall, "Created by Watabou, version 1.0.4" ), onVersion );
		addChild( version );
	}

	override private function layout():Void {
		logo.x = Std.int( (rWidth - logo.width) / 2 );
		logo.y = Std.int( (rHeight - logo.height - 16 - start.height) / 2 );

		start.x = Std.int( (rWidth - start.width) / 2 );
		start.y = logo.y + 16 + logo.height;

		version.x = 8;
		version.y = rHeight + (SwitchHook.fontSmall.lineHeight - SwitchHook.fontSmall.baseLine) - version.height - 8;
	}

	override private function onAdded():Void {
		super.onAdded();
		stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		Updater.tick.add( processStars );
	}

	override private function onRemoved():Void {
		super.onRemoved();
		stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		Updater.tick.remove( processStars );
	}

	private function onKeyDown( e:KeyboardEvent ):Void {
		switch (e.keyCode) {
		case Keyboard.ESCAPE:
			System.exit( 0 );

		case Keyboard.ENTER:
			start.onClick();

		case Keyboard.SPACE:
			start.onClick();
		}
	}

	private function onVersion():Void {
		Lib.getURL( new URLRequest( "https://twitter.com/watawatabou" ) );
	}

	private function processStars( elapsed:Float ):Void {
		for (star in stars) {
			if (star.progress < 1) {
				star.progress += elapsed / 2;
			}
		}

		var x = Std.int( Math.random() * logo.width );
		var y = Std.int( Math.random() * logo.height );
		if (logo.bitmapData.getPixel32( x, y ) == 0xFF8a9499) {
			var star = null;
			for (s in stars) {
				if (s.progress >= 1) {
					star = s;
					break;
				}
			}
			if (star == null) {
				star = new Star();
				stars.push( star );
			}
			star.x = logo.x + x;
			star.y = logo.y + y;
			star.progress = 0;
			addChild( star );
		}
	}
}

private class StartButton extends Button {
	public function new() {
		super( "Press to start", 0x999082 );
	}

	override public function onClick():Void {
		Game.isGameSaved();
		if (Game.isGameSaved()) {
			SwitchHook.instance.loadGame();
		} else {
			SwitchHook.instance.restart();
		}
	}
}

private class Star extends Sprite {

	private static inline var SIZE = 11;

	private static var data	: BitmapData;

	public function new() {
		super();

		if (data == null) {
			data = new BitmapData( SIZE*2+1, SIZE*2+1, true, 0 );
			data.fillRect( new Rectangle( SIZE, 0, 1, SIZE*2+1 ), 0xFFFFFFFF );
			data.fillRect( new Rectangle( 0, SIZE, SIZE*2+1, 1 ), 0xFFFFFFFF );
			data.fillRect( new Rectangle( SIZE-1, SIZE-1, 3, 3 ), 0xFFFFFFFF );
		}

		var bmp = new Bitmap( data, PixelSnapping.ALWAYS, true );
		bmp.x = -SIZE;
		bmp.y = -SIZE;
		addChild( bmp );
	}

	public var progress(get, set) : Float;
	private var _progress : Float = 0;
	public function get_progress():Float {
		return _progress;
	}
	public function set_progress( value:Float ):Float {
		rotation = value * 360;
		if (value < 0.5) {
			alpha = value * 2;
		} else {
			alpha = (1 - value) * 2;
			if (value >= 1) {
				parent.removeChild( this );
			}
		}
		scaleX = scaleY = alpha;
		return (_progress = value);
	}
}
