package com.mini.states;
import com.mini.Application;
import com.mini.display.Display;
import nme.events.Event;

class Fsm extends Display
{
	public var cur_state:State;
	public var old_state:State;
	var next_state:State;
	public var owner:Dynamic;
	
	public function new(init:State,global:State=null) {
		super();
		enterState(init);
	}
	
	override public function update():Void {
		//trace("FSM::UPDATE");
		if (cur_state != null) cur_state.update();
	}
	
	public function enterState(?s:State, backTo:Bool = false):Void {
		
		if (s == null) {
			if(hasOldState)backToOldState();
			return;
		} else {
			if (backTo) setOldState();
			setNewState(s);
		}
	}
	
	function setNewState(s:State):Void {
		if(cur_state!=null)cur_state.exit();
		cur_state = s;
		cur_state.fsm = this;
		cur_state.enter();
	}
	
	function setOldState():Void {
		if (hasOldState) return;
		cur_state.pause();
		old_state = cur_state;
		cur_state = null;
		hasOldState = true;
	}
	
	var hasOldState:Bool;
	function backToOldState():Void {
		if (cur_state != null) cur_state.exit();
		old_state.play();
		cur_state = old_state;
		old_state = null;
		hasOldState = false;
	}
	
	public function resetState():Void {
		cur_state.exit();
		cur_state.enter();
	}
}

class State
{
	public var fsm:Fsm;
	public var type:String;
	public function new() { type = Type.getClassName(Type.getClass(this)); }
	public function enter():Void { }
	public function update():Void { }
	public function exit():Void { }
	public function pause():Void { }
	public function play():Void { }
}