package com.ancientsheep.particles;

/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */
// ideas taken from:
//	 . The ocean spray in your face Jeff.Lander]
//		http://www.double.co.nz/dust/col0798.pdf
//	 . Building an Advanced Particle System John.van der Burg]
//		http://www.gamasutra.com/features/20000623/vanderburg_01.htm
//   . LOVE game engine
//		http://love2d.org/
//
//
// Radius mode support, from 71 squared
//		http://particledesigner.71squared.com/
//
// IMPORTANT: Particle Designer is supported by cocos2d, but
// 'Radius Mode' in Particle Designer uses a fixed emit rate of 30 hz. Since that can't be guarateed in cocos2d,
//  cocos2d uses a another approach, but the results are almost identical. 
//


import nme.display.Sprite;
import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.events.Event;
import nme.Assets;
import nme.Lib;
import nme.system.Capabilities;
import nme.geom.Point;
import nme.geom.Rectangle;

import com.ancientsheep.particles.ASTypes;
import com.ancientsheep.particles.ASPointExtensions;
import com.ancientsheep.particles.ASMacros;
import haxe.Timer;





typedef ASUPDATE_PARTICLE_IMP = {
	var id:String;
	var SEL:Dynamic;
	var particle:ASParticle;
	var point:Point;
}


/** Particle System base class
 Attributes of a Particle System:
	- emmision rate of the particles
	- Gravity Mode (Mode A):
		- gravity
		- direction
		- speed +-  variance
		- tangential acceleration +- variance
		- radial acceleration +- variance
	- Radius Mode (Mode B):
		- startRadius +- variance
		- endRadius +- variance
		- rotate +- variance
	- Properties common to all modes:
		- life +- life variance
		- start spin +- variance
		- end spin +- variance
		- start size +- variance
		- end size +- variance
		- start color +- variance
		- end color +- variance
		- life +- variance
		- blending function
	- texture

 */
class ASParticleSystem extends Sprite
{
	// This were enums
	inline static var kCCParticleModeGravity = 0;/** Gravity mode (A mode) */
	inline static var kCCParticleModeRadius = 1;/** Radius mode (B mode) */
	
	/** Living particles are attached to the world and are unaffected by emitter repositioning. */
	inline static var kCCPositionTypeFree = 0;
	/** Living particles are attached to the world but will follow the emitter repositioning.
	 Use case: Attach an emitter to an sprite, and you want that the emitter follows the sprite.*/
	inline static var kCCPositionTypeRelative = 1;
	/** Living particles are attached to the emitter and are translated along with it. */
	inline static var kCCPositionTypeGrouped = 2;
	
	/** The Particle emitter lives forever */
	inline static var kCCParticleDurationInfinity = 0;
	/** The starting size of the particle is equal to the ending size */
	inline static var kCCParticleStartSizeEqualToEndSize = 1;
	/** The starting radius of the particle is equal to the ending radius */
	inline static var kCCParticleStartRadiusEqualToEndRadius = 2;
	
	public var position:Point;
	
	
	// is the particle system active ?
	public var active :Bool;
	// duration in seconds of the system. -1 is infinity
	public var duration :Float;
	// time elapsed since the start of the system (in seconds)
	public var elapsed :Float=0;

	// Position variance
	public var posVar :Point;

	// The angle (direction) of the particles measured in degrees
	public var angle :Float;
	// Angle variance measured in degrees;
	public var angleVar :Float;

	// Different modes
	/** Switch between different kind of emitter modes:
	   - kCCParticleModeGravity: uses gravity, speed, radial and tangential acceleration
	   - kCCParticleModeRadius: uses radius movement + rotation
	 */
	public var emitterMode :Int;// A or B
	var mode :Mode;

	// start ize of the particles
	public var startSize :Float;
	// start Size variance
	public var startSizeVar :Float;
	// End size of the particle
	var endSize :Float;
	// end size of variance
	var endSizeVar :Float;

	// How many seconds will the particle live
	var life :Float;
	// Life variance
	var lifeVar :Float;

	// Start color of the particles
	var startColor :ASColor4F;
	// Start color variance
	var startColorVar :ASColor4F;
	// End color of the particles
	var endColor :ASColor4F;
	// End color variance
	var endColorVar :ASColor4F;

	// start angle of the particles
	var startSpin :Float;
	// start angle variance
	var startSpinVar :Float;
	// End angle of the particle
	var endSpin :Float;
	// end angle ariance
	var endSpinVar :Float;


