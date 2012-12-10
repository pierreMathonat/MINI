package com.mini;
import nme.display.Stage;
import nme.Lib;

class Screen
{	
	public inline static var DEV_ANDROID:String 		= "android device";
	public inline static var DEV_COMPUTER:String 		= "computer";
	public inline static var DEV_IPHONE_4:String 		= "iphone 4";
	public inline static var DEV_IPHONE_5:String 		= "iphone 5";
	public inline static var DEV_IPAD:String 			= "ipad 1&2";
	public inline static var DEV_IPAD_RETINA:String 	= "ipad retina";
	
	public inline static var OS_DESKTOP:String 			= "desktop";
	public inline static var OS_BROWSER:String 			= "browser";
	public inline static var OS_IOS:String 				= "ios";
	public inline static var OS_ANDROID:String 			= "android";
	
	public inline static var RES_IPHONE_4:String 		= "960x640";
	public inline static var RES_IPHONE_5:String 		= "1136x640";
	public inline static var RES_IPAD:String 			= "1024x768";
	public inline static var RES_IPAD_RETINA:String 	= "2048x1536";
	
	public inline static var AR_QUATRE_TIERS:Float 		= 4 / 3;
	public inline static var AR_SEIZE_DIX:Float 		= 16 / 10;
	public inline static var AR_SEIZE_NEUF:Float 		= 16 / 9;
	public inline static var AR_SEIZE_HUIT:Float 		= 2;
	
	
	public static var screenW:Float;
	public static var screenH:Float;
	public static var aspectRatio:Float;
	public static var supportedAspectRatio:Bool;
	
	public static var resolution:String;
	public static var os:String;
	public static var device:String;
	
	public static var resizable:Bool;
	
	public static var bitmapSmoothing:Bool;
	
	public static function resize():Void 
	{
		screenW = Application.STAGE.stageWidth;
		screenH = Application.STAGE.stageHeight;
		aspectRatio = screenW / screenH;
		
		resolution = screenW + "x" + screenH;
		
		detectOs();
		detectDevice();
		
		if (aspectRatio > AR_SEIZE_HUIT || aspectRatio < AR_QUATRE_TIERS) 
			supportedAspectRatio = false 
		else 
			supportedAspectRatio = true;
		
		//trace("OS::" + os + " DEVICE::" + device + " RATIO::" + aspectRatio + " =>SUPPORTED_RATIO::" + supportedAspectRatio+" RESIZABLE::"+resizable);
	}
	
	public static function detectOs():Void 
	{
		bitmapSmoothing = false;
		
		#if flash
		os = OS_BROWSER;
		resizable = true;
		bitmapSmoothing = true;
		#end
		
		#if desktop
		os = OS_DESKTOP;
		resizable = true;
		bitmapSmoothing = true;
		#end
		
		#if ios
		os = OS_IOS;
		resizable = false;
		#end
		
		#if android
		os = OS_ANDROID;
		resizable = false;
		#end
	}
	
	public static function detectDevice():Void
	{
		switch(os)
		{
			case OS_IOS:
				switch(resolution)
				{
					case RES_IPAD_RETINA: 
						device = DEV_IPAD_RETINA;
					case RES_IPAD: 
						device = DEV_IPAD;
					case RES_IPHONE_5: 
						device=DEV_IPHONE_5;
					case RES_IPHONE_4: 
						device=DEV_IPHONE_4;
				}
			case OS_BROWSER:
				device = DEV_COMPUTER;
			case OS_DESKTOP:
				device = DEV_COMPUTER;
			case OS_ANDROID:
				device = DEV_ANDROID;
		}
	}
}