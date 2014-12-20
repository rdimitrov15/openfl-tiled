// Copyright (C) 2013 Christopher "Kasoki" Kaster
//
// This file is part of "openfl-tiled". <http://github.com/Kasoki/openfl-tiled>
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
package openfl.tiled.display;

import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.display.Tilesheet;

class TilesheetRenderer implements Renderer {

	private var map:TiledMap;

	private var tilesheets:Map<Int, Tilesheet>;
	private var tileRects:Array<Rectangle>;

	public function new() {
		this.tilesheets = new Map<Int, Tilesheet>();
		this.tileRects = new Array<Rectangle>();
	}

	public function setTiledMap(map:TiledMap):Void {
		this.map = map;

		for(tileset in map.tilesets) {
			this.tilesheets.set(tileset.firstGID, new Tilesheet(tileset.image.texture));
		}
	}

	public function drawLayer(on:Dynamic, layer:Layer):Void {
		var sprite:Sprite = new Sprite();

		var drawList:Array<Float> = new Array<Float>();
		var gidCounter:Int = 0;

		if(layer.visible) {
			for(y in 0...map.heightInTiles) {
				for(x in 0...map.widthInTiles) {
					var nextGID = layer.tiles[gidCounter].gid;

					if(nextGID != 0) {
						var point:Point = new Point();

						switch (map.orientation) {
							case TiledMapOrientation.Orthogonal:
								point = new Point(x * map.tileWidth, y * map.tileHeight);
							case TiledMapOrientation.Isometric:
								point = new Point((map.width + x - y - 1) * map.tileWidth * 0.5, (y + x) * map.tileHeight * 0.5);
						}

						var tileset:Tileset = map.getTilesetByGID(nextGID);

						var tilesheet:Tilesheet = tilesheets.get(tileset.firstGID);

						var rect:Rectangle = tileset.getTileRectByGID(nextGID);

						var tileId:Int = -1;

						var foundSomething:Bool = false;

						for(r in this.tileRects) {
							if(rectEquals(r, rect)) {
								tileId = Lambda.indexOf(this.tileRects, r);

								foundSomething = true;

								break;
							}
						}

						if(!foundSomething) {
							this.tileRects.push(rect);
						}

						if(tileId < 0) {
							tileId = tilesheets.get(tileset.firstGID).addTileRect(rect);
						}

						// add coordinates to draw list
						drawList.push(point.x); // x coord
						drawList.push(point.y); // y coord
						drawList.push(tileId); // tile id
						drawList.push(layer.opacity); // alpha channel
					}

					gidCounter++;
				}
			}
		}

		if(map.backgroundColorSet) {
			fillBackground(sprite);
		}

		// draw layer
		for(tileset in map.tilesets) {
			var tilesheet:Tilesheet = tilesheets.get(tileset.firstGID);

			tilesheet.drawTiles(sprite.graphics, drawList, true, Tilesheet.TILE_ALPHA);
		}

		on.addChild(sprite);
	}

	public function drawImageLayer(on:Dynamic, imageLayer:ImageLayer):Void {
		var sprite = new Sprite();

		var tilesheet:Tilesheet = new Tilesheet(imageLayer.image.texture);

		var id = tilesheet.addTileRect(new Rectangle(0, 0, imageLayer.image.width, imageLayer.image.height));

		var drawList:Array<Float> = new Array<Float>();

		drawList.push(0);
		drawList.push(0);
		drawList.push(id);
		drawList.push(imageLayer.opacity);

		tilesheet.drawTiles(sprite.graphics, drawList, true, Tilesheet.TILE_ALPHA);

		on.addChild(sprite);
	}

	public function clear(on:Dynamic):Void {
		while(on.numChildren > 0){
			on.removeChildAt(0);
		}
	}

	private function fillBackground(sprite:Sprite):Void {
		sprite.graphics.beginFill(map.backgroundColor);

		if(map.orientation == TiledMapOrientation.Orthogonal) {
			sprite.graphics.drawRect(0, 0, map.totalWidth, map.totalHeight);
		} else {
			sprite.graphics.drawRect(-map.totalWidth * 0.5, 0, map.totalWidth, map.totalHeight);
		}

		sprite.graphics.endFill();
	}

	private function rectEquals(r1:Rectangle, r2:Rectangle):Bool {
		return r1.x == r2.x && r1.y == r2.y && r1.width == r2.width && r1.height == r2.height;
	}
}