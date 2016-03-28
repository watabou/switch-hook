package com.watabou.switchhook.effects;

import com.watabou.switchhook.utils.Updater;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;

class Blood extends Sprite {

	private static var DARK :ColorTransform = new ColorTransform( 0.3, 0.3, 0.3 );

	public function new( dark:Bool=false ) {

		super();

		var bmp = new Bitmap( Assets.getBitmapData( "blood" ) );
		bmp.x = -bmp.width / 2;
		bmp.y = -bmp.height / 2;
		if (dark) {
			bmp.transform.colorTransform = DARK;
		}
		addChild( bmp );
		rotation = Math.random() * 360;

		Updater.tick.add( onUpdate );
	}

	private function onUpdate( elapsed:Float ):Void {
		if ((alpha -= elapsed * 5) <= 0) {
			parent.removeChild( this );
			Updater.tick.remove( onUpdate );
		} else {
			scaleX = scaleY = 2 - alpha;
		}
	}
}