	// Array of particles
	public var particles :Array<ASParticle>;
	// Maximum particles
	public var totalParticles :Int;
	// Count of active particles
	public var particleCount :Int;

	// color modulate
//	var colorModulate :Bool;

	// How many particles can be emitted per second
	var emissionRate :Float;
	var emitCounter :Float = 0;

	// Texture of the particles
	var texture_ :Bitmap;
	// blend function
	//var blendFunc :ASBlendFunc;

	// movment type: free or grouped
	var positionType_ :Int;

	// Whether or not the node will be auto-removed when there are not particles
	//var autoRemoveOnFinish_ :Bool;

	//  particle idx
	var particleIdx :Int;

	// Optimization
	var updateParticleImp :ASUPDATE_PARTICLE_IMP;
	var updateParticleSel :Dynamic;
	var assetsPath:String;

	var lastTime:Int;

//Ancient Sheep added variables
	var 					particleBMD:BitmapData;
	public var 				asRenderer:ASRenderer;
	public var 				addBlendMode:Bool;

/** Is the emitter active */
//public var active (get_active, null) :Bool;
/** Quantity of particles that are being simulated at the moment */
//public var particleCount (get_particleCount, set_particleCount) :Int;
/** How many seconds the emitter wil run. -1 means 'forever' */
//public var duration (get_duration, set_duration) :Float;
/** position of the emitter */
//public var position (get_position, set_position) :Point;
/** Position variance of the emitter */
//public var posVar (get_posVar, set_posVar) :Point;
/** life, and life variation of each particle */
//public var life (get_life, set_life) :Float;
/** life variance of each particle */
//public var lifeVar (get_lifeVar, set_lifeVar) :Float;
/** angle and angle variation of each particle */
//public var angle (get_angle, set_angle) :Float;
/** angle variance of each particle */
//public var angleVar (get_angleVar, set_angleVar) :Float;

/** Gravity value. Only available in 'Gravity' mode. */
public var gravity (get_gravity, set_gravity) :Point;
/** speed of each particle. Only available in 'Gravity' mode.  */
public var speed (get_speed, set_speed) :Float;
/** speed variance of each particle. Only available in 'Gravity' mode. */
public var speedVar (get_speedVar, set_speedVar) :Float;
/** tangential acceleration of each particle. Only available in 'Gravity' mode. */
public var tangentialAccel (get_tangentialAccel, set_tangentialAccel) :Float;
/** tangential acceleration variance of each particle. Only available in 'Gravity' mode. */
public var tangentialAccelVar (get_tangentialAccelVar, set_tangentialAccelVar) :Float;
/** radial acceleration of each particle. Only available in 'Gravity' mode. */
public var radialAccel (get_radialAccel, set_radialAccel) :Float;
/** radial acceleration variance of each particle. Only available in 'Gravity' mode. */
public var radialAccelVar (get_radialAccelVar, set_radialAccelVar) :Float;

/** The starting radius of the particles. Only available in 'Radius' mode. */
public var startRadius (get_startRadius, set_startRadius) :Float;
/** The starting radius variance of the particles. Only available in 'Radius' mode. */
public var startRadiusVar (get_startRadiusVar, set_startRadiusVar) :Float;
/** The ending radius of the particles. Only available in 'Radius' mode. */
public var endRadius (get_endRadius, set_endRadius) :Float;
/** The ending radius variance of the particles. Only available in 'Radius' mode. */
public var endRadiusVar (get_endRadiusVar, set_endRadiusVar) :Float;			
/** Number of degress to rotate a particle around the source pos per second. Only available in 'Radius' mode. */
public var rotatePerSecond (get_rotatePerSecond, set_rotatePerSecond) :Float;
/** Variance in degrees for rotatePerSecond. Only available in 'Radius' mode. */
public var rotatePerSecondVar (get_rotatePerSecondVar, set_rotatePerSecondVar) :Float;

public var texture (get_texture, set_texture) :Bitmap;
/** conforms to CocosNodeTexture protocol */
public var blendFunc :ASBlendFunc;

public var blendAdditive (get_blendAdditive, set_blendAdditive) :Bool;
/** particles movement type: Free or Grouped
 @since v0.8
 */
public var positionType /*(get_positionType, set_positionType)*/ :Int;
/** whether or not the node will be auto-removed when it has no particles left.
 By default it is NO.
 @since v0.8
 */
public var autoRemoveOnFinish /*(get_autoRemoveOnFinish, set_autoRemoveOnFinish)*/ :Bool=true;


public function new()
{
	super();

	//trace("ASParticleSystem :: new");
}


/** creates an initializes a ASParticleSystem from a plist file.
 This plist files can be creted manually or with Particle Designer:
	http://particledesigner.71squared.com/
 @since v0.99.3
 */
public static function particleWithFile (plistFile:String,pAssets:String,bufferWidth:Int=960,bufferHeight:Int=640) :ASParticleSystem
{
	return new ASParticleSystem().initWithFile (plistFile,pAssets,bufferWidth,bufferHeight);
}

/** initializes a ASParticleSystem from a plist file.
 This plist files can be creted manually or with Particle Designer:
	http://particledesigner.71squared.com/
 @since v0.99.3
 */
public var BUFFER_H:Int;
public var BUFFER_W:Int;
public function initWithFile (plistFile:String, pAssets:String, bufferwidth, bufferHeight ) :ASParticleSystem
{
	BUFFER_H = bufferHeight;
	BUFFER_W = bufferwidth;
	
	assetsPath = pAssets;
	var path :String = pAssets+plistFile;
	//trace("ASParticleSystem :: particleWithFile - "+path);

	var dict :NSDictionary = NSDictionary.dictionaryWithContentsOfFile (path );
	
	if (dict == null) throw "Particles: file not found";
	return this.initWithDictionary ( dict );
}

/** initializes a CCQuadParticleSystem from a NSDictionary.
 @since v0.99.3
 */
//
public function initWithDictionary (dictionary:NSDictionary) :ASParticleSystem
{
	var maxParticles :Int = dictionary.valueForKey ( "maxParticles" );
	// this, not super
	this.initWithTotalParticles ( maxParticles );
	
	// angle
	angle = dictionary.valueForKey ( "angle" );
	angleVar = dictionary.valueForKey ( "angleVariance" );
	
	// duration
	duration = dictionary.valueForKey ( "duration" );
	
	// blend function
/*	blendFunc = {};
	blendFunc.src = dictionary.valueForKey ( "blendFuncSource" ).intValue;
	blendFunc.dst = dictionary.valueForKey ( "blendFuncDestination" ).intValue;*/
	
	// color
	var r:Float,g:Float,b:Float,a:Float;
	
	r = dictionary.valueForKey ( "startColorRed" );
	g = dictionary.valueForKey ( "startColorGreen" );
	b = dictionary.valueForKey ( "startColorBlue" );
	a = dictionary.valueForKey ( "startColorAlpha" );
	startColor = {r:r,g:g,b:b,a:a};
	
	r = dictionary.valueForKey ( "startColorVarianceRed" );
	g = dictionary.valueForKey ( "startColorVarianceGreen" );
	b = dictionary.valueForKey ( "startColorVarianceBlue" );
	a = dictionary.valueForKey ( "startColorVarianceAlpha" );
	startColorVar = {r:r,g:g,b:b,a:a};
	
	r = dictionary.valueForKey ( "finishColorRed" );
	g = dictionary.valueForKey ( "finishColorGreen" );
	b = dictionary.valueForKey ( "finishColorBlue" );
	a = dictionary.valueForKey ( "finishColorAlpha" );
	endColor = {r:r,g:g,b:b,a:a};
	
	r = dictionary.valueForKey ( "finishColorVarianceRed" );
	g = dictionary.valueForKey ( "finishColorVarianceGreen" );
	b = dictionary.valueForKey ( "finishColorVarianceBlue" );
	a = dictionary.valueForKey ( "finishColorVarianceAlpha" );
	endColorVar = {r:r,g:g,b:b,a:a};
	
	// particle size
	startSize = dictionary.valueForKey ( "startParticleSize" );
	startSizeVar = dictionary.valueForKey ( "startParticleSizeVariance" );
	endSize = dictionary.valueForKey ( "finishParticleSize" );
	endSizeVar = dictionary.valueForKey ( "finishParticleSizeVariance" );
	
	// position variation
	posVar = new Point();
	//position = new Point();

	var x :Float = dictionary.valueForKey ( "Positionx" );
	var y :Float = dictionary.valueForKey ( "Positiony" );
	//this.position = new Point (x,y);

	position = new Point (x,y);

	posVar.x = dictionary.valueForKey ( "sourcePositionVariancex" );
	posVar.y = dictionary.valueForKey ( "sourcePositionVariancey" );
	
	// Spinning
	startSpin = dictionary.valueForKey ( "rotationStart" );
	startSpinVar = dictionary.valueForKey ( "rotationStartVariance" );
	endSpin = dictionary.valueForKey ( "rotationEnd" );
	endSpinVar = dictionary.valueForKey ( "rotationEndVariance" );
	
	emitterMode = dictionary.valueForKey ( "emitterType" );

	// Mode A: Gravity + tangential accel + radial accel
	mode = {
		A:{ gravity:new Point(), dir: new Point(), speed:.0, speedVar:.0, tangentialAccel:.0, tangentialAccelVar:.0, radialAccel:.0, radialAccelVar:.0 },
		B:{startRadius:.0, startRadiusVar:.0, endRadius:.0, endRadiusVar:.0, rotatePerSecond:.0, rotatePerSecondVar:.0,deltaRadius: .0,angle: .0,degreesPerSecond: .0,radius: .0 }
	};
	
	if( emitterMode == kCCParticleModeGravity ) {

		// gravity
		mode.A.gravity.x = dictionary.valueForKey ( "gravityx" );
		mode.A.gravity.y = -dictionary.valueForKey ( "gravityy" );
		//mode.A.gravity.y *= -1;


		//
		// speed
		mode.A.speed = dictionary.valueForKey ( "speed" );
		mode.A.speedVar = dictionary.valueForKey ( "speedVariance" );
		
		// radial acceleration			
		var tmp :Null<Float> = dictionary.valueForKey ( "radialAcceleration" );
		mode.A.radialAccel = tmp != null ? tmp : 0.0;
		
		tmp = dictionary.valueForKey ( "radialAccelVariance" );
		mode.A.radialAccelVar = tmp != null ? tmp : 0.0;
					
		// tangential acceleration
		tmp = dictionary.valueForKey ( "tangentialAcceleration" );
		mode.A.tangentialAccel = tmp != null ? tmp : 0.0;
		
		tmp = dictionary.valueForKey ( "tangentialAccelVariance" );
		mode.A.tangentialAccelVar = tmp != null ? tmp : 0.0;
	}
	
	
	// or Mode B: radius movement
	else if( emitterMode == kCCParticleModeRadius ) {

		trace("particle system - B");

		var maxRadius :Float = dictionary.valueForKey ( "maxRadius" );
		var maxRadiusVar :Float = dictionary.valueForKey ( "maxRadiusVariance" );
		var minRadius :Float = dictionary.valueForKey ( "minRadius" );
		
		mode.B.startRadius = maxRadius;
		mode.B.startRadiusVar = maxRadiusVar;
		mode.B.endRadius = minRadius;
		mode.B.endRadiusVar = 0;
		mode.B.rotatePerSecond = dictionary.valueForKey ( "rotatePerSecond" );
		mode.B.rotatePerSecondVar = dictionary.valueForKey ( "rotatePerSecondVariance" );

	} else {
		throw "Invalid emitterType in config file";
	}
	
	// life span
	life = dictionary.valueForKey ( "particleLifespan" );
	lifeVar = dictionary.valueForKey ( "particleLifespanVariance" );				
	
	// emission Rate
	emissionRate = totalParticles/life;

	//Set our blend mode
	if(dictionary.valueForKey("blendFuncDestination") == 770 && dictionary.valueForKey("blendFuncSource") == 1)
		addBlendMode = true;
	else
		addBlendMode = false;

/**
LOAD TEXTURE MAP ... ER TILE SHEET
**/

	var textureName :String = dictionary.valueForKey ( "textureFileName" );
	particleBMD = Assets.getBitmapData(assetsPath + textureName);
	
	asRenderer = new ASRenderer(particleBMD,this);

	var tex :Bitmap = null;

	if( tex != null )
		this.texture = tex;
	else {
		var textureData :String = dictionary.valueForKey ( "textureImageData" );
		var data = null;
	}

	return this;
}

var flashBitmap:Bitmap;

//! Initializes a system with a fixed number of particles
public function initWithTotalParticles ( numberOfParticles:Int ) :ASParticleSystem
{
	totalParticles = numberOfParticles;
	
	particles = new Array<ASParticle>();
	
	// default, active
	active = true;
	
	// default blend function
	//blendFunc = { src:ASMacros.ASBLEND_SRC, dst:ASMacros.ASBLEND_DST };
	
	// default movement type;
	positionType_ = kCCPositionTypeFree;
	
	// by default be in mode A:
	emitterMode = kCCParticleModeGravity;
			
	// default: modulate
	// XXX: not used
//	colorModulate = true;
	
	autoRemoveOnFinish = true;
	
	// Optimization: compile updateQuadWithParticle method
	updateParticleSel = updateQuadWithParticle(null, null);
	//updateParticleImp = this.methodForSelector ( updateParticleSel );

	// udpate after action in run!
	//this.scheduleUpdateWithPriority ( 1 );

	startSystem();

	return this;
}

public function destroy (?e) :Void
{
	removeEventListener(Event.ENTER_FRAME, updateSystem);
	removeEventListener(Event.REMOVED, destroy);
	particles = null;
	texture_ = null;
	asRenderer.destroy();
}


//! Add a particle to the emitter
public function addParticle () :Bool
{
	if( this.isFull() ) return false;
	var particle:ASParticle = new ASParticle();
	particles.push(particle);
	this.initParticle ( particle );		
	particleCount++;
	return true;
}

//! Initializes a particle
public function initParticle (particle:ASParticle)
{
	// timeToLive
	// no negative life. prevent division by 0
	particle.timeToLive = life + lifeVar * ASMacros.RANDOM_MINUS1_1();	
	particle.timeToLive = Math.max(0,particle.timeToLive);

	// position
	particle.pos.x = position.x + posVar.x * ASMacros.RANDOM_MINUS1_1();
	particle.pos.x *= ASConfig.ASCONTENT_SCALE_FACTOR;
	particle.pos.y = position.y + posVar.y * ASMacros.RANDOM_MINUS1_1();
	particle.pos.y *= ASConfig.ASCONTENT_SCALE_FACTOR;
	
	// Color
	var start :ASColor4F = {
		r : ASPointExtensions.clampf( startColor.r + startColorVar.r * ASMacros.RANDOM_MINUS1_1(), 0, 1),
		g : ASPointExtensions.clampf( startColor.g + startColorVar.g * ASMacros.RANDOM_MINUS1_1(), 0, 1),
		b : ASPointExtensions.clampf( startColor.b + startColorVar.b * ASMacros.RANDOM_MINUS1_1(), 0, 1),
		a : ASPointExtensions.clampf( startColor.a + startColorVar.a * ASMacros.RANDOM_MINUS1_1(), 0, 1)
	};


	
	var end :ASColor4F = {
		r : ASPointExtensions.clampf( endColor.r + endColorVar.r * ASMacros.RANDOM_MINUS1_1(), 0, 1),
		g : ASPointExtensions.clampf( endColor.g + endColorVar.g * ASMacros.RANDOM_MINUS1_1(), 0, 1),
		b : ASPointExtensions.clampf( endColor.b + endColorVar.b * ASMacros.RANDOM_MINUS1_1(), 0, 1),
		a : ASPointExtensions.clampf( endColor.a + endColorVar.a * ASMacros.RANDOM_MINUS1_1(), 0, 1)
	};


	
	particle.color = start;

	particle.deltaColor = {
		r: (end.r - start.r) / particle.timeToLive,
		g: (end.g - start.g) / particle.timeToLive,
		b: (end.b - start.b) / particle.timeToLive,
		a: (end.a - start.a) / particle.timeToLive
	};
	
	

	// size
	var startS :Float = startSize + startSizeVar * ASMacros.RANDOM_MINUS1_1();
	startS = Math.max(0, startS); // No negative value
	startS *= ASConfig.ASCONTENT_SCALE_FACTOR;
	
	particle.scale = startS;
	if( endSize == kCCParticleStartSizeEqualToEndSize )
		particle.deltaSize = 0;
	else {
		var endS :Float = endSize + endSizeVar * ASMacros.RANDOM_MINUS1_1();
		endS = Math.max(0, endS);	// No negative values
		endS *= ASConfig.ASCONTENT_SCALE_FACTOR;
		particle.deltaSize = (endS - startS) / particle.timeToLive;
	}
	
	// rotation
	var startA :Float = startSpin + startSpinVar * ASMacros.RANDOM_MINUS1_1();
	var endA :Float = endSpin + endSpinVar * ASMacros.RANDOM_MINUS1_1();
	particle.rotation = startA;
	particle.deltaRotation = (endA - startA) / particle.timeToLive;
	
	// position
	if( positionType_ == kCCPositionTypeFree ) {
		var p :Point = new Point(0,0);
		particle.startPos = ASPointExtensions.mult (p,ASConfig.ASCONTENT_SCALE_FACTOR );
	}
	else if( positionType_ == kCCPositionTypeRelative ) {

		var position_ = new Point(this.x,this.y);

		particle.startPos = ASPointExtensions.mult (position_,ASConfig.ASCONTENT_SCALE_FACTOR );
	}
	


	// direction

	//Custom hack to match particle designer / cocos 2d angle 90 degrees shoots upwards, not downards as expected
	var a :Float = ASMacros.ASDEGREES_TO_RADIANS( 360 - (angle + angleVar * ASMacros.RANDOM_MINUS1_1()) );	

	// Mode Gravity: A
	if( emitterMode == kCCParticleModeGravity ) {

		var v :Point = new Point (Math.cos( a ), Math.sin( a ));
		var s :Float = mode.A.speed + mode.A.speedVar * ASMacros.RANDOM_MINUS1_1();

		s *= ASConfig.ASCONTENT_SCALE_FACTOR;

		// direction
		particle.mode.A.dir = ASPointExtensions.mult (v,s );

		// radial accel
		particle.mode.A.radialAccel = mode.A.radialAccel + mode.A.radialAccelVar * ASMacros.RANDOM_MINUS1_1();
		particle.mode.A.radialAccel *= ASConfig.ASCONTENT_SCALE_FACTOR;
		
		// tangential accel
		particle.mode.A.tangentialAccel = mode.A.tangentialAccel + mode.A.tangentialAccelVar * ASMacros.RANDOM_MINUS1_1();
		particle.mode.A.tangentialAccel *= ASConfig.ASCONTENT_SCALE_FACTOR;

	}
	
	// Mode Radius: B
	else {
		// Set the default diameter of the particle from the source position
		var startRadius :Float = mode.B.startRadius + mode.B.startRadiusVar * ASMacros.RANDOM_MINUS1_1();
		var endRadius :Float = mode.B.endRadius + mode.B.endRadiusVar * ASMacros.RANDOM_MINUS1_1();

		startRadius *= ASConfig.ASCONTENT_SCALE_FACTOR;
		endRadius *= ASConfig.ASCONTENT_SCALE_FACTOR;
		
		particle.mode.B.radius = startRadius;

		if( mode.B.endRadius == kCCParticleStartRadiusEqualToEndRadius )
			particle.mode.B.deltaRadius = 0;
		else
			particle.mode.B.deltaRadius = (endRadius - startRadius) / particle.timeToLive;
	
		particle.mode.B.angle = a;
		particle.mode.B.degreesPerSecond = ASMacros.ASDEGREES_TO_RADIANS (mode.B.rotatePerSecond + mode.B.rotatePerSecondVar * ASMacros.RANDOM_MINUS1_1());
		
	}	
}

public function startSystem()
{
	addEventListener(Event.ENTER_FRAME, updateSystem);
	addEventListener(Event.REMOVED, destroy);
}

public function updateSystem(e:Event)
{
	//trace("system :: updated");
	update(1.0/30.0);
	if(parent!=null)draw();
}

public function draw()
{
	asRenderer.initRender();
	asRenderer.renderParticles(particles);
}

//! stop emitting particles. Running particles will continue to run until they die
public function stopSystem ()
{
	active = false;
	elapsed = duration;
	emitCounter = 0;
}
//! Kill all living particles.
public function resetSystem ()
{
	active = true;
	elapsed = 0;
	for(particleIdx in 0...particleCount) {
		var p :ASParticle = particles[particleIdx];
		p.timeToLive = 0;
	}
}
//! whether or not the system is full
inline public function isFull () :Bool
{
	return (particleCount == totalParticles);
}




// ParticleSystem - MainLoop
public var bounds:Rectangle;
public function update ( dt:Float )
{
	//trace("ASParticleSystem - update");
	//trace(active +";" +emissionRate+";"+duration + ";" +elapsed);
	if( active && emissionRate > 0 ) {
		var rate:Float = 1.0 / emissionRate;
		emitCounter += dt;
		//trace("particleCount::"+particleCount + "; totalParticles::" + totalParticles + "; emitCounter::" + emitCounter + "; rate::" + rate);
		while( particleCount < totalParticles && emitCounter > rate ) {
			this.addParticle();
			emitCounter -= rate;
		}
		
		elapsed += dt;
		if(duration != -1 && duration < elapsed)
			this.stopSystem();
	}
	
	particleIdx = 0;
	
	var currentPosition :Point = new Point(0,0);
	
	if( positionType_ == kCCPositionTypeFree ) {
		currentPosition = new Point(0,0);
		currentPosition.x *= ASConfig.ASCONTENT_SCALE_FACTOR;
		currentPosition.y *= ASConfig.ASCONTENT_SCALE_FACTOR;
	}
	else if( positionType_ == kCCPositionTypeRelative ) {

		var position_ = new Point(this.x,this.y);
		currentPosition = position_;
		currentPosition.x *= ASConfig.ASCONTENT_SCALE_FACTOR;
		currentPosition.y *= ASConfig.ASCONTENT_SCALE_FACTOR;
	}

	//trace("Updating particles - particleCount = "+particleCount + " - actual count = "+particles.length);
	bounds = new Rectangle(position.x, position.y, 0, 0);
	while( particleIdx < particleCount )
	{
		var p :ASParticle = particles[particleIdx];
		
		// life
		p.timeToLive -= dt;

		

		if( p.timeToLive > 0 ) {
			
			// Mode A: gravity, direction, tangential accel & radial accel
			if( emitterMode == kCCParticleModeGravity ) 
			{

				var tmp, radial, tangential :Point;
				
				radial = new Point(0,0);
				// radial acceleration
				if(p.pos.x > 0 || p.pos.y > 0)
					radial = ASPointExtensions.normalize(p.pos);
				tangential = radial;

				radial = ASPointExtensions.mult(radial,p.mode.A.radialAccel);

				// tangential acceleration
				var newy :Float = tangential.x;
				tangential.x = - tangential.y;
				tangential.y = newy;
				tangential = ASPointExtensions.mult (tangential,p.mode.A.tangentialAccel );

				// (gravity + radial + tangential) * dt
				//tmp = radial.add ( tangential ).add ( mode.A.gravity );

				tmp = ASPointExtensions.add(radial,tangential);
				tmp = ASPointExtensions.add(tmp,mode.A.gravity);

				tmp = ASPointExtensions.mult (tmp,dt );
				p.mode.A.dir = ASPointExtensions.add(p.mode.A.dir,tmp);
				tmp = ASPointExtensions.mult (p.mode.A.dir,dt );
				p.pos = ASPointExtensions.add (p.pos,tmp);
			}
			
			// Mode B: radius movement
			else {			
				// Update the angle and radius of the particle.
				p.mode.B.angle += p.mode.B.degreesPerSecond * dt;
				p.mode.B.radius += p.mode.B.deltaRadius * dt;
				
				p.pos.x = - Math.cos(p.mode.B.angle) * p.mode.B.radius;
				p.pos.y = - Math.sin(p.mode.B.angle) * p.mode.B.radius;
			}
			
			// color
			p.color.r += (p.deltaColor.r * dt);
			p.color.g += (p.deltaColor.g * dt);
			p.color.b += (p.deltaColor.b * dt);
			p.color.a += (p.deltaColor.a * dt);
			
			// size
			p.scale += (p.deltaSize * dt);
			p.scale = Math.max( 0, p.scale );
			
			// angle
			p.rotation += (p.deltaRotation * dt);
				

			//
			// update values in quad
			//
			
			var newPos :Point = null;
			
			if( positionType_ == kCCPositionTypeFree || positionType_ == kCCPositionTypeRelative ) {
				
				var diff :Point = ASPointExtensions.sub( currentPosition, p.startPos );
				newPos = ASPointExtensions.sub(p.pos, diff);
				
			} else
				newPos = p.pos;
			
/**

UPDATE PARTICLE IN EITHER POINT OR QUAD SYSTEM
**/
			particleIdx++;
			
				if (p.pos.x < bounds.left) bounds.left = p.pos.x-p.scale;
				if (p.pos.y < bounds.top) bounds.top = p.pos.y-p.scale;
				if (p.pos.x > bounds.right) bounds.right = p.pos.x+p.scale;
				if (p.pos.y > bounds.bottom) bounds.bottom = p.pos.y+p.scale;				

			
		} else {

			particles.splice(particleIdx, 1);
				
			particleCount--;
			if( particleCount == 0 && autoRemoveOnFinish ) {
				parent.removeChild(this);
				return;
			}
		}
	}
	
#if ASENABLE_PROFILERS
	CCProfilingEndTimingBlock(_profilingTimer);
#end
	
#if ASUSES_VBO
	this.postStep();
#end
	}

