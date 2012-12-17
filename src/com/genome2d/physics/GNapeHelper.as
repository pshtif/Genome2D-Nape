/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.physics
{
	import flash.geom.Rectangle;
	
	import nape.dynamics.InteractionFilter;
	import nape.geom.GeomPoly;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;

	public class GNapeHelper
	{
		static public function createStaticBoundary(p_rect:Rectangle, p_size:Number, p_material:Material = null, p_filter:InteractionFilter = null):Body {
			var body:Body = new Body(BodyType.STATIC);
			body.shapes.add(new Polygon(Polygon.rect(p_rect.x-p_size, p_rect.bottom, p_rect.width+p_size*2, p_size), p_material, p_filter));
			body.shapes.add(new Polygon(Polygon.rect(p_rect.x-p_size, p_rect.y-p_size, p_rect.width+p_size*2, p_size), p_material, p_filter));
			body.shapes.add(new Polygon(Polygon.rect(p_rect.x-p_size, p_rect.y-p_size, p_size, p_rect.height+p_size*2), p_material, p_filter));
			body.shapes.add(new Polygon(Polygon.rect(p_rect.right, p_rect.y-p_size, p_size, p_rect.height+p_size*2), p_material, p_filter));
			
			return body;
		}
		
		static public function createBox(p_width:Number, p_height:Number, p_type:BodyType = null, p_material:Material = null, p_filter:InteractionFilter = null):Body {
			if (p_type == null) p_type = BodyType.DYNAMIC; 
				
			var body:Body = new Body(p_type);
			var shape:Polygon = new Polygon(Polygon.box(p_width, p_height), p_material, p_filter);
			shape.body = body;
			
			return body;
		}
		
		/**/
		static public function createCircle(p_radius:Number, p_type:BodyType = null, p_material:Material = null, p_filter:InteractionFilter = null):Body {
			if (p_type == null) p_type = BodyType.DYNAMIC; 
		
			var body:Body = new Body(p_type);
			var shape:Circle = new Circle(p_radius, new Vec2(), p_material, p_filter);
			shape.body = body;
			
			return body;
		}
		
		static public function createPolygon(p_vertices:*, p_type:BodyType = null, p_material:Material = null, p_filter:InteractionFilter = null):Body {
			if (p_type == null) p_type = BodyType.DYNAMIC;
			
			var geompoly:GeomPoly;
			
			if (p_vertices is GeomPoly) {
				geompoly = p_vertices;
			} else {
				var vertices:Array = new Array();
				for (var i:int = 0; i<p_vertices.length; i+=2) {
					var vec:Vec2 = new Vec2(p_vertices[i], p_vertices[i+1]);
					vertices.push(vec);
				}
				
				geompoly = new GeomPoly(vertices);
			}
		
			var body:Body = new Body(p_type);
			var shape:Polygon = new Polygon(geompoly, p_material, p_filter);
			shape.body = body;
			return body;
		}
		
		static public function getBodyType(p_type:String):BodyType {
			switch (p_type) {
				case "DYNAMIC":
					return BodyType.DYNAMIC;
				case "KINEMATIC":
					return BodyType.KINEMATIC;
			}
			
			return BodyType.DYNAMIC;
		}
		
		static public function createBoxGeom(p_width:Number, p_height:Number, p_x:Number = 0, p_y:Number = 0):GeomPoly {
			var vertices:Array = [];
			vertices.push(Vec2.get(p_x-p_width/2, p_y-p_height/2));
			vertices.push(Vec2.get(p_x+p_width/2, p_y-p_height/2));
			vertices.push(Vec2.get(p_x+p_width/2, p_y+p_height/2));
			vertices.push(Vec2.get(p_x-p_width/2, p_y+p_height/2));
			return new GeomPoly(vertices);
		}
	}
}