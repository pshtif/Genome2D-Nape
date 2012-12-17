/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.physics
{
	import com.genome2d.g2d;
	
	import flash.Boot;
	import flash.utils.Dictionary;
	
	import nape.geom.Vec2;
	import nape.space.Space;
	import nape.util.Debug;
	
	use namespace g2d;
	
	public class GNapePhysics extends GPhysics
	{
		private var __dPreCollisionListeners:Dictionary = new Dictionary();
		private var __dCollisionListeners:Dictionary = new Dictionary();
		private var __dSensorListeners:Dictionary = new Dictionary();
		
		g2d var eSpace:Space;
		public function get space():Space {
			return eSpace;
		}
		
		protected var _eDebug:Debug;
		
		public function GNapePhysics(p_gravity:Vec2, p_debug:Debug = null) {
			new Boot();
	
			_eDebug = p_debug;
			eSpace = new Space(p_gravity);
		}

		override g2d function step(p_deltaTime:Number):void {
			if (!_bRunning) return;

			if (p_deltaTime > 100) p_deltaTime = 100;

			if (_eDebug) _eDebug.clear();
			
			if (minimumTimeStep>0) {
				if (p_deltaTime < minimumTimeStep) {
					eSpace.step(p_deltaTime/1000, 8, 8);
				} else {
					var divider:int = 2;
					while (p_deltaTime/divider > minimumTimeStep) divider++;
					for (var i:int = 0; i<divider; ++i) {
						eSpace.step((p_deltaTime/divider)/1000, 8, 8);
					}
				}
			} else {
				eSpace.step(p_deltaTime/1000, 8, 8);
			}
			
			if (_eDebug) {
				_eDebug.draw(eSpace);
				_eDebug.flush();
			}
		}
		
		override public function setGravity(p_x:Number, p_y:Number):void {
			eSpace.gravity.setxy(p_x, p_y);
		}
		
		override public function dispose():void {
			eSpace.clear();
			eSpace = null;
		}
	}
}