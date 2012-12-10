package com.mini;
import com.eclecticdesignstudio.motion.Actuate;
import nme.media.SoundTransform;
import nme.events.Event;
import nme.events.TimerEvent;
import nme.media.Sound;
import nme.media.SoundChannel;
import nme.utils.Timer;

/**
 * ...
 * @author pierre
 */

class Msound
{
	
	public var sound:Sound;
	public var channel:SoundChannel;
	public var transform:SoundTransform;
	var _pan:Float;
	public var pan(getPan, setPan):Float;
	var _volume:Float;
	public var volume(getVolume, setVolume):Float;
	
	public var isPlaying:Bool;
	public var name:String;
	
	public var onComplete:Void->Void;
	
	public function new(s:Sound) 
	{
		sound = s;
		transform = new SoundTransform(1,0);
		isPlaying = false;
		volume = 1;
		pan = 0;
	}
	
	var numloops:Int=0;
	var curloops:Int=0;

	public function play(loops:Int = 1, startTime:Float = 0 ):Void {
		if (isPlaying) return;
		numloops = loops;
		curloops = 0;
		isPlaying = true;
		channel = sound.play();
		channel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
	}
	
	
	var debug:Bool = false;
	function soundComplete(?e:Event):Void {
		curloops++;		
		if (numloops == -1) {
			if(debug)trace(name +" =>infinite loop"+curloops);
			loop();
		}
		else if (curloops<=numloops) {
			if(debug)trace(name +" =>loop"+curloops);
			loop();
		}else {
			if(debug)trace(name +" =>stop"+curloops);
			stop();	
			if (onComplete != null) onComplete();
		}
	}
	
	function loop():Void {
		channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
		isPlaying = true;
		channel = sound.play(0, 1, transform);
		channel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
	}
	
	public function stop():Void {
		if (channel != null) {
			channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			channel.stop();
			channel = null;
		}
		
		curloops = 0;
		numloops = 0;
		
		isPlaying = false;
	}
	
	public function dispose():Void {
		stop();
		sound = null;
		transform = null;
	}
	
	function getPan():Float { return transform.pan; }
	function setPan(v:Float):Float {
		_pan = v;
		transform.pan = _pan;
		if (isPlaying) {
			channel.soundTransform = transform;
		}
		return _pan;
	}
	
	function getVolume():Float { return transform.volume;}
	function setVolume(v:Float):Float {
		_volume = v;
		transform.volume = _volume;
		if (isPlaying) {
			channel.soundTransform = transform;
		}
		return _volume;
	}
	

	public function fadeIn(time:Float):Void {
		volume = 0;
		Actuate.stop(this);
		Actuate.tween(this, time, { volume:1 } );
	}
	
	public function fadeOut(time:Float):Void {
		Actuate.stop(this);
		Actuate.tween(this, time, { volume:0 } );
	}
	
}