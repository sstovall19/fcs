package com.fonality.bu.quote;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.List;
import java.util.Properties;
import java.util.Set;
import java.util.logging.ConsoleHandler;
import java.util.logging.Logger;

import javax.xml.datatype.DatatypeConfigurationException;

import org.springframework.transaction.annotation.Transactional;

import com.fonality.bu.AbstractBusinessUnit;
import com.fonality.bu.entity.Bundle;
import com.fonality.bu.entity.BundlePriceModel;
import com.fonality.bu.entity.EntityAddress;
import com.fonality.bu.entity.OrderBundle;
import com.fonality.bu.entity.OrderGroup;
import com.fonality.bu.entity.TaxMapping;
import com.fonality.bu.entity.TaxTuple;
import com.fonality.bu.entity.json.Input;
import com.fonality.dao.BundlePriceModelDAO;
import com.fonality.dao.OrderBundleDAO;
import com.fonality.dao.OrderGroupDAO;
import com.fonality.service.BillSoftService;
import com.fonality.service.QuoteTaxationService;
import com.fonality.util.BillSoftProperties;
import com.fonality.util.FSPConstants;
import com.fonality.util.ObjectUtils;

@Transactional
public class TaxCalculator extends AbstractBusinessUnit {

	private static QuoteTaxationService quoteTaxService;
	private static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger(TaxCalculator.class.getName());

	/**
	 * @param args
	 * @throws IOException
	 */
	public static void main(String[] args) throws IOException {

		TaxCalculator self = new TaxCalculator();
		self.mainMethod(args);
	}


	@Override
	public String execute(Input inputObj) {

		quoteTaxService = (QuoteTaxationService)context.getBean("quoteTaxationService");
		try {
			quoteTaxService.calculateAndInsertTaxRates(inputObj);
		} catch (Exception e) {
			e.printStackTrace(System.err);
			logger.error("Error retrieveing tax total: " + e.getLocalizedMessage());
			return ("Error retrieveing tax total: " + e.getLocalizedMessage());
		}

		return null;
	}

	@Override
	public String rollback(Input inputObj) {
		// This unit does not do anything that can be rolled back
		return null;
	}

	/**
	 * Method to suppress SOAP warnings on console
	 * 
	 */
	private void suppressSoapWarnings() {
		Logger rootLogger = Logger.getLogger("");
		java.util.logging.Handler[] handlers = rootLogger.getHandlers();
		if (handlers.length > 0 && handlers[0] instanceof ConsoleHandler) {
			rootLogger.removeHandler(handlers[0]);
		}

	}

}
