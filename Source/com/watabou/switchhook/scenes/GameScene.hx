package com.watabou.switchhook.scenes;

import com.watabou.switchhook.actors.Actor;
import com.watabou.switchhook.actors.actions.Input;
import com.watabou.switchhook.geography.Hex;
import com.watabou.switchhook.geography.HexMap;
import com.watabou.switchhook.sprites.ActorSprite;
import com.watabou.switchhook.ui.BitmapText;
import com.watabou.switchhook.ui.HealthIndicator;
import com.watabou.switchhook.ui.MapView;
import com.watabou.switchhook.ui.RestartButton;
import com.watabou.switchhook.ui.VictoryBanner;
import com.watabou.switchhook.utils.Updater;
import openfl.display.DisplayObject;
import openfl.geom.Rectangle;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;

class GameScene extends Scene {

	public static var instance	: GameScene;

	private var mapView : MapView;
	private var title	: BitmapText;
	private var message	: BitmapText;
	private var messDel : Float;
	private var restart	: RestartButton;
	private var banner	: VictoryBanner;

	public function new() {
		instance = this;
		super();

		Actor.reset();

		for (loc in Game.level.locs) {
			if (loc.sprite != null) {
				loc.sprite.visible = Game.visited.data[loc.pos];
				mapView.addLocation( loc );
			}
		}

		Actor.add( Game.hero );

		for (mob in Game.level.mobs) {
			Actor.add( mob );
			mob.sprite.displayed = false;
			mapView.addActor( mob );
		}

		Game.hero.place( Game.hero.pos );

		Actor.process();

		if (Game.stage == 1) {
			showMessage( "Welcome to the Dungeons of Doom!" );
		} else if (Game.loaded) {
			showMessage( "Welcome back to the Dungeons of Doom!" );
		} else {
			if (Game.genocide) {
				showMessage( "You have killed all monsters on the previous level" );
			} else if (Game.pacifism) {
				showMessage( "You haven't killed a single monster on the previous level" );
				Game.hero.hp++;
			}
			if (Game.hero.hp < Game.hero.ht) {
				Game.hero.hp++;
			}
			Game.hero.health.dispatch();
		}
	}

	override private function createChildren():Void {
		mapView = new MapView();
		mapView.click.add( onClick );
		addChild( mapView );

		var health:HealthIndicator = new HealthIndicator( Game.hero );
		health.x = 8;
		health.y = 8;
		addChild( health );

		title = new BitmapText( SwitchHook.fontTitle, "LEVEL " + Game.stage );
		addChild( title );

		message = new BitmapText( SwitchHook.fontNormal );
		addChild( message );
	}

	override private function layout():Void {
		var r = mapView.getTilesBounds();
		mapView.x = Std.int( (rWidth - r.width) / 2 - r.left );
		mapView.y = Std.int( (rHeight - r.height) / 2 - r.top );

		r = Game.hero.sprite.getRect( this );
		r.inflate( MapView.W, MapView.H );
		if (r.left < 0) {
			mapView.x -= r.left;
		} else if (r.right > rWidth) {
			mapView.x -= (r.right - rWidth);
		}
		if (r.top < 0) {
			mapView.y -= r.top;
		} else if (r.bottom > rHeight) {
			mapView.y -= (r.bottom - rHeight);
		}

		title.x = rWidth - title.width - 8;
		title.y = 8;

		message.x = Std.int( (rWidth - message.width) / 2 );
		message.y = rHeight - message.height;

		if (restart != null) {
			restart.x = (width - restart.width) / 2;
			restart.y = height - restart.height - 8;
		}

		if (banner != null) {
			banner.setSize( rWidth, rHeight );
		}
	}

	public function updateVisibility():Void {

		var fov = Game.visible.data;

		mapView.updateVisibility();

		for (mob in Game.level.mobs) {
			mob.sprite.displayed = fov[mob.pos];
		}

		for (loc in Game.level.locs) {
			if (loc.sprite != null) {
				loc.sprite.visible = loc.sprite.visible || fov[loc.pos];
			}
		}
	}

