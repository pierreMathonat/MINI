package com.engine.core;
	
	class Anim 
	{
		
		public var lastFrameTime:Int;
		public var name:String;
		public var length:Int;
		public var row:Int;
		public var delay:Int;
		public var loop:Int;
		
		public function new(Name:String="", Length:Int=1, Row:Int=0, Delay:Int = 100, Loop:Int = 1 ) {
			// constructor code
			name=Name;
			length=Length;
			row=Row;
			delay = Delay;
			loop = Loop;
		}

	}
