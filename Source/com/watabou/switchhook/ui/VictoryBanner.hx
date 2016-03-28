package com.watabou.switchhook.ui;

import com.watabou.switchhook.utils.Updater;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.GradientType;
import openfl.geom.Matrix;

class VictoryBanner extends View {

	private static inline var HEIGHT	: Float = 100;
	private static inline var VIOLET	: Int = 0x31174d;
	private static inline var GOLD		: Int = 0xe6bf00;

	private var text : Bitmap;

	public function new() {
		super();

		alpha = 0;
		Updater.tick.add( onFadeIn );

		setSize( 300, 40 );
		mouseEnabled = false;
	}

	override private function createChildren():Void {
		text = new Bitmap( Assets.getBitmapData( "victory" ) );
		addChild( text );
	}

	override private function layout():Void {
		text.x = Std.int( (width - text.width) / 2 );
		text.y = Std.int( (height - text.height) / 2 );

		var m:Matrix = new Matrix();
		m.createGradientBox( width, HEIGHT, 0 );

		graphics.clear();
		graphics.beginGradientFill( GradientType.LINEAR, [VIOLET,VIOLET,VIOLET], [0,0.5,0], [0,128,255], m );
		graphics.drawRect( 0, (height - HEIGHT) / 2, width, HEIGHT );

		graphics.beginGradientFill( GradientType.LINEAR, [GOLD,GOLD,GOLD], [0,1,0], [0,128,255], m );
		graphics.drawRect( 0, (height - HEIGHT) / 2, width, 2 );
		graphics.drawRect( 0, (height + HEIGHT) / 2 - 2, width, 2 );
	}

	private function onFadeIn( elapsed:Float ):Void {
		if ((alpha += elapsed) >= 1) {
			Updater.tick.remove( onFadeIn );
		}
	}
}