	public function showAll():Void {
		for (i in 0...HexMap.LENGTH) {
			if (Game.level.abris.data[i]) {
				Game.visible.data[i] = false;
				Game.visited.data[i] = true;
			}
		}

		for (dir in Hex.DIRS) {
			Game.visible.data[Hex.offsetPacked( Game.hero.pos, dir )] = true;
		}
		Game.visible.data[Game.hero.pos] = true;

		for (loc in Game.level.locs) {
			if (loc.sprite != null) {
				loc.sprite.visible = true;
			}
		}

		updateVisibility();
	}

	public function addTryButton():Void {
		restart = new RestartButton();
		restart.x = (width - restart.width) / 2;
		restart.y = height - restart.height - 8;
		addChild( restart );
	}

	public function addVictoryBanner():Void {
		banner = new VictoryBanner();
		banner.setSize( rWidth, rHeight );
		addChild( banner );
	}

	public function showMessage( text:String ):Void {
		message.text( text );
		message.x = Std.int( (rWidth - message.width) / 2 );
		message.visible = true;
		messDel = 3;

		Updater.tick.add( onFade );
	}

	public function adjustViewport():Void {
		var rect = Game.hero.sprite.getRect( this );
		rect.inflate( MapView.W, MapView.H );
		if (rect.x < 0 || rect.right > rWidth ||
			rect.y < 0 || rect.bottom > rHeight) {
			layout();
		}
	}

	private function onFade( elapsed:Float ):Void {
		if ((messDel -= elapsed) <= 0) {
			message.visible = false;
			Updater.tick.remove( onFade );
		} else {
			message.alpha = messDel;
		}
	}

	private function onClick( pos:Int ):Void {
		if (Input.instance != null) {
			Game.hero.handle( pos );
		}
	}

	override private function onAdded():Void {

		super.onAdded();

		stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
		stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp );
	}

	override private function onRemoved():Void {
		super.onRemoved();

		stage.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
		stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		stage.removeEventListener( KeyboardEvent.KEY_UP, onKeyUp );
	}

	private var mx	: Float;
	private var my	: Float;
	private var dragging	: Bool;

	private function onMouseDown( e:MouseEvent ):Void {
		stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
		stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );

		mx = mouseX;
		my = mouseY;

		dragging = false;
	}

	private function onMouseMove( e:MouseEvent ):Void {

		if (!dragging) {
			if (Math.abs( mouseX - mx ) + Math.abs( mouseY - my ) > 4) {
				dragging = true;
			} else {
				return;
			}
		}

		mapView.mouseChildren = false;

		mapView.x -= (mx - mouseX);
		mapView.y -= (my - mouseY);
		mx = mouseX;
		my = mouseY;
		e.updateAfterEvent();
	}

	private function onMouseUp( e:MouseEvent ):Void {

		mapView.mouseChildren = true;

		stage.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
		stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
	}

	private function onKeyDown( e:KeyboardEvent ):Void {
		if (e.keyCode == Keyboard.SHIFT) {
			for (mob in Game.level.mobs) {
				mob.sprite.health.visible = true;
			}
		} else if (e.keyCode == Keyboard.ESCAPE && !Game.hero.interrupt()) {
			if (Game.hero.isAlive() && !Game.victory) {
				Game.save();
			}
			SwitchHook.instance.switchScene( TitleScene );
		} else if (Input.instance != null) {
			var pos = Game.hero.pos;
			switch (e.keyCode) {
				case Keyboard.A:
					Game.hero.handle( pos - 1 );
				case Keyboard.D:
					Game.hero.handle( pos + 1 );
				case Keyboard.W:
					Game.hero.handle( pos - HexMap.SIZE );
				case Keyboard.E:
					Game.hero.handle( pos - HexMap.SIZE + 1 );
				case Keyboard.Z:
					Game.hero.handle( pos + HexMap.SIZE - 1 );
				case Keyboard.X:
					Game.hero.handle( pos + HexMap.SIZE );
			}
		}
	}

	private function onKeyUp( e:KeyboardEvent ):Void {
		if (e.keyCode == Keyboard.SHIFT) {
			for (mob in Game.level.mobs) {
				mob.sprite.health.visible = mob.hp < mob.ht;
			}
		}
	}

	override private function onExit( code:Int ):Void {
		if (Game.hero.isAlive() && !Game.victory) {
			Game.save();
		}
	}
}
