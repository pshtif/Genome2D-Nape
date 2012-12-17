/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.physics.nape
{
	import com.genome2d.g2d;
	import com.genome2d.components.physics.GBody;
	import com.genome2d.core.GNode;
	import com.genome2d.error.GError;
	import com.genome2d.physics.GNapePhysics;
	
	import flash.utils.Dictionary;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.callbacks.OptionType;
	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	import nape.callbacks.PreListener;
	import nape.dynamics.InteractionFilter;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.shape.Shape;
	import nape.shape.ShapeType;
	
	use namespace g2d;

	public class GNapeBody extends GBody
	{
		static public const DYNAMIC:int = 0;
		static public const KINEMATIC:int = 1;
		static public const STATIC:int = 2;
		
		g2d var ePhysics:GNapePhysics;
		public function get physics():GNapePhysics {
			return ePhysics;
		}
		
		override public function getPrototype():XML {
			_xPrototype = super.getPrototype();
			
			_xPrototype.shapes = <shapes/>;
			for (var i:int = 0; i<_eNapeBody.shapes.length; ++i) {
				var shapeXML:XML = <shape/>;
				var shape:Shape = _eNapeBody.shapes.at(i);
				shapeXML.@type = shape.type;
				if (shape.isCircle()) {
					shapeXML.@radius = shape.castCircle.radius;	
				}
				shapeXML.@collisionGroup = shape.filter.collisionGroup;
				shapeXML.@collisionMask = shape.filter.collisionMask;
				shapeXML.@sensorGroup = shape.filter.sensorGroup;
				shapeXML.@sensorMask = shape.filter.sensorMask;
				_xPrototype.shapes.appendChild(shapeXML);
			}

			return _xPrototype;
		}
		
		override public function bindFromPrototype(p_prototype:XML):void {
			clearBody();

			napeBody = new Body();
			super.bindFromPrototype(p_prototype);
			/*
			type = p_prototype.properties.type.@value;
			/**/
			for (var i:int=0; i<p_prototype.shapes.children().length(); ++i) {
				var shapeXML:XML = p_prototype.shapes.children()[i];
				var filter:InteractionFilter = new InteractionFilter(int(shapeXML.@collisionGroup), int(shapeXML.@collisionMask), int(shapeXML.@sensorGroup), int(shapeXML.@sensorMask));

				if (shapeXML.@type == String(ShapeType.CIRCLE)) {
					var shape:Shape = new Circle(shapeXML.@radius, null, null, filter);
				}
				
				napeBody.shapes.add(shape);
			}
		}
		
		override public function get x():Number {
			return _eNapeBody.position.x;
		}
		override public function set x(p_x:Number):void {
			if (_eNapeBody.isKinematic() && cNode.core.nCurrentDeltaTime!=0) _eNapeBody.kinematicVel.x = (p_x - _eNapeBody.position.x)*1000/cNode.core.nCurrentDeltaTime;
			_eNapeBody.position.x = p_x;
		}
		
		override public function get y():Number {
			return _eNapeBody.position.y;
		}
		override public function set y(p_y:Number):void {
			if (_eNapeBody.isKinematic() && cNode.core.nCurrentDeltaTime!=0) _eNapeBody.kinematicVel.y = (p_y - _eNapeBody.position.y)*1000/cNode.core.nCurrentDeltaTime;
			_eNapeBody.position.y = p_y;
		}
		
		public var scaleShapes:Boolean = false;
		
		protected var _nScaleX:Number = 1;
		override public function get scaleX():Number {
			return _nScaleX;
		}
		override public function set scaleX(p_scaleX:Number):void {
			if (p_scaleX == _nScaleX) return;
			var scale:Number = p_scaleX/_nScaleX;
			if (scaleShapes) _eNapeBody.scaleShapes(scale, 1);
			_nScaleX = p_scaleX;
		}
		
		protected var _nScaleY:Number = 1;
		override public function get scaleY():Number {
			return _nScaleY;
		}
		override public function set scaleY(p_scaleY:Number):void {
			if (p_scaleY == _nScaleY) return;
			var scale:Number = p_scaleY/_nScaleY;
			if (scaleShapes) _eNapeBody.scaleShapes(1, scale);
			_nScaleY = p_scaleY;
		}
		
		override public function get rotation():Number {
			return _eNapeBody.rotation;
		}
		override public function set rotation(p_rotation:Number):void {
			if (_eNapeBody.isKinematic() && cNode.core.nCurrentDeltaTime!=0) _eNapeBody.kinAngVel = (p_rotation - _eNapeBody.rotation)*1000/cNode.core.nCurrentDeltaTime;
			_eNapeBody.rotation = p_rotation;
		}
		
		override public function isDynamic():Boolean {
			return _eNapeBody.isDynamic();
		}
		
		override public function isKinematic():Boolean {
			return _eNapeBody.isKinematic();
		}
		
		public function get type():int {
			if (_eNapeBody == null) return -1;
			
			switch (_eNapeBody.type) {
				case BodyType.DYNAMIC:
					return DYNAMIC;
					break;
				case BodyType.KINEMATIC:
					return KINEMATIC;
					break;
				case BodyType.STATIC:
					return STATIC;
					break;
			}
			
			return -1;
		}
		
		public function set type(p_type:int):void {
			if (_eNapeBody == null) return;
			
			switch (p_type) {
				case DYNAMIC:
					_eNapeBody.type = BodyType.DYNAMIC;
					_eNapeBody.kinAngVel = 0;
					_eNapeBody.kinematicVel.setxy(0,0);
					break;
				case KINEMATIC:
					_eNapeBody.type = BodyType.KINEMATIC;
					_eNapeBody.angularVel = 0;
					_eNapeBody.velocity.setxy(0,0);
					break;
				case STATIC:
					_eNapeBody.type = BodyType.STATIC;
					break;
			}
			
			return;
		}
		
		public function isMoving():Boolean {
			return !_eNapeBody.isSleeping && _eNapeBody.type == BodyType.DYNAMIC;
		}
		
		protected var _eNapeBody:Body;
		
		public function get napeBody():Body {
			return _eNapeBody;
		}
		public function set napeBody(p_body:Body):void {
			if (_eNapeBody != null) removeFromSpace();
			
			_eNapeBody = p_body;
			_eNapeBody.userData.component = this;
			cNode.cTransform.invalidate(true, false);
			_eNapeBody.position.x = cNode.cTransform.nWorldX;
			_eNapeBody.position.y = cNode.cTransform.nWorldY;
			
			if (node.isOnStage()) addToSpace();
		}
		
		override public function set active(p_value:Boolean):void {
			_bActive = p_value;
			if (!_bActive) {
				_eNapeBody.space = null;
			} else {
				_eNapeBody.space = (node.core.physics as GNapePhysics).eSpace;
			}
		}
		
		public function GNapeBody(p_node:GNode) {
			super(p_node);
			
			ePhysics = node.core.physics as GNapePhysics;
			if (ePhysics == null) throw new GError("GError: Physics not initialized.");
		}
		
		override public function dispose():void {			
			clearBody();	
			
			clearListeners();	
		}
		
		private function clearBody():void {
			if (_eNapeBody == null) return;

			_eNapeBody.shapes.clear();
			_eNapeBody.space = null;;
			_eNapeBody.userData.component = null;
			_eNapeBody = null;
		}
		
		override public function update(p_deltaTime:Number, p_parentTransformUpdate:Boolean, p_parentColorUpdate:Boolean):void {
			if (_eNapeBody.isKinematic()) {
				_eNapeBody.kinematicVel.setxy(0,0);
				_eNapeBody.kinAngVel = 0;
			}
		}
		
		override g2d function addToSpace():void {
			if (node.core.physics == null) throw new GError(GError.NO_PHYSICS_INITIALIZED);
			_eNapeBody.space = ePhysics.space;
		}
		
		override g2d function removeFromSpace():void {
			_eNapeBody.space = null;
		}

		private var __dPreCollisionListeners:Dictionary = new Dictionary();
		
		public function addPreCollisionListener(p_cbType:CbType, p_callback:Function):void {
			var callbackTypes:OptionType = new OptionType(_eNapeBody.cbTypes, CbType.ANY_BODY);
			var listener:PreListener = new PreListener(InteractionType.COLLISION, callbackTypes, p_cbType, onPreCollisionListener);
			physics.space.listeners.add(listener);
			
			__dPreCollisionListeners[listener] = p_callback;
		}
		
		private function onPreCollisionListener(p_callback:PreCallback):PreFlag {
			if (p_callback.int1.castBody == _eNapeBody) return __dPreCollisionListeners[p_callback.listener](p_callback);
			
			return null;
		}
		
		public function removePreCollisionListener(p_cbType:CbType, p_callback:Function):void {
			for (var it in __dPreCollisionListeners) {
				var listener:PreListener = it as PreListener;
				if (__dPreCollisionListeners[it] != p_callback) continue;
				if (!listener.options2.includes.has(p_cbType) || listener.options2.includes.length != 1) continue;
				physics.space.listeners.remove(it);
				delete __dPreCollisionListeners[it];
			}
		}
		/**/
		private var __dCollisionListeners:Dictionary = new Dictionary();
		
		public function addCollisionListener(p_cbEvent:CbEvent, p_cbType:CbType, p_callback:Function):void {
			var callbackTypes:OptionType = new OptionType(_eNapeBody.cbTypes, CbType.ANY_BODY);
			var listener:InteractionListener = new InteractionListener(p_cbEvent, InteractionType.COLLISION, callbackTypes, p_cbType, onCollisionListener);

			physics.space.listeners.add(listener);

			__dCollisionListeners[listener] = p_callback;
		}
		
		private function onCollisionListener(p_callback:InteractionCallback):void {
			if (p_callback.int1.castBody != _eNapeBody) return;
			__dCollisionListeners[p_callback.listener](p_callback);
		}
		
		public function removeCollisionListener(p_cbEvent:CbEvent, p_cbType:CbType, p_callback:Function):void {
			for (var it in __dCollisionListeners) {
				var listener:InteractionListener = it as InteractionListener;
				if (__dCollisionListeners[it] != p_callback) continue;
				if (listener.event != p_cbEvent) continue;
				if (!listener.options2.includes.has(p_cbType) || listener.options2.includes.length != 1) continue;
				physics.space.listeners.remove(it);
				delete __dCollisionListeners[it];
			}
		}

		private var __dSensorListeners:Dictionary = new Dictionary();
		
		public function addSensorListener(p_cbEvent:CbEvent, p_cbType:CbType, p_callback:Function):void {
			var callbackTypes:OptionType = new OptionType(_eNapeBody.cbTypes, CbType.ANY_BODY);
			var listener:InteractionListener = new InteractionListener(p_cbEvent, InteractionType.SENSOR, callbackTypes, p_cbType, onSensorListener);
			physics.space.listeners.add(listener);
			
			__dSensorListeners[listener] = p_callback;
		}
		
		private function onSensorListener(p_callback:InteractionCallback):void {
			if (p_callback.int1.castBody != _eNapeBody) return;
			__dSensorListeners[p_callback.listener](p_callback);
		}
		
		public function removeSensorListener(p_cbEvent:CbEvent, p_cbType:CbType, p_callback:Function):void {
			for (var it in __dSensorListeners) {
				var listener:InteractionListener = it as InteractionListener;
				if (__dSensorListeners[it] != p_callback) continue;
				if (listener.event != p_cbEvent) continue;
				if (!listener.options2.includes.has(p_cbType) || listener.options2.includes.length != 1) continue;
				physics.space.listeners.remove(it);
				delete __dSensorListeners[it];
			}
		}
		
		private function clearListeners():void {
			for (var it in __dPreCollisionListeners) {
				physics.space.listeners.remove(it);
			}
			__dPreCollisionListeners = null;
			
			for (var it in __dCollisionListeners) {
				physics.space.listeners.remove(it);
			}
			__dCollisionListeners = null;
			
			for (var it in __dSensorListeners) {
				physics.space.listeners.remove(it);
			}
			__dSensorListeners = null;			
		}
	}
}