package com.fonality.service.common;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      JasperReportService.java
 //* Revision:      1.0
 //* Author:        Satya Boddu
 //* Created On:    Jan 18, 2013
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:   Service class to generate jasper report 
 /********************************************************************************/

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.Map;

import javax.sql.DataSource;

import net.sf.jasperreports.engine.JasperExportManager;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.JasperReport;
import net.sf.jasperreports.engine.util.JRLoader;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fonality.service.EmailService;
import com.fonality.util.FSPConstants;

@Service
@Transactional
public class JasperReportService {

	public JasperReportService() {

	}

	@Autowired
	public DataSource dataSource;

	@Autowired
	EmailService emailService;

	private static final Logger LOGGER = Logger.getLogger(JasperReportService.class.getName());

	/**
	 * Generate the jasper report based on paramaters map and jasper objects
	 * 
	 * @param parameterMap
	 * @return byte[]
	 */
	public byte[] generateJasperOutput(Map<String, Object> parameterMap) throws Exception {
		// Create jasperReport and jasperPrint instances
		JasperReport jasperReport = (JasperReport) JRLoader.loadObject(this
				.getReportStream((String) parameterMap.get(FSPConstants.REPORT_PATH_PARAM)));

		JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, parameterMap,
				dataSource.getConnection());

		return JasperExportManager.exportReportToPdf(jasperPrint);

	}

	private InputStream getReportStream(String reportPath) throws FileNotFoundException {
		InputStream reportStream = getClass().getResourceAsStream(reportPath);

		if (reportStream == null) {
			reportStream = new FileInputStream(reportPath.substring(1));
		}

		return reportStream;
	}
}
