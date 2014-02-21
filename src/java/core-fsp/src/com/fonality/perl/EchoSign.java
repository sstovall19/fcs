package com.fonality.perl;

import java.io.IOException;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import com.fonality.bu.entity.json.Input;
import com.fonality.service.EchoSignService;
import com.fonality.util.FSPConstants;
import com.fonality.util.ObjectUtils;
import org.json.JSONObject;
import java.util.Map;
import java.util.HashMap;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;


public class EchoSign {
	private int orderGroupId;
	private ApplicationContext  context;
	private EchoSignService echoSignService;
	public EchoSign(int orderGroupId) throws Exception {
		this.orderGroupId = orderGroupId;
		context = new ClassPathXmlApplicationContext("classpath:application-context.xml");
		echoSignService = (EchoSignService) context.getBean("echoSignService");
	}
	public JSONObject sendAgreement() throws Exception {
		JSONObject ret;
		try {
			ret= echoSignService.emailEchoSignAgreement(orderGroupId);
		} catch (Exception e) {
			ret = errorJSON(e);
		}
		return ret;

	}
	public JSONObject retrieveAgreement()  throws Exception {
		
                JSONObject ret;
		try {
			ret = echoSignService.getSignedEchoSignDocument(orderGroupId);
		} catch (Exception e) {
			ret = errorJSON(e);
		}
		return ret;
        }
	public JSONObject errorJSON(Exception e) {
		JSONObject json = new JSONObject();
		try {
			json.put("status",0);
			json.put("message",e.getCause());
		} catch (Exception ee) {
			try {
				json.put("message","NESTED ERROR!");
			} catch(Exception e3) {
				
			}
		}
		return json;
	}
}
