package com.fonality.service.common;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      ContentService.java
 //* Revision:      1.0
 //* Author:        Satya Boddu
 //* Created On:    Nov 28, 2012
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:   Application content service
 /********************************************************************************/

import java.io.StringWriter;
import java.util.Scanner;

import org.apache.log4j.Logger;
import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.Velocity;
import org.apache.velocity.exception.ParseErrorException;
import org.apache.velocity.exception.ResourceNotFoundException;
import org.apache.velocity.runtime.RuntimeConstants;
import org.apache.velocity.runtime.resource.loader.ClasspathResourceLoader;

import com.fonality.util.FSPConstants;

public class ContentService {

	private static final Logger LOGGER = Logger.getLogger(ContentService.class.getName());

	/**
	 * Loads the content at the requested path from the content source.
	 * 
	 * @param path
	 *            to the content
	 * @return the string representation of the content at that path.
	 */
	public String loadContent(String path) {

		Scanner scanner = null;
		StringBuilder contentBody = new StringBuilder();
		String newLine = System.getProperty("line.separator");

		try {
			scanner = new Scanner(getClass().getResourceAsStream(path));
			while (scanner.hasNextLine()) {
				contentBody.append(scanner.nextLine() + newLine);
			}

		} catch (Exception exc) {
			System.out.println("Content file not found: " + path);
		} finally {
			if (scanner != null)
				scanner.close();
		}

		return contentBody.toString();
	}

	/**
	 * Loads the content from the email template source using velocity template engine. Content
	 * files will be created using velocity template language. Runtime values are inserted by
	 * template engine using context data.
	 * 
	 * @param templateFile
	 * @return the string representation of the content at that path.
	 */
	public String loadEmailContent(VelocityContext context, String templateFile) {

		String content = null;
		try {
			this.initVelocityEngine();
			Template template = Velocity.getTemplate(templateFile);
			if (template != null) {
				StringWriter writer = new StringWriter();
				template.merge(context, writer);
				content = writer.toString();
				content = content.replaceAll(FSPConstants.NEW_LINE, FSPConstants.BREAK);
			}
		} catch (ResourceNotFoundException rnfe) {
			LOGGER.error("Unable to find email template " + templateFile);
		} catch (ParseErrorException pee) {
			LOGGER.error("Syntax error in template " + templateFile + ":" + pee);
		}

		return content;
	}

	/**
	 * Initializes velocity engine
	 */
	private void initVelocityEngine() {
		Velocity.setProperty(RuntimeConstants.RESOURCE_LOADER, "classpath");
		Velocity.setProperty("classpath.resource.loader.class",
				ClasspathResourceLoader.class.getName());
		Velocity.init();
	}
}
