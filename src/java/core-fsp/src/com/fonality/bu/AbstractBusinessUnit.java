package com.fonality.bu;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.ParameterException;
import com.fonality.bu.entity.json.Input;
import com.fonality.util.CommandParams;
import com.fonality.util.HibernateProperties;
import java.lang.Thread;
import java.lang.InterruptedException;
import java.util.ArrayList;

/**
 * All Java business units should extend this class. In addition to implementing
 * the abstract methods, every subclass of AbstractBusinessUnit must implement a
 * main method like this:
 * 
 * public static void main(String[] args) throws IOException { 
 * 		SubClass self = new SubClass(); 
 * 		self.mainMethod(args); 
 * }
 * 
 * Explicit wiring of service beans should take place in the execute and rollback implementations, 
 * never in main
 * @author Jason V
 * 
 */
public abstract class AbstractBusinessUnit {

	private static final int EXIT_CODE_FAILURE = 1;
	private static final int EXIT_CODE_SUCCESS = 0;
	private static final int EXIT_CODE_TIMEOUT = 98;
	private static final int EXIT_CODE_HALT = 99;
	private static final int EXIT_CODE_RESTART = 88;
	
	private int curExitCode = EXIT_CODE_SUCCESS;
	protected int transactionId;
	protected ApplicationContext context;
	private Thread timeoutHandlerThread;

	public void init() throws IOException {
                context = new ClassPathXmlApplicationContext("classpath:application-context.xml");
	}
	
    public void mainMethod(String[] args) throws IOException {

		// Handle some silliness coming from IPC::Open3
		ArrayList<String> argsTmp = new ArrayList<String>();
		for (String arg : args) {
			if (arg.indexOf(" ")<0) {
				argsTmp.add(arg);
			} else {
				String[] pieces = arg.split("\\s");
				for (String piece: pieces) {
					argsTmp.add(piece);
				}
			}
			
		}
		args = argsTmp.toArray(new String[argsTmp.size()]);
		//final long timeout = maxExecutionTime();
		timeoutHandlerThread = new Thread() {
			public void run() {
				try {
					Thread.sleep(getMaxExecutionTime());
					timeoutHandler();
				} catch (InterruptedException e) {
				}
			}
		};
		HibernateProperties.initProperties();
		context = new ClassPathXmlApplicationContext("classpath:application-context.xml");

		String serializedOutput = "Fail";
		String errorOut = null;
		int exitCode = 0;
		BufferedReader in = new BufferedReader(new InputStreamReader(System.in));// We should define an encoding here?
		String s;
		StringBuilder inputBuf = new StringBuilder();
		while ((s = in.readLine()) != null)
			inputBuf.append(s);
		// A Ctrl-Z terminates the input
		String fullInput = inputBuf.toString();
		Input inputObj = null;
		try {
			timeoutHandlerThread.start();
			inputObj = new Input(new JSONObject(fullInput));

			// Set up command-line arguments parser
			CommandParams cp = new CommandParams();
			JCommander parser = new JCommander(cp);
			try {
				parser.parse(args);
				// Check for rollback
				if (cp.rollback) {
					errorOut = rollback(inputObj);
				} else {
					errorOut = execute(inputObj);
				}
				transactionId = cp.transactionId;
			} catch (ParameterException pe) {
				errorOut = ("Improper usage: " + pe.getMessage());
			}

			serializedOutput = inputObj.getJSONObject().toString(4);

		} catch (JSONException je) {
			errorOut = ("JSON error: " + je.getMessage());
		}

		if (errorOut == null) {
			System.out.println(serializedOutput);
			exitCode = curExitCode;
		} else {
			System.err.println(errorOut);
			exitCode = 1;
		}
		timeoutHandlerThread.interrupt();
		System.exit(exitCode);
	}

	/**
	 * This method contains all of the business logic to be performed by the BU
	 * under normal circusmtances
	 * 
	 * Explicit wiring of necessary beans should happen in this method, not in main
	 * 
	 * @param json
	 * @return A string representing any error state reached by this method, or
	 *         else null
	 */
	public abstract String execute(Input inputObj);

	/**
	 * This method rolls back any changes made by the execute method given the
	 * same JSON input
	 * 
	 * @param json
	 * @return A string representing any error state reached by this method, or
	 *         else null
	 */
	public abstract String rollback(Input inputObj);
	/**
	 * This method deletes all keys from the JSON object. Business units that
	 * are expected to return no useable JSON should call this method
	 * 
	 * Explicit wiring of necessary beans should happen in this method, not in main
	 * 
	 * @param json
	 *            The JSON object to empty
	 */
	public void emptyJSON(JSONObject json) {
		// Generate a list of keys first in order to prevent concurrent
		// mofdification
		List<String> keyList = new ArrayList<String>();
		for (Iterator ite = json.keys(); ite.hasNext();) {
			String key = (String) ite.next();
			keyList.add(key);
		}
		for (Iterator ite = keyList.iterator(); ite.hasNext();) {
			String key = (String) ite.next();
			json.remove(key);
		}

	}
	
	public void halt() {
		curExitCode = EXIT_CODE_HALT;
	}


/**
 * This method returns, simply, the max allowed execution time for the unit in milliseconds.
 * Override in the subclass if your unit requires more than the default.
 * @param none
**/
	protected long getMaxExecutionTime() {
		return 180000;
	}
/**
 * This method is called when the maximum time alloted for execution has been passed.
 * Override if your unit requires additional handling for timeout conditions, e.g. closiing
 * open sessions for certain evil ERP systems that will otherwise lock the user out for an hour.
**/
	protected void timeoutHandler() {
		displayErrorTimeout("Request Timed Out");
	}

	protected void displayErrorTimeout(String message) {
		System.err.println(message);
		System.exit(98);
	}
}
