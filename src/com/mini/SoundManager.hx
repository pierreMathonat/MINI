package com.mini;
import com.eclecticdesignstudio.motion.Actuate;
import haxe.xml.Fast;
import nme.Assets;
import nme.events.Event;
import nme.events.TimerEvent;
import nme.media.Sound;
import nme.media.SoundChannel;
import nme.media.SoundTransform;
import nme.utils.Timer;


class SoundManager 
{
	
	var path = "snd";
	var Sounds:Hash<Msound>;
		
	public function new() 
	{
		Sounds = new Hash<Msound>();
	}
	
	public function load(url:String):Void {
		var xml:Fast = new Fast(Xml.parse(Assets.getText(path+"_scenes" + "/" + url))).node.data;
		for (sound in xml.nodes.sound) {
			add(sound.att.name, sound.att.path);
		}
	}
	
	public function add(name:String, url:String) {
		#if flash
		var ext = ".mp3";
		#else
		var ext = ".wav";
		#end
		var s = new Msound(Assets.getSound(path + "/" + url + ext));
		s.name = name;
		Sounds.set(name, s);
	}
	
	public function play(name:String, time:Float=0, loop:Int=0):Void {
		if (!Sounds.exists(name)) return;
		Sounds.get(name).play(loop,time);
	}
	
	public function stop(name:String):Void {
		Sounds.get(name).stop();
	}

	
	public function closeAll():Void {
		for (s in Sounds) {
			s.dispose();
		}
		Sounds = new Hash<Msound>();
	}
	
	public function sound(name:String):Msound {
		return Sounds.get(name);
	}
	
	public function transform(name:String, pan:Float=0, volume:Float=1 ) {
		var s = Sounds.get(name);
		s.pan = pan;
		s.volume = volume;
	}
	
	var onComplete:Void->Void;
	
	public function fadeIn(sound:String, time:Float):Void {
		var s = Sounds.get(sound).fadeIn(time);
	}
	public function fadeOut(sound:String, time:Float):Void {
		var s = Sounds.get(sound).fadeIn(time);
	}
	public function fadeInAll(time:Float,_onComplete:Void->Void=null):Void {
		for (s in Sounds) s.fadeIn(time);
		if(_onComplete!=null)Actuate.timer(time).onComplete(_onComplete);
	}
	
	public function fadeOutAll(time:Float,_onComplete:Void->Void=null):Void {
		for (s in Sounds) s.fadeOut(time);
		if(_onComplete!=null)Actuate.timer(time).onComplete(_onComplete);
	}

}