package com.fonality.bu.entity.json;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      BaseInput.java
 //* Revision:      1.1
 //* Author:        Satya Boddu
 //* Created On:    Dec 03, 2012
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:   Base Input class to handle json data
 /********************************************************************************/

import java.io.Serializable;

import org.json.JSONException;
import org.json.JSONObject;

import com.fonality.util.ObjectUtils;

public abstract class BaseInput implements Serializable {

	private static final long serialVersionUID = 8760947780005075295L;

	private JSONObject inputJson;

	public BaseInput(JSONObject inputJson) throws JSONException {
		this.inputJson = inputJson;
		this.populateJSONData();
	}

	/**
	 * 
	 */
	public BaseInput() {
		super();
	}

	/**
	 * Method to populate values from JSONObject
	 * 
	 */
	protected abstract void populateJSONData();

	/**
	 * Method to set value in JSONObject
	 * 
	 * @param key
	 * @param value
	 */
	protected void setJSONValue(String key, Object value) {
		try {
			ObjectUtils.setJSONValue(this.inputJson, key, value);
		} catch (JSONException je) {
			// This should be an unreachable state
			throw new RuntimeException("JSON has reached an impossible state");
		}
	}

	/**
	 * Method to get string value from JSONObject
	 * 
	 * @param key
	 * @return value
	 */
	protected String getString(String key) {
		return ObjectUtils.getJSONString(this.inputJson, key);
	}

	/**
	 * Method to get string value from JSONObject
	 * 
	 * @param key
	 * @return value
	 */
	protected int getInteger(String key) {
		return ObjectUtils.getJSONInteger(this.inputJson, key);
	}

	protected long getLong(String key) {
		return ObjectUtils.getJSONLong(this.inputJson, key);
	}

	/**
	 * @return the jSONObject
	 */
	public JSONObject getJSONObject() {
		return this.inputJson;
	}

	/**
	 * @param jSONObject
	 *            the jSONObject to set
	 */
	public void setJSONObject(JSONObject jSONObject) {
		this.inputJson = jSONObject;
	}
}
