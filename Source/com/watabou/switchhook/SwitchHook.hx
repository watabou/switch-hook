package com.watabou.switchhook;

import com.watabou.switchhook.actors.Actor;
import com.watabou.switchhook.geography.HexMap;
import com.watabou.switchhook.scenes.GameScene;
import com.watabou.switchhook.scenes.Scene;
import com.watabou.switchhook.scenes.TitleScene;
import com.watabou.switchhook.ui.BitmapFont;
import com.watabou.switchhook.ui.Fader;
import com.watabou.switchhook.ui.MapView;
import com.watabou.switchhook.ui.View;
import com.watabou.switchhook.utils.Updater;
import openfl.events.Event;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;

class SwitchHook extends View {

	public static var instance : SwitchHook;
	
	private var curScene	: Scene;
	private var fader		: Fader;

	public static var fontTitle		: BitmapFont;
	public static var fontSmall		: BitmapFont;
	public static var fontNormal	: BitmapFont;

	public function new () {

		instance = this;

		super ();

		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.addEventListener( Event.RESIZE, function( e:Event ) {
			layout();
		} );

		fontTitle = new BitmapFont( "font", "LEVL0123456789" );
		fontTitle.tracking = 2;

		fontSmall = new BitmapFont( "font_small", BitmapFont.LATIN_FULL );
		fontSmall.baseLine = 14;
		fontSmall.tracking = -1;

		fontNormal = new BitmapFont( "font_normal", BitmapFont.LATIN_FULL );
		fontNormal.baseLine = 17;
		fontNormal.tracking = -2;

		Updater.useEnterFrame( this );

		fader = new Fader();
		addChild( fader );

		switchScene( TitleScene );
	}

	override private function layout():Void {

		var maxW = HexMap.SIZE * MapView.W + (HexMap.SIZE - 1) * MapView.W / 2;
		var maxH = HexMap.SIZE * (MapView.H - MapView.N) + MapView.N;

		scaleX = scaleY = Math.floor( Math.min( stage.stageWidth / maxW, stage.stageHeight / maxH ) );
		if (scaleX == 0) {
			scaleX = scaleY = 1;
		}

		var w = stage.stageWidth / scaleX;
		var h = stage.stageHeight / scaleY;
		fader.setSize( w, h );
		curScene.setSize( w, h );
	}

	public function switchScene( sceneClass:Class<Scene> ):Void {

		Updater.reset();

		if (curScene != null) {

			fader.fadeOut();
			fader.complete.addOnce( function():Void {
				removeChild( curScene );
				curScene = null;
				switchScene( sceneClass );
			} );

		} else {

			curScene = Type.createInstance( sceneClass, [] );
			addChildAt( curScene, 0 );
			layout();

			stage.focus = stage;

			fader.fadeIn();
		}
	}

	public function restart():Void {

		Actor.reset();

		Game.newGame();
		Game.newLevel();
		switchScene( GameScene );
	}

	public function loadGame():Void {

		Actor.reset();

		Game.load();
		switchScene( GameScene );
	}
}