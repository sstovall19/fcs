package com.fonality.perl;

import java.util.HashMap;

import org.json.JSONObject;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

import com.fonality.bu.entity.json.Input;
import com.fonality.service.OrderService;

public class OrderBilling {
	public static HashMap execute(JSONObject in) {
		HashMap<String, String> ret = new HashMap<String, String>();
		ret.put("status", "failed");
		ret.put("message", "U SUCK");
		ApplicationContext context = new ClassPathXmlApplicationContext(
				"classpath:application-context.xml");
		//OneTimeTaxationService orderTaxationService = (OneTimeTaxationService) context.getBean("orderTaxationService");
		OrderService order = (OrderService) context.getBean("orderService");
		try {
			Input input = new Input(in);
			ret.put("message", order.processOrderInvoice(input));
		} catch (Exception e) {
			ret.put("message", e.getCause().toString());
		}
		return ret;
	}
}