	public function updateQuadWithParticle (particle:ASParticle, pos:Point) :Void
	{
		// should be overriden
	}

	public function postStep ()
	{
		// should be overriden
	}

	// ParticleSystem - CCTexture protocol

	public function set_texture (texture:Bitmap) :Bitmap
	{
		if (texture_ != null)
			texture_ = null;
		texture_ = texture;

		// If the new texture has No premultiplied alpha, AND the blendFunc hasn't been changed, then update it
		if( texture_ != null  /*&&
			   ( blendFunc.src == ASBLEND_SRC && blendFunc.dst == ASBLEND_DST )*/)
		{
			blendFunc.src = GL.SRC_ALPHA;
			blendFunc.dst = GL.ONE_MINUS_SRC_ALPHA;
		}
		return texture_;
	}

	public function get_texture () :Bitmap
	{
		return texture_;
	}

	// ParticleSystem - Additive Blending
	public function set_blendAdditive ( additive:Bool ) :Bool
	{
		if( additive ) {
			blendFunc.src = GL.SRC_ALPHA;
			blendFunc.dst = GL.ONE;

		} else {
			
	/*		if( texture_ != null && ! texture_.hasPremultipliedAlpha ) {
				blendFunc.src = GL.SRC_ALPHA;
				blendFunc.dst = GL.ONE_MINUS_SRC_ALPHA;
			} else {
				blendFunc.src = ASMacros.ASBLEND_SRC;
				blendFunc.dst = ASMacros.ASBLEND_DST;
			}*/
		}
		return additive;
	}

