// Copyright 2006-2007 Fonality, Inc. ALL RIGHTS RESERVED

// This section is used to remove the yellow caused by Google Auto-fill

if(window.attachEvent)
  window.attachEvent("onload",setListeners);

function setListeners(){
  inputList = document.getElementsByTagName("INPUT");
  for(i=0;i<inputList.length;i++)
    inputList[i].attachEvent("onpropertychange",restoreStyles);
  selectList = document.getElementsByTagName("SELECT");
  for(i=0;i<selectList.length;i++)
    selectList[i].attachEvent("onpropertychange",restoreStyles);
}

function restoreStyles(){
  if(event.srcElement.style.backgroundColor != "")
    event.srcElement.style.backgroundColor = "";
}
// end Google Auto-fill section

// This function directs browser to a URL
function view(query)
{
    window.location=query;
}

//for pop-up windows
function popUp(URL,width,height,scrollbar) {
day = new Date();
id = day.getTime();
eval("page" + id + " = window.open(URL, '" + id + "', 'toolbar=0,scrollbars='+scrollbar+',location=0,statusbar=0,menubar=0,resizable=0,width='+width+',height='+height+',left = 190,top = 20');");
}

//for pop-up windows that we want to resize
function popUp_resize(URL,width,height,scrollbar) {
day = new Date();
id = day.getTime();
eval("page" + id + " = window.open(URL, '" + id + "','toolbar=0,scrollbars='+scrollbar+',location=0,statusbar=0,menubar=0,resizable=1,width='+width+',height='+height+',left = 190,top = 20');");
}

// this function is used for DHTML hiding and showing of div blocks
function div_change(div_id,div_val) {
	//alert('In div_change and div_id=' + div_id);
	var param=document.getElementById(div_id);
	if (div_val == 0) {
		param.style.display = "none";
	}
	else {
		param.style.display = "block";
	}
}

// These functions set and track the cookie for the side_bar for logging into the cpU/A
var referral = GetCookie("referral");
//var expdate = new Date ();
//expdate.setTime (expdate.getTime() + (24 * 60 * 60 * 1000 * 31));
var tenyears = new Date ();
tenyears.setFullYear(tenyears.getFullYear() + 10);
if (referral == null || referral == undefined || referral.length == 0)	SetCookie('referral',document.referrer, tenyears, 'fonality.com', '/');

// This gets the site a user was on before they came to our site
var refsite = GetCookie("referringsite");
if (refsite == null || refsite == undefined || refsite.length == 0)
{
	var tenyears = new Date ();
	tenyears.setFullYear(tenyears.getFullYear() + 10);
	var now   = new Date();
	var year  = now.getFullYear();
	var month = now.getMonth() + 1;
	var day   = now.getDate();
	var referringsite = year + "-" + month + "-" + day + " " + now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds() + "\r" + document.referrer;
	SetCookie("referringsite", referringsite, tenyears, 'fonality.com', '/');
}

// This gets the REQUEST_URI a user followed to come to our site
var request_url = GetCookie("requesturl");
if (request_url == null || request_url == undefined || request_url.length == 0)
{
	var tenyears = new Date ();
	tenyears.setFullYear(tenyears.getFullYear() + 10);
	SetCookie("requesturl", document.URL, tenyears, 'fonality.com', '/');
}

// Get Cookie Value function
function getCookieVal(offset)
{
	var endstr = document.cookie.indexOf (";", offset);
	if (endstr == -1) endstr = document.cookie.length;
	return unescape (document.cookie.substring(offset, endstr));
}

// Get Cookie function
function GetCookie(name) {
	var arg = name+"=";
	var alen = arg.length;
	var clen = document.cookie.length;
	var i = 0;
	while (i < clen) {
		var j = i + alen;
		if (document.cookie.substring(i, j) == arg) return getCookieVal(j);
		i = document.cookie.indexOf(" ", i) + 1;
		if (i == 0) break;
	}
	return null;
}

// Set Cookie function
function SetCookie (name, value)
{         
	var argv = SetCookie.arguments;
	var argc = SetCookie.arguments.length;
	var expires = (argc >= 2) ? argv[2] : null;
	var domain = (argc >= 3) ? argv[3] : null;
	var path = (argc >= 4) ? argv[4] : null;
	var secure = (argc >= 5) ? argv[5] : false;
	
	document.cookie = name + "=" + escape (value) + ((expires == null) ? "" : ("; expires=" + expires.toGMTString())) + ((path == null) ? "" : ("; path=" + path)) + ((domain == null) ? "" : ("; domain=" + domain)) + ((secure == true) ? "; secure" : "");
}
	
