package com.watabou.switchhook.effects;

import com.watabou.switchhook.geography.HexMap;
import com.watabou.switchhook.ui.MapView;
import openfl.display.BitmapData;
import openfl.display.Shape;

class FogOfWar extends Shape {

	private static var colors : BitmapData;

	private var vertices	: Array<Float>;
	private var indices		: Array<Int>;
	private var uvData		: Array<Float>;

	public function new() {
		super();

		if (colors == null) {
			colors = new BitmapData( 2, 2, true, 0 );
			colors.setPixel32( 0, 0, 0xFF000000 );
			colors.setPixel32( 1, 0, 0x80000000 );
			colors.setPixel32( 0, 1, 0x80000000 );
			colors.setPixel32( 1, 1, 0x00000000 );
		}

		vertices = [];
		indices = [];
		uvData = [];

		var i = 0;
		for (k in 0...HexMap.LENGTH) {
			if (Game.level.abris.data[k]) {
			var p = MapView.tileBottom( k );
				vertices.push( p.x );
				vertices.push( p.y - MapView.H / 2 );

					vertices.push( p.x - MapView.W / 4 );
					vertices.push( p.y - MapView.N / 2 );
				vertices.push( p.x - MapView.W / 2 );
				vertices.push( p.y - MapView.N );
					vertices.push( p.x - MapView.W / 2 );
					vertices.push( p.y - MapView.H / 2 );
				vertices.push( p.x - MapView.W / 2);
				vertices.push( p.y - MapView.H + MapView.N  );
					vertices.push( p.x - MapView.W / 4 );
					vertices.push( p.y - MapView.H + MapView.N / 2 );
				vertices.push( p.x );
				vertices.push( p.y - MapView.H );
					vertices.push( p.x + MapView.W / 4 );
					vertices.push( p.y - MapView.H + MapView.N / 2 );
				vertices.push( p.x + MapView.W / 2 );
				vertices.push( p.y - MapView.H + MapView.N );
					vertices.push( p.x + MapView.W / 2);
					vertices.push( p.y - MapView.H / 2 );
				vertices.push( p.x + MapView.W / 2 );
				vertices.push( p.y - MapView.N );
					vertices.push( p.x + MapView.W / 4 );
					vertices.push( p.y - MapView.N / 2 );
				vertices.push( p.x );
				vertices.push( p.y );

				uvData.push( 1 );
				uvData.push( 1 );
				for (j in 0...12) {
					uvData.push( 0 );
					uvData.push( 1 );

				/*	indices.push( i * 13 );
					indices.push( i * 13 + 1 + j );
					indices.push( i * 13 + 1 + (j + 1) % 12 );*/
				}
				for (j in 0...6) {
					indices.push( i * 13 );
					indices.push( i * 13 + 1 + (j * 2 + 0) );
					indices.push( i * 13 + 1 + (j * 2 + 2) % 12 );

					indices.push( i * 13 + 1 + (0 + j * 2) % 12 );
					indices.push( i * 13 + 1 + (1 + j * 2) % 12 );
					indices.push( i * 13 + 1 + (2 + j * 2) % 12 );
				}
				i++;
			}
		}
	}

	public function update():Void {

		cacheAsBitmap = false;

		var vst = Game.visited.data;
		var vsb = Game.visible.data;

		function setVertex( hexIndex:Int, vertexIndex:Int, pos:Int, refs:Array<Int> ):Void {
			var visible = vsb[pos];
			var visited = vst[pos];
			for (r in refs) {
				var rr = pos + r;
				visible = visible && vsb[rr];
				visited = visited && vst[rr];
			}
			var ofs = hexIndex * 26 + vertexIndex * 2;
			if (visible) {
				uvData[ofs] = 1;
				uvData[ofs + 1] = 1;
			} else if (visited) {
				uvData[ofs] = 0;
				uvData[ofs + 1] = 1;
			} else {
				uvData[ofs] = 0;
				uvData[ofs + 1] = 0;
			}
		}

		var j = 0;
		for (i in 0...HexMap.LENGTH) {
			if (Game.level.abris.data[i]) {
				setVertex( j, 0, i,	[] );

				setVertex( j, 1, i,		[ HexMap.SIZE - 1] );
				setVertex( j, 2, i,		[ HexMap.SIZE - 1, -1] );
				setVertex( j, 3, i,		[-1] );
				setVertex( j, 4, i,		[-1, -HexMap.SIZE] );
				setVertex( j, 5, i,		[-HexMap.SIZE] );
				setVertex( j, 6, i,		[-HexMap.SIZE, -HexMap.SIZE + 1] );
				setVertex( j, 7, i,		[-HexMap.SIZE + 1] );
				setVertex( j, 8, i,		[-HexMap.SIZE + 1, 1] );
				setVertex( j, 9, i,		[ 1] );
				setVertex( j, 10, i,	[ 1, HexMap.SIZE] );
				setVertex( j, 11, i,	[ HexMap.SIZE] );
				setVertex( j, 12, i,	[ HexMap.SIZE, HexMap.SIZE - 1] );

				j++;
			}
		}

		graphics.clear();
		graphics.beginBitmapFill( colors, null, false, false );
		graphics.drawTriangles( vertices, indices, uvData );

		cacheAsBitmap = true;
	}
}
