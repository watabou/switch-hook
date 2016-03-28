package com.watabou.switchhook.ui;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

class BitmapButton extends Sprite {

	private var overAlpha	: Float = 0.5;
	private var outAlpha	: Float = 0.2;

	private var bmp	: Bitmap;

	public function new( bmp:Bitmap, callback:Void->Void) {
		super();
		addChild( this.bmp = bmp );

		buttonMode = true;
		if (callback != null) {
			addEventListener( MouseEvent.CLICK, function( e:MouseEvent ):Void {
				callback();
			} );
		}
		addEventListener( MouseEvent.MOUSE_OVER, onOver );
		addEventListener( MouseEvent.MOUSE_OUT, onOut );

		setAlpha( overAlpha, outAlpha );
	}

	public function setAlpha( over:Float, out:Float ):Void {
		overAlpha = over;
		outAlpha = out;
		bmp.alpha = outAlpha;
	}

	private function onOver( e:MouseEvent ):Void {
		bmp.alpha = overAlpha;
	}

	private function onOut( e:MouseEvent ):Void {
		bmp.alpha = outAlpha;
	}
}
