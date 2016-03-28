package com.watabou.switchhook.ui;

import com.watabou.switchhook.actors.Actor;
import com.watabou.switchhook.utils.Updater;
import openfl.Assets;
import openfl.display.Shape;
import openfl.display.Tilesheet;
import openfl.geom.Rectangle;

class HealthIndicator extends View {

	private var actor	: Actor;

	private var tilesheet	: Tilesheet;
	private var unitSize	: Int;

	private var lastHP	: Int;

	public function new( actor:Actor ) {

		super();

		this.actor = actor;

		Game.hero.health.add( onHealth );
		update( actor.hp, actor.ht );
	}

	override private function createChildren():Void {
		var bmp = Assets.getBitmapData( "health" );
		tilesheet = new Tilesheet( bmp );
		unitSize = Std.int( bmp.width / 2 );
		tilesheet.addTileRect( new Rectangle( 0, 0, unitSize, bmp.height ) );
		tilesheet.addTileRect( new Rectangle( unitSize, 0, unitSize, bmp.height ) );
	}

	private function onHealth():Void {
		for (i in actor.hp...lastHP) {
			addBrokenShard( i );
		}
		update( actor.hp, actor.ht );
	}

	private function update( hp, ht ):Void {
		graphics.clear();

		var data:Array<Float> = [];
		for (i in 0...hp) {
			data.push( (unitSize - 1) * i );
			data.push( 0 );
			data.push( 0 );
		}
		for (i in hp...ht) {
			data.push( (unitSize - 1) * i );
			data.push( 0 );
			data.push( 1 );
		}

		tilesheet.drawTiles( graphics, data );

		lastHP = hp;
	}

	private function addBrokenShard( index:Int ):Void {
		var shard = new BrokenShard();
		tilesheet.drawTiles( shard.graphics, [-unitSize / 2, -unitSize / 2, 0], true );
		shard.x = index * (unitSize - 1) + unitSize / 2;
		shard.y = unitSize / 2;
		addChild( shard );
	}
}

private class BrokenShard extends Shape {
	public function new() {
		super();
		Updater.tick.add( onFade );
	}

	private function onFade( elapsed:Float ):Void {
		if ((alpha -= elapsed) <= 0) {
			parent.removeChild( this );
			Updater.tick.remove( onFade );
		} else {
			scaleX = scaleY = 4 - alpha * 3;
		}
	}
}
