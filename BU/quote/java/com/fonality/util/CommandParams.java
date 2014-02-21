package com.fonality.util;

import com.beust.jcommander.Parameter;

public class CommandParams {

	@Parameter(names = "-r", description = "rollback")
	public boolean rollback = false;
}
