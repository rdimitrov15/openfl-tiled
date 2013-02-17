// Copyright (C) 2013 Christopher "Kasoki" Kaster
// 
// This file is part of "nme-tiled". <http://github.com/Kasoki/nme-tiled>
// 
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
// THE SOFTWARE.
package de.kasoki.nmetiled;

class TiledObjectGroup {

	public var name:String;
	public var color:String;
	public var width:Int;
	public var height:Int;
	public var properties:Hash<String>;
	public var objects:Array<TiledObject>;

	private var objectCounter:Int;
	
	public function new(name:String, color:String, width:Int, height:Int, properties:Hash<String>, objects:Array<TiledObject>) {
		this.name = name;
		this.color = color;
		this.width = width;
		this.height = height;
		this.properties = properties;
		this.objects = objects;

		this.objectCounter = 0;
	}
	
	public static function fromGenericXml(xml:Xml):TiledObjectGroup {
		var name = xml.get("name");
		var color = xml.get("color");
		var width = Std.parseInt(xml.get("width"));
		var height = Std.parseInt(xml.get("height"));
		var properties:Hash<String> = new Hash<String>();
		var objects:Array<TiledObject> = new Array<TiledObject>();
		
		for (child in xml) {
			if (Helper.isValidElement(child)) {
				if (child.nodeName == "properties") {
					for (property in child) {
						if (Helper.isValidElement(property)) {
							properties.set(property.get("name"), property.get("value"));
						}
					}
				}
				
				if (child.nodeName == "object") {
					objects.push(TiledObject.fromXml(child));
				}
			}
		}
		
		return new TiledObjectGroup(name, color, width, height, properties, objects);
	}

	public function hasNext():Bool {
		if(objectCounter < objects.length) {
			return true;
		} else {
			objectCounter = 0;
			return false;
		}
	}

	public function next():TiledObject {
		return objects[objectCounter++];
	}
	
}