	public function get_blendAdditive () :Bool
	{
		return false;//( blendFunc.src == GL.SRC_ALPHA && blendFunc.dst == GL.ONE);
	}

	// ParticleSystem - Properties of Gravity Mode 
	public function set_tangentialAccel ( t:Float ) :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.tangentialAccel = t;
	}
	public function get_tangentialAccel () :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.tangentialAccel;
	}

	public function set_tangentialAccelVar ( t:Float ) :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.tangentialAccelVar = t;
	}
	public function get_tangentialAccelVar () :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.tangentialAccelVar;
	}

	public function set_radialAccel ( t:Float ) :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.radialAccel = t;
	}
	public function get_radialAccel () :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.radialAccel;
	}

	public function set_radialAccelVar ( t:Float ) :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.radialAccelVar = t;
	}
	public function get_radialAccelVar () :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.radialAccelVar;
	}

	public function set_gravity ( g:Point ) :Point
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.gravity = g;
	}
	public function get_gravity () :Point
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.gravity;
	}

	public function set_speed ( speed:Float ) :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.speed = speed;
	}
	public function get_speed () :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.speed;
	}

	public function set_speedVar ( speedVar:Float ) :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.speedVar = speedVar;
	}
	public function get_speedVar () :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.speedVar;
	}

	// ParticleSystem - Properties of Radius Mode

	public function set_startRadius ( startRadius:Float ) :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.startRadius = startRadius;
	}
	public function get_startRadius () :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.startRadius;
	}

	public function set_startRadiusVar ( startRadiusVar:Float ) :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.startRadiusVar = startRadiusVar;
	}
	public function get_startRadiusVar () :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.startRadiusVar;
	}

	public function set_endRadius ( endRadius:Float ) :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.endRadius = endRadius;
	}
	public function get_endRadius () :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.endRadius;
	}

	public function set_endRadiusVar ( endRadiusVar:Float ) :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.endRadiusVar = endRadiusVar;
	}
	public function get_endRadiusVar () :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.endRadiusVar;
	}

	public function set_rotatePerSecond ( degrees:Float ) :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.rotatePerSecond = degrees;
	}
	public function get_rotatePerSecond () :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.rotatePerSecond;
	}

	public function set_rotatePerSecondVar ( degrees:Float ) :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.rotatePerSecondVar = degrees;
	}
	public function get_rotatePerSecondVar () :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.rotatePerSecondVar;
	}
}
