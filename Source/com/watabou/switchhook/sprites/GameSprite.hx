package com.watabou.switchhook.sprites;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;

class GameSprite extends Sprite {

	private var bmp	: Bitmap;

	public function new( src:String ) {

		super();

		bmp = new Bitmap( Assets.getBitmapData( src ) );
		bmp.x = Std.int( -bmp.width / 2 );
		bmp.y = -bmp.height;
		addChild( bmp );

		mouseEnabled = false;
		mouseChildren = false;
	}
}
