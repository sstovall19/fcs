package com.fonality.util;

/*********************************************************************************
 //* Copyright (C) 2012 Fonality. All Rights Reserved.
 //*
 //* Filename:      SendMail.java
 //* Revision:      1.0
 //* Author:        Satya Boddu
 //* Created On:    Nov 27, 2012
 //* Modified by:   
 //* Modified On:   
 //*
 //* Description:   Email service
 /********************************************************************************/

import java.util.Map;
import java.util.Properties;

import javax.activation.DataHandler;
import javax.activation.DataSource;
import javax.mail.BodyPart;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import javax.mail.util.ByteArrayDataSource;

import org.apache.log4j.Logger;

public class SendMail {

	private String smtpHostName = null;
	private String smtpUser = null;
	private String smtpPassword = null;
	private Integer smtpPort = null;

	private String mailRecipientOverride;
	private String mailFormat = null;
	public static final String EMAIL_FORMAT_TEXT = "text/plain";
	public static final String EMAIL_FORMAT_HTML = "text/html; charset=utf-8";
	private static final String RELATED = "related";

	private static final Logger LOGGER = Logger.getLogger(SendMail.class
			.getName());

	private static SendMail _INSTANCE = new SendMail();

	/* Static 'instance' method */
	public static SendMail getInstance() {
		return _INSTANCE;
	}

	private SendMail() {
		Properties emailProps = null;
		this.mailFormat = EMAIL_FORMAT_HTML;
		try {
			emailProps = EmailProperties.getProperties();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		if (ObjectUtils.isValid(emailProps)) {
			this.smtpHostName = (String) emailProps
					.get(FSPConstants.EMAIL_SMTP_HOST);
			this.smtpUser = (String) emailProps
					.get(FSPConstants.EMAIL_SMTP_USER);
			this.smtpPassword = (String) emailProps
					.get(FSPConstants.EMAIL_SMTP_PWD);
			this.smtpPort = Integer.decode(emailProps
					.getProperty(FSPConstants.EMAIL_SMTP_PORT));
		} else {
			LOGGER.error("Mail configurations not set");
		}

	}

	/**
	 * Method to send the mail notification to the specified addresses
	 * 
	 * @param message
	 * @param sendToAddresses
	 * @param subject
	 * @param fromAddress
	 * @throws Exception
	 */
	public void postMail(String message, String[] sendToAddresses,
			String subject, String fromAddress) throws Exception {
		postMail(message, sendToAddresses, null, subject, fromAddress, null);
	}

	/**
	 * Method to send the mail notification to the specified addresses
	 * 
	 * @param message
	 * @param sendToAddresses
	 * @param sendCCAddresses
	 * @param subject
	 * @param fromAddress
	 * @throws Exception
	 */
	public void postMail(String message, String[] sendToAddresses,
			String[] sendCCAddresses, String subject, String fromAddress,
			Map<String, byte[]> attachmentMap) throws Exception {
		boolean debug = false;

		// Set the host smtp address
		Properties props = new Properties();
		props.put("mail.smtp.host", smtpHostName);
		props.put("mail.smtp.port", smtpPort);
		props.put("mail.smtp.user", smtpUser);
		props.put("mail.smtp.auth", "true");
		props.put("mail.smtp.starttls.enable", "true");
		props.put("mail.smtp.debug", "true");

		props.put("mail.smtp.socketFactory.port", smtpPort);

		props.put("mail.smtp.socketFactory.class",
				"javax.net.ssl.SSLSocketFactory");
		props.put("mail.smtp.socketFactory.fallback", "false");

		Session session = Session.getDefaultInstance(props, null);

		session.setDebug(debug);

		// create a message
		Message msg = new MimeMessage(session);
		Multipart multipart = new MimeMultipart(RELATED);
		BodyPart htmlPart = new MimeBodyPart();
		htmlPart.setContent(message, this.mailFormat);

		multipart.addBodyPart(htmlPart);

		if (ObjectUtils.isValid(attachmentMap)) {
			for (String fileName : attachmentMap.keySet()) {
				BodyPart messageAttachmentPart = new MimeBodyPart();
				DataSource source = new ByteArrayDataSource(
						attachmentMap.get(fileName), "application/octet-stream");
				messageAttachmentPart = new MimeBodyPart();

				messageAttachmentPart.setDataHandler(new DataHandler(source));
				messageAttachmentPart.setFileName(fileName);

				multipart.addBodyPart(messageAttachmentPart);
			}
		}

		// set the from and to address
		InternetAddress addressFrom = new InternetAddress(fromAddress);
		msg.setRecipients(Message.RecipientType.TO,
				getRecipients(sendToAddresses));
		if (sendCCAddresses != null)
			msg.setRecipients(Message.RecipientType.CC,
					getRecipients(sendCCAddresses));
		msg.setFrom(addressFrom);

		// Setting the Subject and Content Type
		msg.setSubject(subject);
		msg.setContent(multipart);

		// Use Transport to deliver the message

		Transport transport = session.getTransport("smtp");
		transport.connect(smtpHostName, smtpUser, smtpPassword);
		transport.sendMessage(msg, msg.getAllRecipients());
		transport.close();

		// Transport.send(msg);
	}

	/**
	 * 
	 * @param sendToAddresses
	 * @return
	 * @throws MessagingException
	 */
	private InternetAddress[] getRecipients(String[] sendToAddresses)
			throws MessagingException {
		if (mailRecipientOverride != null) {
			return new InternetAddress[] { new InternetAddress(
					mailRecipientOverride) };
		}

		InternetAddress[] recipient = new InternetAddress[sendToAddresses.length];
		for (int i = 0; i < sendToAddresses.length; i++) {
			recipient[i] = new InternetAddress(sendToAddresses[i]);
		}
		return recipient;
	}

	/**
	 * Config.getString("mail.recipient.override")
	 * 
	 * @param mailRecipientOverride
	 */
	public void setMailRecipientOverride(String mailRecipientOverride) {
		this.mailRecipientOverride = mailRecipientOverride;
	}

	/**
	 * @param mailFormat
	 *            the mailFormat to set
	 */
	public void setMailFormat(String mailFormat) {
		this.mailFormat = mailFormat;
	}

	/**
	 * @return the mailFormat
	 */
	public String getMailFormat() {
		return this.mailFormat;
	}
}
