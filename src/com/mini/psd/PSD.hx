package com.mini.psd;
import com.mini.Msprite;
import haxe.xml.Fast;
import nme.display.BitmapData;
import nme.Assets;

class PSD extends Msprite
{
	public static var path:String = "img";
	
	var folder:String;
	var elems:Hash<Msprite>;
	public var bgColor:Int = 0x000000;
	public var frameColor:Int = 0xFFFFFF;
	public var realWidth:Float;
	public var realHeight:Float;
	public var originalW:Float;
	public var originalH:Float;
	
	public function new() {
		super();
	}	
	
	public var cur_pxRatio:Float;
	
	public function load(f:String,xml:String):Void {

		folder = f;
		cur_pxRatio = 1;
		elems = new Hash<Msprite>();
		var root:Fast = new Fast(Xml.parse(Assets.getText(path+"/"+folder+"/"+xml)));
		var psd:Fast = root.node.data;
		
		bgColor = Std.parseInt(psd.att.bgColor);
		frameColor = Std.parseInt(psd.att.frameColor);		
		realHeight = Std.parseFloat(psd.att.height);
		realWidth = Std.parseFloat(psd.att.width);
		originalH = realHeight;
		originalW = realWidth;
		parseNode(psd, this);		
		initAnchors();
	}
	
	function parseNode(_node:Fast,parent:Msprite):Void {
		for (n in _node.nodes.folder) {
			var s:Msprite = new Msprite();
			add(n.att.name,s,parent);
			if(n.x.elementsNamed("layer")!=null)loadFrames(s,n);
			s.x = Std.parseFloat(n.att.x);
			s.y = Std.parseFloat(n.att.y);
			parseNode(n,s);
		}
	}
	
	function loadFrames(s:Msprite, n:Fast):Void {
		var frames:Array<Int> = new Array<Int>();
		var cur = 0;
		for (i in n.nodes.layer) {
			var url =  i.att.link;
			s.paths.push(url);
			s.addFrame(getBitmapData(url));
			frames.push(cur);
			cur++;
		}		
		s.addAnim("default", frames, 50, true);
		s.setAnim("default");
		s.pause();
	}
	
	public function add(name:String,s:Msprite,parent:Msprite):Void {
		s.name = name;
		parent.addChild(s);
		elems.set(name, s);
	}
	
	public function get(name:String):Msprite {
		return elems.get(name);
	}
	
	function initAnchors():Void {
		for (e in elems) e.centerAnchor();
	}
	inline function getBitmapData(url:String):BitmapData {
		return Assets.getBitmapData(path + "/" + folder + "/" + url, false);
	}
	
	override public function dispose():Void 
	{
		for (e in elems.keys()) {
			var c:Msprite = elems.get(e);
			c.dispose();
			c = null;
			elems.remove(e);
		}
		super.dispose();
	}
	
}