package com.watabou.switchhook.ui;

//import com.watabou.switchhook.effects.FogOfWar;
import com.watabou.switchhook.actors.Actor;
import com.watabou.switchhook.actors.Monster;
import com.watabou.switchhook.actors.actions.Input;
import com.watabou.switchhook.geography.Hex;
import com.watabou.switchhook.geography.HexMap;
import com.watabou.switchhook.locations.Location;
import com.watabou.switchhook.sprites.GameSprite;
import openfl.Assets;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.display.Tilesheet;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import msignal.Signal.Signal1;

class MapView extends Sprite {

	public static inline var W	: Int = 32;
	public static inline var H	: Int = 36;
	public static inline var N	: Int = 8;

	public static var instance	: MapView;

	private var tilesheet	: Tilesheet;
	private var empty	: Int;
	private var wall	: Int;
	private var emptyHd	: Int;
	private var wallHd	: Int;

	private var tiles	: Array<Bool> = [];

	private var fov		: Sprite;
	private var attack	: AttackArea;
	private var locs	: Sprite;
	private var mobs	: Sprite;
//	private var fog	: FogOfWar;

	private static var lastTileset	: Int = -1;

	public var click : Signal1<Int> = new Signal1<Int>();

	public function new() {

		instance = this;
		super();

		var tileset:Int;
		if (Game.theme == -1) {
			switch (Game.stage) {
				case 17:
					Game.theme = 1;
				case 18:
					Game.theme = 2;
				case 19:
					Game.theme = 0;
				case 20:
					Game.theme = 3;
				default:
					do {
						Game.theme = Std.int( 4 * Math.random() );
					} while (Game.theme == lastTileset);
			}
		}
		tilesheet = new Tilesheet( Assets.getBitmapData( "tiles" + Game.theme ) );
		lastTileset = Game.theme;

		empty	= tilesheet.addTileRect( new Rectangle( 0, 0, W, H ), new Point( W / 2, H ) );
		wall	= tilesheet.addTileRect( new Rectangle( W, 0, W, H ), new Point( W / 2, H ) );
		emptyHd	= tilesheet.addTileRect( new Rectangle( W*2, 0, W, H ), new Point( W / 2, H ) );
		wallHd	= tilesheet.addTileRect( new Rectangle( W*3, 0, W, H ), new Point( W / 2, H ) );

		fov = new Sprite();
		addChild( fov );

		attack = new AttackArea();
		addChild( attack );

		//	fog = new FogOfWar();
		//	addChild( fog );

		locs = new Sprite();
		addChild( locs );

		mobs = new Sprite();
		addChild( mobs );
	}

	public function updateVisibility():Void {
		fov.graphics.clear();

		var fData:Array<Float> = [];
		var mData:Array<Float> = [];

		var visited = Game.visited.data;
		var visible = Game.visible.data;
		for (i in 0...HexMap.LENGTH) {
			if (visited[i]/* && Game.level.abris.data[i]*/) {
				var p = tileBottom( i );
				if (visible[i]) {
					fData.push( p.x );
					fData.push( p.y );
					fData.push( Game.level.walls.data[i] ? wall : empty );
				}
				if (!tiles[i]) {
					createTile( i, p, Game.level.empty.data[i] );
					mData.push( p.x );
					mData.push( p.y );
					mData.push( Game.level.walls.data[i] ? wallHd : emptyHd );
				}
			}
		}

		tilesheet.drawTiles( fov.graphics, fData );
		tilesheet.drawTiles( graphics, mData );

	//	fog.update();
	}

	private function createTile( index:Int, p:Point, interactive:Bool ):Void {
		var tile = new Sprite();
		if (interactive) {
			tile.graphics.beginFill( 0, 0 );
			tile.graphics.lineTo( -W/2, -N );
			tile.graphics.lineTo( -W/2, -H+N );
			tile.graphics.lineTo( 0, -H );
			tile.graphics.lineTo( W/2, -H+N );
			tile.graphics.lineTo( W/2, -N );
			tile.graphics.lineTo( 0, 0 );
			tile.x = p.x;
			tile.y = p.y;
			tile.buttonMode = true;
			tile.addEventListener( MouseEvent.CLICK, function( e:MouseEvent ):Void {
				showAttackArea( Game.hero.pos );
				click.dispatch( index );
			} );
			tile.addEventListener( MouseEvent.MOUSE_OVER, function( e:MouseEvent ):Void {
				onOver( index, true );
			} );
			tile.addEventListener( MouseEvent.MOUSE_OUT, function( e:MouseEvent ):Void {
				onOver( index, false );
			} );
			tile.addEventListener( MouseEvent.RIGHT_CLICK, function( e:MouseEvent ):Void {
				if (Input.instance != null) {
					showAttackArea( index );
				}
			} );
			addChild( tile );
		}

		tiles[index] = true;
	}

	public function getTilesBounds():Rectangle {
		var minX = Math.POSITIVE_INFINITY;
		var minY = Math.POSITIVE_INFINITY;
		var maxX = Math.NEGATIVE_INFINITY;
		var maxY = Math.NEGATIVE_INFINITY;
		for (i in 0...HexMap.LENGTH) {
			if (tiles[i]) {
				var p = tileBottom( i );
				if (p.x < minX) {
					minX = p.x;
				}
				if (p.y < minY) {
					minY = p.y;
				}
				if (p.x > maxX) {
					maxX = p.x;
				}
				if (p.y > maxY) {
					maxY = p.y;
				}
			}
		}
		return new Rectangle( minX - W/2, minY-H, maxX - minX + W, maxY - minY + H );
	}

	private function onOver( pos:Int, show:Bool ):Void {
		var a = Actor.get( pos );
		if (a != null && a.sprite.health != null) {
			a.sprite.health.visible = show || a.hp < a.ht;
		}
	}

	private function showAttackArea( pos:Int ):Void {
		if (Game.visible.data[pos]) {
			var a = Actor.get( pos );
			if (Std.is( a, Monster )) {
				attack.update( cast(a, Monster) );
			} else {
				attack.update( null );
			}
		}
	}

	public static function tileBottom( index:Int ):Point {
		if (index == -1) {
			return null;
		}

		var hex = Hex.unpack( index );
		return new Point(
			hex.q * W + hex.r * W/2 + W/2,
			hex.r * (H - N) + H
		);
	}

	public static function tileBottomUP( hex:Hex ):Point {
		return new Point(
			hex.q * W + hex.r * W/2 + W/2,
			hex.r * (H - N) + H
		);
	}

	public function addActor( a:Actor ):Void {
		var p:Point = tileBottom( a.pos );
		a.sprite.x = p.x;
		a.sprite.y = p.y;
		mobs.addChild( a.sprite );
	}

	public function addLocation( loc:Location ):Void {
		var p:Point = tileBottom( loc.pos );
		loc.sprite.x = p.x;
		loc.sprite.y = p.y;
		locs.addChild( loc.sprite );
	}
}
