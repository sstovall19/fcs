package com.fonality.bu.entity;

import java.util.List;

public class Input {

	//private Quote quote;
	private String promo_code;
	private String order_review;
	private String wizard;
	private String quote_id;
	private Contact contact;
	private List<Order_Group> order_group; 
	
	public Contact getContact() {
		return contact;
	}
	public void setContact(Contact contact) {
		this.contact = contact;
	}
	public List<Order_Group> getOrder_group() {
		return order_group;
	}
	public void setOrder_group(List<Order_Group> order_group) {
		this.order_group = order_group;
	}
	public String getPromo_code() {
		return promo_code;
	}
	public void setPromo_code(String promo_code) {
		this.promo_code = promo_code;
	}
	public String getOrder_review() {
		return order_review;
	}
	public void setOrder_review(String order_review) {
		this.order_review = order_review;
	}
	public String getWizard() {
		return wizard;
	}
	public void setWizard(String wizard) {
		this.wizard = wizard;
	}
	public String getQuote_id() {
		return quote_id;
	}
	public void setQuote_id(String quote_id) {
		this.quote_id = quote_id;
	}
	
	
	
}
