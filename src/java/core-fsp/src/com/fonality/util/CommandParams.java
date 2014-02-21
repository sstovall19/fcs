package com.fonality.util;

import com.beust.jcommander.Parameter;

public class CommandParams {

	@Parameter(names = "-j", description = "State Machine Transaction ID")
        public int transactionId  = 0;
	@Parameter(names = "-r", description = "rollback")
	public boolean rollback = false;
}
