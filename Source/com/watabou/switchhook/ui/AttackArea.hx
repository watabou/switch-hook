package com.watabou.switchhook.ui;

import com.watabou.switchhook.actors.Monster;
import com.watabou.switchhook.geography.HexMap;
import openfl.Assets;
import openfl.display.Shape;
import openfl.display.Tilesheet;
import openfl.geom.Point;

class AttackArea extends Shape {

	private var map : HexMap = new HexMap();

	private var tilesheet : Tilesheet;

	public function new() {
		super();

		var bmp = Assets.getBitmapData( "attack" );
		tilesheet = new Tilesheet( bmp );
		tilesheet.addTileRect( bmp.rect, new Point( bmp.width / 2, bmp.height ) );
	}

	public function update( a:Monster ):Void {
		graphics.clear();

		if (a == null) {
			return;
		}

		var data:Array<Float> = [];
		a.getAttackArea( map );

		for (i in 0...HexMap.LENGTH) {
			if (map.data[i]) {
				var p = MapView.tileBottom( i );
				data.push( p.x );
				data.push( p.y );
				data.push( 0 );
			}
		}

		tilesheet.drawTiles( graphics, data );
	}
}
