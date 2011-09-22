/**************************************************************************
* Copyright 2010 Marc BUILS
* Original sourec: QRReader Exemple by Kenichi UENO
*
* This program is free software; you can redistribute it and/or modify it under
* the terms of the GNU General Public License as published by the Free Software
* Foundation; either version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this program; if not, write to the Free Software Foundation, Inc., 59 Temple
* Place, Suite 330, Boston, MA 02111-1307 USA
*
**************************************************************************/ 
package fr.marcbuils.WebcamQRCode
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.SimpleButton;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import com.logosware.event.QRdecoderEvent;
	import com.logosware.event.QRreaderEvent;
	import com.logosware.utils.QRcode.QRdecode;
	import com.logosware.utils.QRcode.GetQRimage;
	
	import flash.external.*;
	import mx.core.FlexGlobals;
	
	/**
	 * QR
	 * @author Marc BUILS
	 */
	public class WebcamQRCode extends Sprite 
	{
		private const SRC_SIZE:int = 350;
		private const STAGE_SIZE:int = 350;
		
		private var getQRimage:GetQRimage;
		private var qrDecode:QRdecode = new QRdecode();

		private var errorView:Sprite;
		private var errorText:TextField = new TextField();
		
		private var cameraView:Sprite;
		private var camera:Camera;
		private var video:Video = new Video(SRC_SIZE, SRC_SIZE);
		private var freezeImage:Bitmap;
		private var blue:Sprite = new Sprite();
		private var red:Sprite = new Sprite();
		private var blurFilter:BlurFilter = new BlurFilter();
		
		private var textArea:TextField = new TextField();
		private var cameraTimer:Timer = new Timer(2000);
		
		private var textArray:Array = ["", "", ""];
		
		private var m_id:int = -1;	// ID used by JS
		
		/**
		 * 
		 */
		public function WebcamQRCode():void {
			stage.scaleMode = StageScaleMode.NO_BORDER; //NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			errorView = buildErrorView();
			
			cameraTimer.addEventListener(TimerEvent.TIMER, getCamera);
			cameraTimer.start();
			
			// Javascript communication for js
			this.m_id = root.loaderInfo.parameters.ID;
			
			getCamera();
		}
		/**
		 * 
		 */
		private function getCamera(e:TimerEvent = null):void{
			camera = Camera.getCamera();
			this.graphics.clear();
			if ( camera == null ) {
				this.addChild( errorView );
			} else {
				cameraTimer.stop();
				if ( errorView.parent == this ) {
					this.removeChild(errorView);
				}
				start();
			}
		}
		/**
		 * 
		 */
		private function start():void {
			onStart();
		}
		/**
		 * 
		 */
		private function onStart():void {
			cameraView = buildCameraView();
			
			this.addChild( cameraView );
			
			getQRimage = new GetQRimage(video);
			getQRimage.addEventListener(QRreaderEvent.QR_IMAGE_READ_COMPLETE, onQrImageReadComplete);
			qrDecode.addEventListener(QRdecoderEvent.QR_DECODE_COMPLETE, onQrDecodeComplete);
			redTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onRedTimer );
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
			
		/**
		 * 
		 */
		private function buildErrorView():Sprite {
			var sprite:Sprite = new Sprite();
			errorText.autoSize = TextFieldAutoSize.LEFT;
			errorText.text = "no camera detected.";
			errorText.x = 0.5 * (STAGE_SIZE - errorText.width);
			errorText.y = 0.5 * (STAGE_SIZE - errorText.height);
			errorText.border = true;
			errorText.background = true;
			sprite.graphics.lineStyle(0);
			sprite.graphics.drawPath(Vector.<int>([1, 2, 2, 2, 2, 2, 1, 2]), Vector.<Number>([5, 5, STAGE_SIZE-5, 5, STAGE_SIZE-5, STAGE_SIZE-5, 5, STAGE_SIZE-5, 5, 5, STAGE_SIZE-5, STAGE_SIZE-5, 5, STAGE_SIZE-5, STAGE_SIZE-5, 5]));
			sprite.addChild(errorText);
			return sprite;
		}

		/**
		 * 
		 */
		private function buildCameraView():Sprite {
			camera.setQuality(0, 100);
			camera.setMode(SRC_SIZE, SRC_SIZE, 24, true );
			video.attachCamera( camera );
			
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginGradientFill(GradientType.LINEAR, [0xCCCCCC, 0x999999], [1.0, 1.0], [0, 255], new Matrix(0, 0.1, -0.1, 0, 0, 150));
			
			var videoHolder:Sprite = new Sprite();
			videoHolder.addChild( video );
			videoHolder.x = videoHolder.y = 0;
			
			freezeImage = new Bitmap(new BitmapData(SRC_SIZE, SRC_SIZE));
			videoHolder.addChild( freezeImage );
			freezeImage.visible = false;
			
			red.graphics.lineStyle(2, 0xFF0000);
			red.graphics.drawPath(Vector.<int>([1,2,2,1,2,2,1,2,2,1,2,2]), Vector.<Number>([30,60,30,30,60,30,SRC_SIZE-30,60,SRC_SIZE-30,30,SRC_SIZE-60,30,30,SRC_SIZE-60,30,SRC_SIZE-30,60,SRC_SIZE-30,SRC_SIZE-30,SRC_SIZE-60,SRC_SIZE-30,SRC_SIZE-30,SRC_SIZE-60,SRC_SIZE-30]));
			blue.graphics.lineStyle(2, 0x0000FF);
			blue.graphics.drawPath(Vector.<int>([1,2,2,1,2,2,1,2,2,1,2,2]), Vector.<Number>([30,60,30,30,60,30,SRC_SIZE-30,60,SRC_SIZE-30,30,SRC_SIZE-60,30,30,SRC_SIZE-60,30,SRC_SIZE-30,60,SRC_SIZE-30,SRC_SIZE-30,SRC_SIZE-60,SRC_SIZE-30,SRC_SIZE-30,SRC_SIZE-60,SRC_SIZE-30]));

			sprite.addChild( videoHolder );
			sprite.addChild( red );
			sprite.addChild( blue );
			blue.alpha = 0;
			red.x = red.y = 0;
			blue.x = blue.y = 0;
			return sprite;
		}

		/**
		 * 
		 */
		private function onEnterFrame(e: Event):void{
			if( camera.currentFPS > 0 ){
				getQRimage.process();
			}
		}
		/**
		 * 
		 */
		private function onQrImageReadComplete(e: QRreaderEvent):void{
			qrDecode.setQR(e.data); // QRreaderEvent.data: QR
			qrDecode.startDecode(); // 
		}
		/**
		 * 
		 */
		private function onQrDecodeComplete(e: QRdecoderEvent):void {
			blue.alpha = 1.0;
			redTimer.reset();
			redTimer.start();
			textArray.shift();
			textArray.push( e.data );  // QRdecoderEvent.data: 
			if ( textArray[0] == textArray[1] && textArray[1] == textArray[2] ) {
				if ( ExternalInterface.available && this.m_id != -1 ) 
		        {
		          	ExternalInterface.call("jQuery.WebcamQRCode.onQrDecodeComplete", m_id, e.data);
		        }
			}
		}

		private var redTimer:Timer = new Timer(400, 1);
		/**
		 * 
		 */
		private function onRedTimer(e:TimerEvent):void {
			blue.alpha = 0;
		}
	}
	
}