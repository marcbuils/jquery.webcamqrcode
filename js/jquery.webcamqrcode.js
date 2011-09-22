/**
 * WebcamQRCode: Scannez les codes QR à partir de votre site web 
 * http://webcamwrcode.marcbuils.fr
 * 
 * Par Marc Buils ( mbuils@marcbuils.fr )
 * Sous licence LGPL v3 (http://www.gnu.org/licenses/lgpl-3.0.txt)
 */

(function($){
    $.WebcamQRCode = function( ){};
    $.WebcamQRCode.defaultOptions = {
    	messageNoFlash:		"L'animation flash n'est pas prise en charge",
        onQRCodeDecode: 	function( p_data ){ alert( "onQRCodeDecode data: " + p_data ); },
        onError:			function( p_e ){ alert( p_e ); },
        webcamOnStart:		true,
        webcamStopContent:	$('<p>Capture stopped</p>'),
        delay:				5000,
        path:				""
    };
    $.WebcamQRCode.s_currentID = 1;
    
    /**
	 * Start webcam reading
	 */
    $.WebcamQRCode.start = function( $this ){
		var _flash = $('<object></object>');
		var _messageNoFlash = $('<p></p>');
		var __options = $this.data( 'webcam_qrcode_options' );

		// Set message if no flash
		_messageNoFlash.text( __options.messageNoFlash );
		            
		// Set flash object information
		_flash.attr( 'type', "application/x-shockwave-flash" );
		_flash.attr( 'data', __options.path + "swf/webcamqrcode.swf?ID=" + $this.attr( '_webcam_qrcode_id' ) );
		_flash.attr( 'width', "100%" );
		_flash.attr( 'height', "100%" );
		_flash.append( _messageNoFlash );
		            
		$this.html( _flash );
    };
    
    /**
	 * Stop webcam reading
     */
    $.WebcamQRCode.stop = function( $this ){
    	var __options = $this.data( 'webcam_qrcode_options' );

    	$this.html( __options.webcamStopContent );
    };
    
    $.WebcamQRCode.onQrDecodeComplete = function ( p_id, p_data ) {
    	var $this = $('[_webcam_qrcode_id="' + p_id + '"]');
    	var __options = $this.data( 'webcam_qrcode_options' );
    	var _currenttime = (new Date).getTime();
    	var _lasttime = $this.data( 'last_decode_time' );
    	if ( _lasttime == null ) _lasttime = 0;
    	
    	if ( _currenttime-_lasttime > __options.delay ) {    
	    	$this.data( 'last_decode_time', _currenttime );
	    	$this.data( 'webcam_qrcode_options' ).onQRCodeDecode( p_data );
    	}
    };
    
    /**
     * Constructor
     */
    $.fn.WebcamQRCode = function( p_options ) {
        var _options = $.extend( {}, $.WebcamQRCode.defaultOptions, p_options );
        
        // Add start function
		this.start = function( ){
			return this.each(function(){
				$.WebcamQRCode.start( $(this) );
			});
		};
		
		// Add stop function
    	this.stop = function()
		{
			return this.each(function(){
				$.WebcamQRCode.stop( $(this) );
			});
		};
		
		/*
		 * Initialisation
		 */	
        return this.each(function(){
        	var $this = $(this);

			if ( !$this.attr( '_webcam_qrcode_id' ) ) {
				$this.attr( '_webcam_qrcode_id' , $.WebcamQRCode.s_currentID++ );
				$this.data( 'webcam_qrcode_options' , _options);
				
        		if ( _options.webcamOnStart ) {
					$.WebcamQRCode.start( $this );
        		} else {
        		  $.WebcamQRCode.stop( $this );
        		}
        	}
        });
    };

})(jQuery);
