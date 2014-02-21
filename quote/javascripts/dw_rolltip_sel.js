
/*************************************************************************
  This code is from Dynamic Web Coding at dyn-web.com
  Copyright 2002-5 by Sharon Paine 
  See Terms of Use at www.dyn-web.com/bus/terms.html
  regarding conditions under which you may use this code.
  This notice must be retained in the code as is!
*************************************************************************/

/*
  dw_rolltip.js   version date: Feb 2005  
  requires dw_event.js and dw_viewport.js
  algorithm for time-based animation from youngpup.net
*/

var RollTip = {
    followMouse: true,
    overlaySelects: true,  // iframe shim for select lists (ie win)    
    offX: 12,
    offY: 12,
    ID: "rolltipDiv",
    // duration of clipping animation
    showAni: 400,
    hideAni: 200,

    ovTimer: 0, // for overlaySelects    
    ready:false, timer:null, tip:null, shim:null, supportsOverlay:false,
  
    init: function() {
        // op7.5(?) can do the clip now
        var ua = navigator.userAgent; // only because opera.com contacted me
        var i = ua.indexOf("Opera");  // otherwise I don't do this sort of browser detection!
        var opok = ( i == -1 || parseFloat( ua.slice(i + 6) ) > 7.5 )? true: false;
        if ( document.createElement && document.body && 
            typeof document.body.appendChild != "undefined" && opok ) {
        var el = document.createElement("DIV");
        el.id = this.ID; document.body.appendChild(el);
		this.showMult = el.offsetWidth/this.showAni/this.showAni;	
        this.hideMult = el.offsetWidth/this.hideAni/this.hideAni;	                
        el.style.clip = "rect(0, 0, 0, 0)";
        el.style.visibility = "visible";
        this.supportsOverlay = this.checkOverlaySupport();        
        this.ready = true;
        }
    },

    reveal: function(msg, e, s_bgcolor, s_width, s_justify) {
        if (this.timer) { clearTimeout(this.timer);	this.timer = 0; }
        if ( this.overlaySelects && this.supportsOverlay ) {
            if (this.ovTimer) { clearTimeout(this.ovTimer); this.ovTimer = 0; }
            this.ovTimer = setTimeout("RollTip.toggleOverlay(" + 1 + ")", 10);
        }
        this.tip = document.getElementById( this.ID );
        this.writeTip(""); // for mac ie 
        this.writeTip(msg);
        viewport.getAll();
        this.w = this.tip.offsetWidth; this.h = this.tip.offsetHeight;
        this.startTime = (new Date()).getTime();
        this.positionTip(e);

       	// Allow for additional formatting
		if (this.tip) {	
			if (s_bgcolor)
				this.tip.style.backgroundColor = s_bgcolor;
			if (s_width)
				this.tip.style.width = s_width;
			if (s_justify)
				this.tip.style.textAlign = s_justify;
		}	

        if (this.followMouse) // set up mousemove 
            dw_event.add( document, "mousemove", this.trackMouse, true );
        
        this.timer = setInterval("RollTip.rollOut()", 10);
    },
  
    rollOut: function() {
        var elapsed = (new Date()).getTime() - this.startTime;
        if (elapsed < this.showAni) {
            var cv = this.w - Math.round( Math.pow(this.showAni - elapsed, 2) * this.showMult );
            this.clipTo(0, cv, this.h, 0);
        } else {
            this.clipTo(0, this.w, this.h, 0);
            clearInterval(this.timer);
        }
    },
  
    conceal: function() {
        if (this.timer) { clearTimeout(this.timer);	this.timer = 0; }
        if ( this.overlaySelects && this.supportsOverlay ) {        
            if (this.ovTimer) { clearTimeout(this.ovTimer); this.ovTimer = 0; }
            this.ovTimer = setTimeout("RollTip.toggleOverlay(" + 0 + ")", this.hideAni );
        }
        this.startTime = (new Date()).getTime();
        if (this.followMouse) // release mousemove
            dw_event.remove( document, "mousemove", this.trackMouse, true );
        this.timer = setInterval("RollTip.rollUp()", 10);
    },
  
    rollUp: function() {
        var elapsed = (new Date()).getTime() - this.startTime;
        if ( elapsed < this.hideAni ) {
            var cv = Math.round( Math.pow(this.hideAni - elapsed, 2) * this.hideMult );
            this.clipTo(0, cv, this.h, 0);
        } else {
            this.clipTo(0, 0, this.h, 0);
            clearInterval(this.timer);
            this.tip = null;
        }  
    },
  
    writeTip: function(msg) {
        if ( this.tip && typeof this.tip.innerHTML != "undefined" ) this.tip.innerHTML = msg;
    },
  
    clipTo: function(top, rt, btm, lft) {
       	if (this.tip) this.tip.style.clip = "rect("+top+"px, "+rt+"px, "+btm+"px, "+lft+"px)";
        if ( this.shim ) this.shim.style.clip = "rect("+top+"px, "+rt+"px, "+btm+"px, "+lft+"px)";
    },
  
    positionTip: function(e) {
        // put e.pageX/Y first! (for Safari)
        var x = e.pageX? e.pageX: e.clientX + viewport.scrollX;
        var y = e.pageY? e.pageY: e.clientY + viewport.scrollY;

        if ( x + this.tip.offsetWidth + this.offX > viewport.width + viewport.scrollX ) {
            x = x - this.tip.offsetWidth - this.offX;
         //   if ( x < 0 ) x = 0; // no good with roll-out if layer appears over link
        } else x = x + this.offX;
    
        if ( y + this.tip.offsetHeight + this.offY > viewport.height + viewport.scrollY ) {
            y = y - this.tip.offsetHeight - this.offY;
            if ( y < viewport.scrollY ) y = viewport.height + viewport.scrollY - this.tip.offsetHeight;
        } else y = y + this.offY;

        this.tip.style.left = x + "px"; this.tip.style.top = y + "px";
        
        // position shim too        
        if ( this.overlaySelects && this.supportsOverlay && this.shim ) {
            this.shim.style.left = this.tip.style.left;
            this.shim.style.top = this.tip.style.top;
        }
    },
    
    trackMouse: function(e) {
    	e = dw_event.DOMit(e);
     	RollTip.positionTip(e);
    },
    
    // check need for and support of iframe shim
    checkOverlaySupport: function() {
        if ( typeof document.body != "undefined" && 
            typeof document.body.insertAdjacentHTML != "undefined" && 
            !window.opera && navigator.appVersion.indexOf("MSIE 5.0") == -1 &&
            navigator.userAgent.indexOf("Windows") != -1 
            )
            return true;
        else return false;
    }, 
    
    toggleOverlay: function(bVis) {
        if ( this.overlaySelects && this.supportsOverlay ) { 
            if ( !document.getElementById('tipShim') ) 
                document.body.insertAdjacentHTML("beforeEnd", '<iframe id="tipShim" src="javascript:false" style="position:absolute; left:0; top:0; z-index:500; visibility:hidden" scrolling="no" frameborder="0"></iframe>');
            this.shim = document.getElementById('tipShim');
            if (this.shim) {
                switch (bVis) {
                    case 1 :
                        this.shim.style.left = this.tip.style.left;
                        this.shim.style.top = this.tip.style.top;
                        this.shim.style.width = this.tip.offsetWidth + "px";
                        this.shim.style.height = this.tip.offsetHeight + "px";
                        this.shim.style.visibility = "visible";
                    break;
                    case 0 :
                        this.shim.style.visibility = "hidden";
                        this.shim = null;
                    break;
                }
            }
        }
    }
};
