package com.watabou.switchhook.ui;

import com.watabou.switchhook.utils.Sound;
import openfl.display.GradientType;
import openfl.events.MouseEvent;
import openfl.geom.Matrix;

class Button extends View {

	private var label : String;
	private var color : Int;
	private var text : BitmapText;

	public function new( label:String, color:Int ) {

		this.label = label;
		this.color = color;

		super();

		buttonMode = true;
		addEventListener( MouseEvent.CLICK, onClickHandler );
	}

	override private function createChildren():Void {
		text = new BitmapText( SwitchHook.fontNormal, label );
		addChild( text );
	}

	override private function layout():Void {
		text.x = Std.int( (rWidth - text.width) / 2 );
		text.y = Std.int( (rHeight - text.baseLine()) / 2 );

		var m = new Matrix();
		m.createGradientBox( rWidth, rHeight, 0 );

		graphics.clear();
		graphics.beginGradientFill( GradientType.LINEAR, [color,color,color], [0,0.5,0], [0,128,255], m );
		graphics.drawRect( 0, 0, rWidth, rHeight );
	}

	private function onClickHandler( e:MouseEvent ):Void {
		Sound.play( "click" );
		onClick();
	}

	public function onClick():Void {
	}
}
