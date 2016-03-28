package com.watabou.switchhook.effects;

import com.watabou.switchhook.ui.MapView;
import com.watabou.switchhook.utils.Updater;
import openfl.display.BlendMode;
import openfl.display.GradientType;
import openfl.display.Shape;
import openfl.geom.Matrix;

class Explosion extends Shape {
	public function new( pos:Int ) {

		super();

		var m = new Matrix();
		m.createGradientBox( MapView.W * 4, MapView.W * 4, 0, -MapView.W * 2, -MapView.W * 2 );
		graphics.beginGradientFill( GradientType.RADIAL, [0xFFFFFF, 0xFFFFFF], [0, 1], [0, 255], m );
		graphics.drawCircle( 0, 0, MapView.W * 1.5 );
		blendMode = BlendMode.ADD;

		var p = MapView.tileBottom( pos );
		x = p.x;
		y = p.y - MapView.H / 2;
		MapView.instance.addChild( this );

		scaleX = scaleY = 0;
		Updater.tick.add( onExpand );
	}

	private function onExpand( elapsed:Float ):Void {
		if ((alpha -= elapsed * 4) <= 0) {
			parent.removeChild( this );
			Updater.tick.remove( onExpand );
		} else {
			scaleX = scaleY = 1 - alpha;
		}
	}
}
