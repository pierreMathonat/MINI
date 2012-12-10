package com.mini.states;
import com.eclecticdesignstudio.motion.Actuate;
import com.mini.Msprite;
import com.mini.Screen;
import nme.Assets;
import com.mini.psd.PSDscene;

class UiState extends MState
{
	public function new()
	{
		super();
	}
	
	override private function init():Void 
	{
		scene = Main.ui;
		scene.resizeMode = ResizeMode.FIT_HORIZONTAL;
		
		Main.cars.paused = true;
		Main.bg.visible = false;
		Main.scene.visible = false;
		Main.frame.visible = false;
		Main.cars.visible = false;
	}
	
	override public function exit():Void 
	{
		Main.cars.paused = false;
		Main.scene.visible = true;
		Main.bg.visible = true;
		Main.frame.visible = true;
		Main.cars.visible = true;
		super.exit();
	}
}