function setC(form) 
{   
	var expdate = new Date ();   
	expdate.setTime (expdate.getTime() + (24 * 60 * 60 * 1000 * 31));   
	SetCookie (form.name, form.value, expdate, 'fonality.com', '/');
}

// Javascript focus. Pass it the form_number and field_number within that form for an onload Focus
function placeFocus(form_number,field_number) {
  if (document.forms.length > 0) {
    var field = document.forms[form_number];
    for (i = 0; i < field.length; i++) {
      if ((field.elements[i].type == "text") || (field.elements[i].type == "textarea") || (field.elements[i].type.toString().charAt(0) == "s")) {
        document.forms[form_number].elements[field_number].focus();
        break;
      }
    }
  }
}

function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function mouse(event, grpName) { //v6.0
  var i,img,nbArr,args=mouse.arguments;
  if (event == "init" && args.length > 2) {
    if ((img = MM_findObj(args[2])) != null && !img.MM_init) {
      img.MM_init = true; img.MM_up = args[3]; img.MM_dn = img.src;
      if ((nbArr = document[grpName]) == null) nbArr = document[grpName] = new Array();
      nbArr[nbArr.length] = img;
      for (i=4; i < args.length-1; i+=2) if ((img = MM_findObj(args[i])) != null) {
        if (!img.MM_up) img.MM_up = img.src;
        img.src = img.MM_dn = args[i+1];
        nbArr[nbArr.length] = img;
    } }
  } else if (event == "over") {
    document.MM_nbOver = nbArr = new Array();
    for (i=1; i < args.length-1; i+=3) if ((img = MM_findObj(args[i])) != null) {
      if (!img.MM_up) img.MM_up = img.src;
      img.src = (img.MM_dn && args[i+2]) ? args[i+2] : ((args[i+1])? args[i+1] : img.MM_up);
      nbArr[nbArr.length] = img;
    }
  } else if (event == "out" ) {
    for (i=0; i < document.MM_nbOver.length; i++) {
      img = document.MM_nbOver[i]; img.src = (img.MM_dn) ? img.MM_dn : img.MM_up; }
  } else if (event == "down") {
    nbArr = document[grpName];
    if (nbArr)
      for (i=0; i < nbArr.length; i++) { img=nbArr[i]; img.src = img.MM_up; img.MM_dn = 0; }
    document[grpName] = nbArr = new Array();
    for (i=2; i < args.length-1; i+=2) if ((img = MM_findObj(args[i])) != null) {
      if (!img.MM_up) img.MM_up = img.src;
      img.src = img.MM_dn = (args[i+1])? args[i+1] : img.MM_up;
      nbArr[nbArr.length] = img;
  } }
}

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}

// These 2 methods are for dynamically creating multiple window.onload calls
function myAddEvent( obj, type, fn )
{
	if (obj.addEventListener)
		obj.addEventListener( type, fn, false );
	else if (obj.attachEvent)
	{
		obj["e"+type+fn] = fn;
		obj[type+fn] = function() { obj["e"+type+fn]( window.event ); }
		obj.attachEvent( "on"+type, obj[type+fn] );
	}
}

function myRemoveEvent( obj, type, fn )
{
	if (obj.removeEventListener)
		obj.removeEventListener( type, fn, false );
	else if (obj.detachEvent)
	{
		obj.detachEvent( "on"+type, obj[type+fn] );
		obj[type+fn] = null;
		obj["e"+type+fn] = null;
	}
}

function isDigit(select_field,field_name_English)
{
	var s       = document.form[select_field].value;
	var length  = s.length;
	var tmp     = String();
	var problem = 0;
	for (var i=0; i < s.length; i++)
	{
		var c = s.substr(i,1);
		if (c >= '0' && c <= '9')
		{
			tmp = tmp + c;
		}
		else
		{
			problem = 1;
		}
	}
	if (problem)
	{
		document.form[select_field].value = tmp;
		alert(field_name_English + " value must be a number.");
		return false;
	}
	return true;
}

