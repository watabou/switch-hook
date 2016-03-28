package com.watabou.switchhook.ui;

import openfl.display.Sprite;
import openfl.events.Event;

class View extends Sprite {

	private var rWidth	: Float = 0;
	private var rHeight	: Float = 0;

	public function new() {
		super();
		createChildren();

		addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage );
	}

	private function createChildren():Void {
	}

	private function layout():Void {
	}

	public function setSize( w:Float, h:Float ):Void {
		rWidth = w;
		rHeight = h;
		layout();
	}

	#if !flash
	override function get_width():Float {
		return rWidth;
	}

	override function set_width( value:Float ):Float {
		setSize( value, height );
		return rWidth;
	}

	override function get_height():Float {
		return rHeight;
	}

	override function set_height( value:Float ):Float {
		setSize( width, value );
		return rHeight;
	}
	#end

	public var right( get, never ): Float;
	private function get_right():Float {
		return x + width;
	}

	public var bottom( get, never ): Float;
	private function get_bottom():Float {
		return y + height;
	}

	private function onAdded():Void {
	}

	private function onRemoved():Void {
	}

	private function onAddedToStage( e:Event ):Void {
		onAdded();
	}

	private function onRemovedFromStage( e:Event ):Void {
		onRemoved();
	}
}
