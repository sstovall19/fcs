package com.fonality.bu.entity;

import java.lang.reflect.Type;
import java.util.List;

import com.google.gson.reflect.TypeToken;

public class Server {
	
	private List<Bundle> bundles; 
	private Shipping shipping;
	
	public List<Bundle> getBundles() {
		return bundles;
	}
	public void setBundles(List<Bundle> items) {
		this.bundles = items;
	}
	public Shipping getShipping() {
		return shipping;
	}
	public void setShipping(Shipping shipping) {
		this.shipping = shipping;
	}
	
	
}
